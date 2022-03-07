//
//  CutSceneState.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import AVKit
import SpriteKit
import 虎_engine_base

#if os(OSX)
typealias UIColor = NSColor
typealias UIFont = NSFont
#endif

@available(OSX 10.13, *)
@available(iOS 9.0, *)
open class CutSceneLogic: GameScene {
	
	var currentTextIndex: Int = 0
	var lastTextChange: TimeInterval = 0.0
	var lastAnimationCompleteTime: TimeInterval = 0.0
	var animatingText: Bool = false
	var currentTextSpeed: Double = 0.0
	var speedingText: Bool = false
	var disableSpeedingText: Bool = false
    var textSpeechPause: Bool = false
	
	var fixedText: String = ""
	var newText: String = ""
	var stickyText: Bool = true
	var instantText: Bool = false
	var fadeFullText: Bool = false
	var instantWordText: Bool = false
	var fastText: Bool = false
	var applyShake: Bool = false
	var readyForNextScene: Bool = false
	var waitfornext: Bool = false
	var centerText: Bool = false
	var skipIndent: Bool = false
	var shakeNode: SKNode = SKNode()
	var pauseFor: Double = 0.0
	var lastTime: Double = 0.0
	var queuedSound: URL? = nil
	var queuedBlackCover: Bool = false
	
	var currentOffset: CGSize = CGSize(width: 0.0, height: 0.0)
	var wantedOffset: CGSize = CGSize(width: 0.0, height: 0.0)
	var currentScale: Float = 1.0
	var wantedScale: Float = 1.0
	
	var subSceneNode: SKNode = SKNode()
	var currentSubScene: String = ""
	
	var maskTexture1: SKTexture? = nil
	var maskTexture2: SKTexture? = nil
	
	class func newScene(gameLogic: GameLogic) -> CutSceneLogic {
        let scene: CutSceneLogic = gameLogic.loadScene(scene: "Default.CutScene", classType: CutSceneLogic.classForKeyedUnarchiver()) as! CutSceneLogic

		scene.requiresMusic = true
        let fontSizeScale: CGFloat = CGFloat(Float.init(gameLogic.localizedString(forKey: "FontScale", value: nil, table: "Story")) ?? 1.0)
        let coverTextLabel = scene.childNode(withName: "//CoverText") as? SKLabelNode
        coverTextLabel?.fontSize = coverTextLabel!.fontSize * fontSizeScale
        let textLabel = scene.childNode(withName: "//Text") as? SKLabelNode
        textLabel?.fontSize = textLabel!.fontSize * fontSizeScale
        let centerTextLabel = scene.childNode(withName: "//CenterText") as? SKLabelNode
        centerTextLabel?.fontSize = centerTextLabel!.fontSize * fontSizeScale
        
		return scene
	}
	
	open override func didMove(to view: SKView) {
		super.didMove(to: view)
		if (self.childNode(withName: "//ShakeNode") == nil) {
			shakeNode.name = "ShakeNode"
			let children = self.children
			self.removeAllChildren()
			for child in children {
				shakeNode.addChild(child)
			}
			self.addChild(shakeNode)
		}
		let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
		coverTextLabel?.alpha = 0.0
        coverTextLabel?.fontName = gameLogic!.localizedString(forKey: "FontName", value: nil, table: "Story")
		let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		textLabel!.alpha = 1.0
        textLabel?.fontName = gameLogic!.localizedString(forKey: "FontName", value: nil, table: "Story")
        let centerTextLabel = shakeNode.childNode(withName: "//CenterText") as? SKLabelNode
        centerTextLabel?.fontName = gameLogic!.localizedString(forKey: "FontName", value: nil, table: "Story")
		fixedText = ""
		newText = ""
        if #available(iOS 11.0, *) {
            textLabel?.attributedText = NSAttributedString()
            coverTextLabel?.attributedText = NSAttributedString()
        } else {
            // Fallback on earlier versions
        }
		currentTextIndex = -1
		lastTextChange = 0.0
		lastAnimationCompleteTime = 0.0
		animatingText = false
        textSpeechPause = false
		currentTextSpeed = self.gameLogic!.textFadeTime
		speedingText = false
		readyForNextScene = false
		waitfornext = false
		centerText = false
		pauseFor = 0.0
		
