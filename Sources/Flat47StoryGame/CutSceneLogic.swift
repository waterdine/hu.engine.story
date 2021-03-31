//
//  CutSceneState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import AVKit
import SpriteKit
import GameplayKit

class CutSceneLogic: GameScene {
	
	var currentTextIndex: Int = 0
	var lastTextChange: TimeInterval = 0.0
	var lastAnimationCompleteTime: TimeInterval = 0.0
	var animatingText: Bool = false
	var currentTextSpeed: Double = 0.0
	var speedingText: Bool = false
	var disableSpeedingText: Bool = false
	
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
	var fontColor: UIColor?
	var pauseFor: Double = 0.0
	var lastTime: Double = 0.0
	var queuedSound: String = ""
	
	class func newScene(gameLogic: GameLogic) -> CutSceneLogic {
		guard let scene = CutSceneLogic(fileNamed: "CutScene" + gameLogic.getAspectSuffix()) else {
			print("Failed to load CutScene.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic;
		
		return scene
	}
	
	override func didMove(to view: SKView) {
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
		let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		textLabel!.alpha = 1.0
		fixedText = ""
		newText = ""
		textLabel?.attributedText =  NSAttributedString()
		currentTextIndex = -1
		lastTextChange = 0.0
		lastAnimationCompleteTime = 0.0
		animatingText = false
		currentTextSpeed = self.gameLogic!.textFadeTime
		speedingText = false
		readyForNextScene = false
		waitfornext = false
		centerText = false
		pauseFor = 0.0
		
		let storyImage = shakeNode.childNode(withName: "//StoryImage") as? SKSpriteNode
		let image: String = self.data?["Image"] as! String
		let imagePath = Bundle.main.path(forResource: image, ofType: ".png")
		if (imagePath != nil) {
			storyImage?.isHidden = false
			storyImage?.texture = SKTexture(imageNamed: imagePath!)
		} else {
			storyImage?.isHidden = true
		}
		
		let textList: NSArray? = self.data?["Text"] as? NSArray
		if (textList != nil && textList!.count > 0 && (textList?[0] as! String) == "[instant]") {
			if (hasMoreText()) {
				nextText()
			}
		}
		
		if (fontColor != nil) {
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			textLabel?.fontColor = fontColor!
			fontColor = nil
		}
		
		let transitionType: String? = self.data?["Transition"] as? String
		let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
		cover?.alpha = 0.0
		if (transitionType != nil) {
			if (transitionType == "Flash") {
				let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
				cover?.alpha = 1.0
				cover?.color = UIColor.white
			} else if (transitionType == "FadeBlack") {
				cover?.alpha = 1.0
				cover?.color = self.backgroundColor
				let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
				fontColor = textLabel?.fontColor
				textLabel?.fontColor = UIColor.lightGray
			}
		}
		let disableSpeedText: Bool? = self.data?["DisableSpeedText"] as? Bool
		disableSpeedingText = (disableSpeedText != nil && disableSpeedText! == true)
		
		let variableToSet = self.data?["VariableToSet"] as? String
		let variableText = self.data?["VariableText"] as? String
		if (variableToSet != nil && variableText != nil) {
			self.gameLogic?.variables[variableToSet!] = Bundle.main.localizedString(forKey: variableText!, value: nil, table: self.gameLogic!.getChapterTable())
		}
		let flag = self.data?["Flag"] as? String
		if (flag != nil) {
			self.gameLogic?.flags.append(flag!)
		}
	}
	
	override func update(_ currentTime: TimeInterval) {
		let delta = currentTime - lastTime
		lastTime = currentTime
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
		} else if (!speedingText && !fastText && currentTextSpeed == 0.01) {
			updateCharactersForTextSpeed(currentTime: currentTime)
			currentTextSpeed = self.gameLogic!.textFadeTime
		}
		
		if (animatingText) {
			if (lastTextChange == 0.0) {
				lastTextChange = currentTime
			}
			let centerTextLabel = shakeNode.childNode(withName: "//CenterText") as? SKLabelNode
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			let delta = (currentTime - lastTextChange)
			
			let mainColor = (textLabel?.fontColor!.cgColor.components)!
			let font = UIFont.init(name: (textLabel!.fontName!) as String, size: textLabel!.fontSize)
			let mainAttributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : textLabel?.fontColor as Any]
			let string: NSMutableAttributedString = NSMutableAttributedString(string: fixedText, attributes: mainAttributes)
			
			var remainingCharacters = newText.count
			if (remainingCharacters > 0) {
				if (fadeFullText) {
					let fadingCharacterAlpha = (delta >= 1.0) ? 1.0 : delta
					let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(fadingCharacterAlpha))

					let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
					let attributedCharacterString: NSAttributedString = NSAttributedString(string: newText, attributes: attributes)
					string.append(attributedCharacterString)
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
						
						let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
						var characterIndex: String.Index = newText.startIndex
						newText.formIndex(&characterIndex, offsetBy: index)
						let character = newText[characterIndex]
						if (character == " ") {
							fakeIndex = index + fakeOffset
						}
						let attributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: attributes)
						string.append(attributedCharacterString)
						
						if (characterAlpha == 1.0) {
							remainingCharacters -= 1
						}
					}
				} else {
					let textFadeTime = currentTextSpeed
					let deltaFadeTime = delta / textFadeTime
					let fadingCharacterAlpha = deltaFadeTime - Double(Int(deltaFadeTime))
					
					var fakeIndex = 0
					for index: Int in 0 ... newText.count - 1 {
						let indexFadeStartTime = Double(fakeIndex) * textFadeTime
						let characterAlpha = (delta >= indexFadeStartTime + textFadeTime) ? 1.0 : (delta < indexFadeStartTime) ? 0.0 : fadingCharacterAlpha
						let color = UIColor.init(red: mainColor[0], green: mainColor[1], blue: mainColor[2], alpha: CGFloat(characterAlpha))
						
						let attributes: [NSAttributedString.Key : Any] = [.font : font as Any, .foregroundColor : color]
						var characterIndex: String.Index = newText.startIndex
						newText.formIndex(&characterIndex, offsetBy: index)
						let character = newText[characterIndex]
						if (character == ",") {
							fakeIndex += 5
						} else {
							fakeIndex += 1
						}
						let attributedCharacterString: NSAttributedString = NSAttributedString(string: String(character), attributes: attributes)
						string.append(attributedCharacterString)
						
						if (characterAlpha == 1.0) {
							remainingCharacters -= 1
						}
					}
				}
			}
			
			if (centerText && centerTextLabel != nil) {
				textLabel?.isHidden = true
				centerTextLabel?.attributedText = string
				centerTextLabel?.isHidden = false
			} else {
				centerTextLabel?.isHidden = true
				textLabel?.attributedText = string
				textLabel?.isHidden = false
			}
			
			if (remainingCharacters == 0) {
				lastAnimationCompleteTime = currentTime
				animatingText = false
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
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (animatingText && !disableSpeedingText && !fadeFullText && !instantWordText && !waitfornext) {
			speedingText = true
		}
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if (speedingText) {
			speedingText = false
		} else if (readyForNextAction(currentTime: event!.timestamp, delay: self.gameLogic!.actionDelay)) {
			if (waitfornext) {
				waitfornext = false
				animatingText = true
				lastTextChange = 0.0
				if (queuedSound != "") {
					self.run(SKAction.playSoundFileNamed(queuedSound, waitForCompletion: false))
					queuedSound = ""
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
				if (character == ",") {
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
		
		let textList: NSArray? = self.data?["Text"] as? NSArray
		return (currentTextIndex == -1) || (stickyText && (textList![self.currentTextIndex + 1] as! String != ""))
	}
	
	func readyForNextAction(currentTime: TimeInterval, delay: Double) -> Bool {
		let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		return !(textLabel?.hasActions())! && !shakeNode.hasActions() && !animatingText && currentTime >= (lastAnimationCompleteTime + delay)
	}
	
	func hasMoreText() -> Bool {
		let textList: NSArray? = self.data?["Text"] as? NSArray
		return textList!.count > self.currentTextIndex + 1
	}
	
	func hasTextCommand() -> Bool {
		let textList: NSArray? = self.data?["Text"] as? NSArray
		if (textList != nil && textList!.count > self.currentTextIndex) {
			let nextLine = (textList![self.currentTextIndex] as! String)
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
		} else if (command.starts(with: "[sound:")) {
			var file = command.replacingOccurrences(of: "[sound:", with: "")
			file = file.trimmingCharacters(in: ["]"])
			let path = file + ".mp3"
			if (waitfornext) {
				queuedSound = path
			} else {
				self.run(SKAction.playSoundFileNamed(path, waitForCompletion: false))
			}
		} else if (command.starts(with: "[soundloop:")) {
			var musicFile = command.replacingOccurrences(of: "[soundloop:", with: "")
			musicFile = musicFile.trimmingCharacters(in: ["]"])
			do {
				if (self.gameLogic?.loopSound != nil) {
					self.gameLogic?.loopSound?.stop()
				}
				if (musicFile != "") {
					let file = Bundle.main.url(forResource: musicFile, withExtension: ".mp3")
					if (file != nil) {
						try self.gameLogic?.loopSound = AVAudioPlayer(contentsOf: file!)
						self.gameLogic?.loopSound?.numberOfLoops = -1
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
		} else if (command.starts(with: "[fadeblack]")) {
			let cover = shakeNode.childNode(withName: "//Cover") as? SKSpriteNode
			cover?.run(SKAction.fadeIn(withDuration: 0.3))
			cover?.color = self.backgroundColor
			let textLabel = shakeNode.childNode(withName: "//Text") as? SKLabelNode
			fontColor = textLabel?.fontColor
			textLabel?.fontColor = UIColor.lightGray
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
			self.gameLogic?.fadePlayer?.setVolume(0, fadeDuration: 3.0)
			self.gameLogic?.player = nil
		}
	}
	
	func nextText() {
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

		let textList: NSArray? = self.data?["Text"] as? NSArray
		clearTextCommands()
		while (hasTextCommand()) {
			processTextCommand(command: (textList?[self.currentTextIndex] as! String))
			currentTextIndex += 1
		}
		
		if (textList != nil && textList!.count > self.currentTextIndex) {
			if (waitfornext) {
				fixedText = ""
				newText = skipIndent ? "" : "\t"
			} else if (fixedText != "" && fixedText != "\t" && !skipIndent) {
				newText += "\t"
			}
			var nextLine = Bundle.main.localizedString(forKey: (textList?[self.currentTextIndex] as! String), value: nil, table: self.gameLogic!.getChapterTable())
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