        var imageMaskUrl = gameLogic?.loadUrl(forResource: "Default.ImageMask", withExtension: ".png", subdirectory: "Images")
		if (imageMaskUrl != nil) {
            maskTexture1 = SKTexture(imageNamed: imageMaskUrl!.path)
		}
        imageMaskUrl = gameLogic?.loadUrl(forResource: "Default.ImageMask3", withExtension: ".png", subdirectory: "Images")
		if (imageMaskUrl != nil) {
			maskTexture2 = SKTexture(imageNamed: imageMaskUrl!.path)
		}
		
		let storyImage = shakeNode.childNode(withName: "//StoryImage") as? SKSpriteNode
        let image: String = (data as! CutSceneScene).Image
		let imageUrl = gameLogic?.loadUrl(forResource: image, withExtension: ".png", subdirectory: "Images/Backgrounds")
		if (imageUrl != nil) {
			storyImage?.isHidden = false
			storyImage?.texture = SKTexture(imageNamed: imageUrl!.path)
		} else {
			storyImage?.isHidden = true
		}
		
        let imageScale = (data as! CutSceneScene).Scale
		var imageScaleFloat: Float? = nil
		if (imageScale != nil) {
			imageScaleFloat = Float.init(imageScale!)!
		}
		if (imageScaleFloat != nil) {
			wantedScale = imageScaleFloat!
			currentScale = imageScaleFloat!
		} else {
			wantedScale = 1.0
			currentScale = 1.0
		}
		
		currentOffset = CGSize(width: 0.0, height: 0.0)
        let imageOffsetX = (data as! CutSceneScene).OffsetX
        let imageOffsetY = (data as! CutSceneScene).OffsetY
		var imageOffsetXFloat: Float? = nil
		if (imageOffsetX != nil) {
			imageOffsetXFloat = Float.init(imageOffsetX!)
		}
		var imageOffsetYFloat: Float? = nil
		if (imageOffsetY != nil) {
			imageOffsetYFloat = Float.init(imageOffsetY!)
		}
		
		if (imageOffsetXFloat != nil) {
			currentOffset.width = CGFloat(imageOffsetXFloat!)
		}
		if (imageOffsetYFloat != nil) {
			currentOffset.height = CGFloat(imageOffsetYFloat!)
		}
		
		wantedOffset = currentOffset
		
        let imageRotation = (data as! CutSceneScene).Rotation
		if (imageRotation != nil) {
			storyImage?.shader?.uniformNamed("u_flip")?.floatValue = 1.0
		} else {
			storyImage?.shader?.uniformNamed("u_flip")?.floatValue = 0.0
		}
		
		storyImage?.shader?.uniformNamed("u_offset_x")?.floatValue = Float(currentOffset.width)
		storyImage?.shader?.uniformNamed("u_offset_y")?.floatValue = Float(currentOffset.height)
		storyImage?.shader?.uniformNamed("u_scale")?.floatValue = currentScale
		storyImage?.shader?.uniformNamed("u_maskTexture")?.textureValue = maskTexture1
		
        let storyScene: String? = (data as! CutSceneScene).SubScene
		if (storyScene != nil) {
			if (storyScene! != currentSubScene) {
				currentSubScene = storyScene!
				storyImage?.removeAllChildren()
                let subScene = gameLogic?.loadEffectOverlay(scene: storyScene!) as? SKNode
				subSceneNode = (subScene?.childNode(withName: "//Root"))!
				subScene?.removeAllChildren()
				storyImage?.addChild(subSceneNode)
			}
			subSceneNode.isPaused = false
		} else {
			storyImage?.removeAllChildren()
			currentSubScene = ""
		}
		
        let textList: [TextLine]? = (data as! CutSceneScene).Text
        if (textList != nil && textList!.count > 0 && textList?[0].textString == "[instant]") {
			if (hasMoreText()) {
				nextText()
			}
		}
		
        let transitionType: String? = (data as! CutSceneScene).Transition
		let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
		cover?.alpha = 0.0
		coverTextLabel?.alpha = 0.0
		if (transitionType != nil) {
			if (transitionType == "Flash") {
				let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
				cover?.alpha = 1.0
				cover?.color = UIColor.white
				textLabel?.alpha = 1.0
			} else if (transitionType == "FadeBlack") {
				cover?.alpha = 1.0
				cover?.color = self.backgroundColor
				coverTextLabel?.alpha = 1.0
				textLabel?.alpha = 0.0
			}
		}
        let disableSpeedText: Bool? = (data as! CutSceneScene).DisableSpeedText
		disableSpeedingText = (disableSpeedText != nil && disableSpeedText! == true)
		
		let variableToSet = (data as! CutSceneScene).VariableToSet
		let variableText = (data as! CutSceneScene).VariableText
		if (variableToSet != nil && variableText != nil) {
            self.gameLogic?.gameState.variables[variableToSet!] = gameLogic!.localizedString(forKey: variableText!, value: nil, table: self.gameLogic!.getChapterTable())
		}
		let flag = (data as! CutSceneScene).Flag
		if (flag != nil) {
            self.gameLogic?.gameState.flags.append(flag!)
		}
		enablePrevSceneIndicator()
	}
	
	open override func update(_ currentTime: TimeInterval) {
		var delta = currentTime - lastTime
		if (lastTime == 0) {
			delta = 0
		}
		lastTime = currentTime
		
		let storyImageNode = self.childNode(withName: "//StoryImage") as? SKSpriteNode
		
		if (wantedScale != currentScale) {
			if (wantedScale < currentScale) {
				currentScale -= Float(delta / 10.0)
				if (currentScale < 0.0) {
					currentScale = wantedScale
				}
				if (currentScale < wantedScale) {
					currentScale = wantedScale
				}
			} else if (wantedScale > currentScale) {
				currentScale += Float(delta / 10.0)
				if (currentScale > 1.0) {
					currentScale = wantedScale
				}
				if (currentScale > wantedScale) {
					currentScale = wantedScale
				}
			}
			storyImageNode?.shader?.uniformNamed("u_scale")?.floatValue = currentScale
		}
		
		if (wantedOffset != currentOffset) {
			if (wantedOffset.width < currentOffset.width) {
				currentOffset.width -= CGFloat(delta / 10.0)
				if (currentOffset.width < 0.0) {
					currentOffset.width = wantedOffset.width
				}
				if (currentOffset.width < wantedOffset.width) {
					currentOffset.width = wantedOffset.width
				}
			} else if (wantedOffset.width > currentOffset.width) {
				currentOffset.width += CGFloat(delta / 10.0)
				if (currentOffset.width > 1.0) {
					currentOffset.width = wantedOffset.width
				}
				if (currentOffset.width > wantedOffset.width) {
					currentOffset.width = wantedOffset.width
				}
			}
			
			if (wantedOffset.height < currentOffset.height) {
				currentOffset.height -= CGFloat(delta / 10.0)
				if (currentOffset.height < 0.0) {
					currentOffset.height = wantedOffset.height
				}
				if (currentOffset.height < wantedOffset.height) {
					currentOffset.height = wantedOffset.height
				}
			} else if (wantedOffset.height > currentOffset.height) {
				currentOffset.height += CGFloat(delta / 10.0)
				if (currentOffset.height > 1.0) {
					currentOffset.height = wantedOffset.height
				}
				if (currentOffset.height > wantedOffset.height) {
					currentOffset.height = wantedOffset.height
				}
			}
			storyImageNode?.shader?.uniformNamed("u_offset_x")?.floatValue = Float(currentOffset.width)
			storyImageNode?.shader?.uniformNamed("u_offset_y")?.floatValue = Float(currentOffset.height)
		}
		
		if (pauseFor > 0) {
			pauseFor -= delta
			return
		}
		
		if (readyForNextScene) {
			if (readyForNextAction(currentTime: currentTime, delay: 0.0)) {
				gameLogic?.nextScene()
			}
			return
		}
		
		if (waitfornext) {
			return
		}
		
		if (speedingText || fastText) {
			currentTextSpeed = 0.01
		} else if (!speedingText && !fastText && currentTextSpeed != self.gameLogic!.textFadeTime) {
			updateCharactersForTextSpeed(currentTime: currentTime)
			currentTextSpeed = self.gameLogic!.textFadeTime
		}
		
		if (animatingText) {
			if (lastTextChange == 0.0) {
				lastTextChange = currentTime
			}
			let centerTextLabel = shakeNode.childNode(withName: "//CenterText") as? SKLabelNode
			let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			let delta = (currentTime - lastTextChange)
			
			let mainColor = (textLabel?.fontColor!.cgColor.components)!
			let font = UIFont.init(name: (textLabel!.fontName!) as String, size: textLabel!.fontSize)
			let mainAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : textLabel?.fontColor as Any]
			let string: NSMutableAttributedString = NSMutableAttributedString(string: fixedText, attributes: mainAttributes)
			
			let coverMainColor = coverTextLabel != nil ? (coverTextLabel?.fontColor!.cgColor.components)! : mainColor
			let coverMainAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : coverTextLabel?.fontColor as Any]
			let coverString: NSMutableAttributedString = NSMutableAttributedString(string: fixedText, attributes: coverMainAttributes)
			
			var remainingCharacters = newText.count
			if (remainingCharacters > 0) {
				if (fadeFullText) {
					let fadingCharacterAlpha = (delta >= 1.0) ? 1.0 : delta
					let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(fadingCharacterAlpha))
					let coverColor = UIColor.init(red: coverMainColor[0], green: coverMainColor[1], blue: coverMainColor[2], alpha: CGFloat(fadingCharacterAlpha))

					let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
					let attributedCharacterString: NSAttributedString = NSAttributedString(string: newText, attributes: attributes)
					string.append(attributedCharacterString)
					let coverAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : coverColor]
					let coverAttributedCharacterString: NSAttributedString = NSAttributedString(string: newText, attributes: coverAttributes)
					coverString.append(coverAttributedCharacterString)
					if (fadingCharacterAlpha == 1.0) {
						remainingCharacters = 0
					}
				} else if (instantWordText) {
					let textFadeTime = currentTextSpeed
					let deltaFadeTime = delta / textFadeTime
					let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
					
					let fakeOffset = currentTextIndex == 1 ? 5 : 0
					var fakeIndex = fakeOffset
					for index: Int in 0 ... newText.count - 1 {
						let indexFadeStartTime = Double(fakeIndex) * textFadeTime
						let characterAlpha = (delta >= indexFadeStartTime + textFadeTime) ? 1.0 : (delta < indexFadeStartTime) ? 0.0 : fadingCharacterAlpha
						let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(characterAlpha))
						let coverColor = UIColor.init(red: coverMainColor[0], green: coverMainColor[1], blue: coverMainColor[2], alpha: CGFloat(characterAlpha))
						
						let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
						let coverAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : coverColor]
						var characterIndex: String.Index = newText.startIndex
						newText.formIndex(&characterIndex, offsetBy: index)
						let character = newText[characterIndex]
						if (character == " ") {
							fakeIndex = index + fakeOffset
						}
						let attributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: attributes)
						string.append(attributedCharacterString)
						let coverAttributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: coverAttributes)
						coverString.append(coverAttributedCharacterString)
						
						if (characterAlpha == 1.0) {
							remainingCharacters -= 1
						}
					}
				} else {
					let textFadeTime = currentTextSpeed
					let deltaFadeTime = delta / textFadeTime
					let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
					
					var fakeIndex = 0
                    var lastRevealedCharacter: Character = Character.init("a")
					for index: Int in 0 ... newText.count - 1 {
						let indexFadeStartTime = Double(fakeIndex) * textFadeTime
						let characterAlpha = (delta >= indexFadeStartTime + textFadeTime) ? 1.0 : (delta < indexFadeStartTime) ? 0.0 : fadingCharacterAlpha
						let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(characterAlpha))
						let coverColor = UIColor.init(red: coverMainColor[0], green: coverMainColor[1], blue: coverMainColor[2], alpha: CGFloat(characterAlpha))
						
						let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
						let coverAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : coverColor]
						var characterIndex: String.Index = newText.startIndex
						newText.formIndex(&characterIndex, offsetBy: index)
						let character = newText[characterIndex]
						if (character == "," || character == ";") {
							fakeIndex += 5
						} else {
							fakeIndex += 1
						}
                        
						let attributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: attributes)
						string.append(attributedCharacterString)
						let coverAttributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: coverAttributes)
						coverString.append(coverAttributedCharacterString)
						
                        if (characterAlpha != 0.0) {
                            lastRevealedCharacter = character
                        }
                        
						if (characterAlpha == 1.0) {
							remainingCharacters -= 1
						}
					}
                    
                    textSpeechPause = (lastRevealedCharacter == "," || lastRevealedCharacter == "." || lastRevealedCharacter == ";")
				}
			}
			
			if (centerText && centerTextLabel != nil) {
				textLabel?.isHidden = true
				coverTextLabel?.isHidden = true
				centerTextLabel?.isHidden = false
                if #available(iOS 11.0, *) {
                    centerTextLabel?.attributedText = string
                } else {
                    // Fallback on earlier versions
                }
			} else {
				centerTextLabel?.isHidden = true
				textLabel?.isHidden = false
				coverTextLabel?.isHidden = false
                if #available(iOS 11.0, *) {
                    coverTextLabel?.attributedText = coverString
                    textLabel?.attributedText = string
                } else {
                    // Fallback on earlier versions
                }
			}
			
			if (remainingCharacters == 0) {
				lastAnimationCompleteTime = currentTime
				animatingText = false
                textSpeechPause = false
			}
		}
		
		if (applyShake) {
			shakeNode.position = CGPoint(x: 0.0, y: 0.0)
			shakeNode.run(SKAction.sequence([SKAction.moveBy(x: -5.0, y: 0.0, duration: 0.2), SKAction.moveBy(x: 10.0, y: 0.0, duration: 0.1), SKAction.moveBy(x: -7.5, y: 0.0, duration: 0.2), SKAction.moveBy(x: 5.0, y: 0.0, duration: 0.1), SKAction.moveBy(x: -2.5, y: 0.0, duration: 0.1)]))
			applyShake = false
		}
		
		if (readyForNextAction(currentTime: currentTime, delay: self.gameLogic!.textDelay)) {
			if (canAutoProgress()) {
				if (hasMoreText()) {
					nextText()
				}
			}
		}
	}
	
	open override func interactionBegan(_ point: CGPoint, timestamp: TimeInterval) {
		if (super.handleToolbar(point)) {
			return
		}

		// atode: add super call with bool!
		if (gameMenu?.isHidden == false) {
			gameMenu?.interactionBegan(point, timestamp: timestamp)
			return
		}
		
		if (animatingText && !disableSpeedingText && !fadeFullText && !instantWordText && !waitfornext) {
			speedingText = true
		}
	}
	
	open override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (super.handleToolbar(point)) {
			gameMenu?.isHidden = false
			return
		}
		
		if (gameMenu?.isHidden == false) {
			gameMenu?.interactionEnded(point, timestamp: timestamp)
			return
		}

		if (!prevSceneNode!.isHidden && prevSceneNode!.frame.contains(point)) {
			self.gameLogic?.prevScene()
		} else if (readyForNextScene) {
			if (nextSceneNode!.frame.contains(point)) {
				self.gameLogic?.nextScene()
			} else if (prevSceneNode!.frame.contains(point)) {
				self.gameLogic?.nextScene()
			}
		} else if (speedingText) {
			speedingText = false
		} else if (readyForNextAction(currentTime: timestamp, delay: self.gameLogic!.actionDelay)) {
			if (waitfornext) {
				waitfornext = false
				animatingText = true
				lastTextChange = 0.0
				if (queuedSound != nil) {
                    self.run(SKAction.run({[queuedSound] in
                        if (self.gameLogic?.loopSound != nil) {
                            self.gameLogic?.loopSound?.stop()
                        }
                        if (queuedSound != nil) {
                            try! self.gameLogic?.loopSound = AVAudioPlayer(contentsOf: queuedSound!)
                            self.gameLogic?.loopSound?.numberOfLoops = 0
                            self.gameLogic?.alignVolumeLevel()
                            self.gameLogic?.loopSound?.play()
                        }
                    }))
					queuedSound = nil
				}
				if (queuedBlackCover) {
					let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
					cover?.run(SKAction.fadeIn(withDuration: 0.2))
					cover?.color = self.backgroundColor
					let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
					textLabel?.run(SKAction.fadeOut(withDuration: 0.2))
					textLabel?.alpha = 1.0
					let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
					coverTextLabel?.removeAllActions()
					coverTextLabel?.alpha = 0.0
					coverTextLabel?.run(SKAction.fadeIn(withDuration: 0.2))
					queuedBlackCover = false
				}
			} else if (hasMoreText()) {
				nextText()
				if (!animatingText && !hasMoreText() && !waitfornext) {
					readyForNextScene = true
					enableNextSceneIndicator()
				}
			} else {
				readyForNextScene = true
				enableNextSceneIndicator()
			}
		}
	}
	
	func updateCharactersForTextSpeed(currentTime: TimeInterval) {
		let delta = currentTime - lastTextChange
		lastTextChange = currentTime

		let textFadeTime = currentTextSpeed
		var fixedCharacters = 0
		if (newText.count > 0) {
			var fakeIndex = 0
			for index: Int in 0 ... newText.count - 1 {
				let indexFadeStartTime = Double(fakeIndex) * textFadeTime
				if ((delta >= indexFadeStartTime + textFadeTime)) {
					fixedCharacters += 1
				}
				var characterIndex: String.Index = newText.startIndex
				newText.formIndex(&characterIndex, offsetBy: index)
				let character = newText[characterIndex]
				if (character == "," || character == ";") {
					fakeIndex += 5
				} else {
					fakeIndex += 1
				}
			}

			var characterIndex: String.Index = newText.startIndex
			newText.formIndex(&characterIndex, offsetBy: fixedCharacters - 1)
			let substring = newText[newText.startIndex ... characterIndex]
			fixedText += substring
			newText.removeFirst(fixedCharacters)
		}
	}
	
	func canAutoProgress() -> Bool {
		if (!hasMoreText()) {
			return true
		}
		
        let textList: [TextLine]? = (data as! CutSceneScene).Text
		return (currentTextIndex == -1) || (stickyText && (textList![self.currentTextIndex + 1].textString != ""))
	}
	
	func readyForNextAction(currentTime: TimeInterval, delay: Double) -> Bool {
		let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		return !(textLabel?.hasActions())! && !shakeNode.hasActions() && !animatingText && currentTime >= (lastAnimationCompleteTime + delay)
	}
	
	func hasMoreText() -> Bool {
		let textList: [TextLine]? = (data as! CutSceneScene).Text
		return textList!.count > self.currentTextIndex + 1
	}
	
	func hasTextCommand() -> Bool {
		let textList: [TextLine]? = (data as! CutSceneScene).Text
		if (textList != nil && textList!.count > self.currentTextIndex) {
			let nextLine = (textList![self.currentTextIndex].textString)
			return nextLine.hasPrefix("[") && nextLine.hasSuffix("]")
		} else {
			return false
		}
	}
	
	func clearTextCommands() {
		instantText = false
		fadeFullText = false
		fastText = false
		instantWordText = false
		applyShake = false
		waitfornext = false
		centerText = false
		skipIndent = false
		disableNextSceneIndicator()
	}
	
	func processTextCommand(command: String) {
		if (command == "[instant]") {
			instantText = true
		} else if (command == "[clear]") {
			waitfornext = true
			enableNextSceneIndicator()
		} else if (command == "[fade]") {
			fadeFullText = true
		} else if (command == "[fasttext]") {
			fastText = true
		} else if (command == "[instantword]") {
			instantWordText = true
		} else if (command == "[camerashake]") {
			applyShake = true
		} else if (command.starts(with: "[panto:")) {
			var pos = command.replacingOccurrences(of: "[panto:", with: "")
			pos = pos.trimmingCharacters(in: ["]"])
			let parts: [Substring] = pos.split(separator: ",")
			if (parts.count == 1) {
				let offset = Float.init(parts[0])
				wantedOffset.width = CGFloat(offset!)
				wantedOffset.height = CGFloat(offset!)
			} else if (parts.count == 2) {
				let offsetX = Float.init(parts[0])
				let offsetY = Float.init(parts[1])
				wantedOffset.width = CGFloat(offsetX!)
				wantedOffset.height = CGFloat(offsetY!)
			}
		} else if (command.starts(with: "[zoom:")) {
			var scale = command.replacingOccurrences(of: "[zoom:", with: "")
			scale = scale.trimmingCharacters(in: ["]"])
			wantedScale = Float.init(scale)!
		} else if (command.starts(with: "[sound:")) {
			var file = command.replacingOccurrences(of: "[sound:", with: "")
			file = file.trimmingCharacters(in: ["]"])
            let url = gameLogic?.loadUrl(forResource: file, withExtension: ".mp3", subdirectory: "Sound")
            if (url != nil) {
                if (waitfornext) {
                    queuedSound = url
                } else {
                    self.run(SKAction.run({[url] in
                        if (self.gameLogic?.loopSound != nil) {
                            self.gameLogic?.loopSound?.stop()
                        }
                        if (url != nil) {
                            try! self.gameLogic?.loopSound = AVAudioPlayer(contentsOf: url!)
                            self.gameLogic?.loopSound?.numberOfLoops = 0
                            self.gameLogic?.alignVolumeLevel()
                            self.gameLogic?.loopSound?.play()
                        }
                    }))
                }
            }
		} else if (command.starts(with: "[soundloop:")) {
			var musicFile = command.replacingOccurrences(of: "[soundloop:", with: "")
			musicFile = musicFile.trimmingCharacters(in: ["]"])
			do {
				if (self.gameLogic?.loopSound != nil) {
					self.gameLogic?.loopSound?.stop()
				}
				if (musicFile != "") {
                    let file = gameLogic?.loadUrl(forResource: musicFile, withExtension: ".mp3", subdirectory: "Sound")
					if (file != nil) {
						try self.gameLogic?.loopSound = AVAudioPlayer(contentsOf: file!)
						self.gameLogic?.loopSound?.numberOfLoops = -1
                        self.gameLogic?.alignVolumeLevel()
						self.gameLogic?.loopSound?.play()
					}
				}
			} catch  {
			}
		} else if (command.starts(with: "[soundloopstop]")) {
			if (self.gameLogic?.loopSound != nil) {
				self.gameLogic?.loopSound?.stop()
			}
		} else if (command.starts(with: "[fadecover]")) {
			let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
			cover?.run(SKAction.fadeOut(withDuration: 1.0))
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			textLabel?.run(SKAction.fadeIn(withDuration: 1.0))
			let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
			coverTextLabel?.run(SKAction.fadeOut(withDuration: 1.0))
		} else if (command.starts(with: "[hidecover]")) {
			let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
			cover?.alpha = 0.0
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			textLabel?.alpha = 1.0
			let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
			coverTextLabel?.alpha = 0.0
		} else if (command.starts(with: "[changemask]")) {
			let storyImage = shakeNode.childNode(withName: "//StoryImage") as? SKSpriteNode
			storyImage?.shader?.uniformNamed("u_maskTexture")?.textureValue = maskTexture2
		} else if (command.starts(with: "[blackcover]")) {
			if (waitfornext) {
				queuedBlackCover = true
			} else {
				let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
				cover?.run(SKAction.fadeIn(withDuration: 0.2))
				cover?.color = self.backgroundColor
				let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
				textLabel?.run(SKAction.fadeOut(withDuration: 0.2))
				textLabel?.alpha = 1.0
				let coverTextLabel = shakeNode.childNode(withName: "//CoverText") as? SKLabelNode
				coverTextLabel?.removeAllActions()
				coverTextLabel?.alpha = 0.0
				coverTextLabel?.run(SKAction.fadeIn(withDuration: 0.2))
			}
		} else if (command == "[pause]") {
			pauseFor = 1.0
		} else if (command == "[longpause]") {
			pauseFor = 5.0
		} else if (command == "[nextscene]") {
			readyForNextScene = true
		} else if (command == "[center]") {
			centerText = true
		} else if (command == "[skipindent]") {
			skipIndent = true
		} else if (command.starts(with: "[stopmusic]")) {
			if (self.gameLogic?.player != nil) {
				self.gameLogic?.player?.stop()
				self.gameLogic?.player = nil
			}
		} else if (command.starts(with: "[fademusic]")) {
			if (self.gameLogic?.fadePlayer != nil) {
				self.gameLogic?.fadePlayer?.stop()
			}
			self.gameLogic?.fadePlayer = self.gameLogic?.player
            if #available(iOS 10.0, *) {
                self.gameLogic?.fadePlayer?.setVolume(0, fadeDuration: 3.0)
            } else {
                self.gameLogic?.fadePlayer?.volume = 0;
            }
			self.gameLogic?.player = nil
		}
	}
	
	func nextText() {
		disablePrevSceneIndicator()
		
		currentTextIndex += 1

		if (stickyText) {
			fixedText += newText
		} else{
			fixedText = ""
		}
		newText = ""
		
		if (fixedText != "") {
			fixedText += "\n"
		}

		let textList: [TextLine] = (data as! CutSceneScene).Text
		clearTextCommands()
		while (hasTextCommand()) {
            processTextCommand(command: (textList[self.currentTextIndex].textString))
			currentTextIndex += 1
		}
		
		if (textList.count > self.currentTextIndex) {
			if (waitfornext) {
				fixedText = ""
				newText = skipIndent ? "" : "\t"
			} else if (fixedText != "" && fixedText != "\t" && !skipIndent) {
				newText += "\t"
			}
			var nextLine = gameLogic!.localizedString(forKey: (textList[self.currentTextIndex].textString), value: nil, table: self.gameLogic!.getChapterTable())
			nextLine = self.gameLogic!.unwrapVariables(text: nextLine)
			newText += nextLine
		}
		
		if (self.instantText) {
			fixedText += newText
			newText = ""
		}
		
		if (!readyForNextScene && !waitfornext && (newText != "" || fixedText != "")) {
			animatingText = true
			lastTextChange = 0.0
		}
	}
}
