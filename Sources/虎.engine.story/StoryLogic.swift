//
//  StoryState.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class StoryLogic: CutSceneLogic {
    
    let characterNodes = SKNode()
    var character: CharacterLogic? = nil
    var characters: [CharacterLogic] = []
	
	override class func newScene(gameLogic: GameLogic) -> StoryLogic {
        let scene: StoryLogic = gameLogic.loadScene(scene: "Default.Story", resourceBundle: "虎.engine.story", classType: StoryLogic.classForKeyedUnarchiver()) as! StoryLogic
 
		scene.stickyText = false
		scene.requiresMusic = true
        let fontSizeScale: CGFloat = CGFloat(Float.init(gameLogic.localizedString(forKey: "CharacterFontScale", value: nil, table: "Story")) ?? 1.0)
        let textLabel = scene.childNode(withName: "//Text") as? SKLabelNode
        textLabel?.fontSize = textLabel!.fontSize * fontSizeScale
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
        
        var startHidden = false
        let textList: [TextLine]? = (data as! StoryScene).Text
        if (textList != nil && textList!.count > 0 && ((textList?[0].textString == "[enterleft]") || (textList?[0].textString == "[enterright]"))) {
            startHidden = true
        }
        
        let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
        speakerImageNode?.texture = nil
        let scale = (speakerImageNode?.userData!["scale"] as! CGFloat)
        let storyImageNode = self.childNode(withName: "//StoryImage")
        let positionScale = storyImageNode?.xScale ?? 1.0
        
        let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
        let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
        let font = gameLogic!.localizedString(forKey: "CharacterFontName", value: nil, table: "Story")
        speakerRoyalLabel.fontName = font
        speakerRoyalLabel.isHidden = true
        speakerLabel.fontName = font
        speakerLabel.isHidden = true
        
        characters = []
        if ((data as! StoryScene).Speaker != nil && !(data as! StoryScene).Speaker!.isEmpty) {
            let speaker = gameLogic!.localizedString(forKey: (data as! StoryScene).Speaker!, value: nil, table: "Story")
            let isRoyalSpeaker = (data as! StoryScene).RoyalSpeaker ?? false
            var speakerImage: String? = (data as! StoryScene).SpeakerImage
            if (speakerImage == nil) {
                speakerImage = gameLogic?.story?.Characters.first(where: { $0.name == (data as! StoryScene).Speaker! })?.model
            }
            let imageRotation: Float? = (data as! StoryScene).Rotation
            var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
            
            if (isRoyalSpeaker) {
                speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
            }
            character = CharacterLogic(gameLogic: gameLogic, shakeNode: shakeNode, startHidden: startHidden, isRoyalSpeaker: isRoyalSpeaker, speaker: speaker, shortName: (data as! StoryScene).Speaker!, speakerImage: speakerImage, imageRotation: imageRotation, speakerAreaNode: speakerAreaNode, scale: scale, positionScale: positionScale, position: -(self.scene!.frame.height / 2.0))
            characters.append(character!)
        }
        
        if (textList != nil) {
            for textLine in textList! {
                if let lineCharacter = textLine.character {
                    let speaker = gameLogic!.localizedString(forKey: lineCharacter, value: nil, table: "Story")
                    if (!characters.contains(where: { $0.speaker == speaker })) {
                        var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
                        
                        let character = gameLogic?.story?.Characters.first(where: { $0.name == textLine.character })
                        if (character != nil) {
                            if (character!.royal) {
                                speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
                            }
                            characters.append(CharacterLogic(gameLogic: gameLogic, shakeNode: shakeNode, startHidden: true, isRoyalSpeaker: character!.royal, speaker: speaker, shortName: lineCharacter, speakerImage: character!.model, imageRotation: 0.0, speakerAreaNode: speakerAreaNode, scale: scale, positionScale: positionScale, position: -(self.scene!.frame.height / 2.0)))
                        } else {
                            characters.append(CharacterLogic(gameLogic: gameLogic, shakeNode: shakeNode, startHidden: startHidden, isRoyalSpeaker: false, speaker: speaker, shortName: lineCharacter, speakerImage: nil, imageRotation: 0.0, speakerAreaNode: speakerAreaNode, scale: scale, positionScale: positionScale, position: -(self.scene!.frame.height / 2.0)))
                        }
                    }
                }
            }
        }
        
        characterNodes.removeAllChildren()
        for character in characters {
            characterNodes.addChild(character)
        }
        
        if (shakeNode.childNode(withName: "//CharacterNodes") == nil) {
            characterNodes.name = "CharacterNodes"
            characterNodes.position.x = 0
            characterNodes.position.y = 0
            shakeNode.addChild(characterNodes)
        }
        
		let disableOffset = storyImageNode?.userData?["disableOffset"] as? Bool
		if (disableOffset == nil || disableOffset! == false) {
            let imageOffset = (data as! StoryScene).Offset
			if (imageOffset != nil) {
				storyImageNode?.position = CGPoint(x: CGFloat(imageOffset!) * storyImageNode!.xScale, y: 0)
			} else {
				storyImageNode?.position = CGPoint(x: 0, y: 0)
			}
		}
		
		let textArea = shakeNode.childNode(withName: "//TextArea") as? SKSpriteNode
        var theme = (data as! StoryScene).Theme
		if (theme == nil) {
			theme = "Theme1"
		}
		let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		let themeColor = textArea?.userData?[theme as Any] as? String
		if (themeColor != nil) {
			if (themeColor! == "White") {
				textArea?.color = UIColor.white
				textNode?.fontColor = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
			} else if (themeColor! == "0058D0") {
				textArea?.color = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
				textNode?.fontColor = UIColor.white
			} else if (themeColor! == "Black") {
				textArea?.color = UIColor.black
				textNode?.fontColor = UIColor.white
			}
		}
	}
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        for character in characters {
            if (character == self.character) {
                character.update(currentTime, animatingText: animatingText || character != self.character, textSpeechPause: textSpeechPause || character != self.character)
            } else {
                character.update(currentTime, animatingText: false, textSpeechPause: true)
            }
        }
    }
	
	override func readyForNextAction(currentTime: TimeInterval, delay: Double) -> Bool {
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		return super.readyForNextAction(currentTime: currentTime, delay: delay) && !speakerImageNode!.hasActions()
	}
    
    override func processText(line: TextLine) {
        super.processText(line: line)
        
        var currentCharacter = character
        if let lineCharacter = line.character {
            currentCharacter = characters.first(where: { $0.shortName == lineCharacter })
            character = currentCharacter
        }
        
        if (currentCharacter != nil) {
            let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
            let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
            let speakerAreaRoyal = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as! SKSpriteNode
            let speakerArea = shakeNode.childNode(withName: "//SpeakerArea") as! SKSpriteNode
            if (currentCharacter!.isRoyalSpeaker) {
                speakerRoyalLabel.text = currentCharacter?.speaker
                speakerRoyalLabel.isHidden = false
                speakerLabel.isHidden = true
                speakerAreaRoyal.isHidden = false
                speakerArea.isHidden = true
            } else {
                speakerLabel.text = currentCharacter?.speaker
                speakerRoyalLabel.isHidden = true
                speakerLabel.isHidden = false
                speakerAreaRoyal.isHidden = true
                speakerArea.isHidden = false
            }
            currentCharacter?.show()
        }
    }
    
	override func processTextCommand(command: TextLine) {
		super.processTextCommand(command: command)
        
        var speaker = character
        if let lineCharacter = command.character {
            speaker = characters.first(where: { $0.shortName == lineCharacter })
        }
        
        if (speaker != nil) {
            var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
            
            if (speaker?.isRoyalSpeaker ?? false) {
                speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
            }
            speaker?.processTextCommand(command: command, speakerAreaNode: speakerAreaNode!)
        }
        
        let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		
		if (command.textString == "[jump]") {
		} else if (command.textString == "[enterleft]") {
		} else if (command.textString == "[enterright]") {
		} else if (command.textString == "[fadeout]") {
			textNode?.run(SKAction.fadeOut(withDuration: 0.7))
        } else if (command.textString == "[shake]") {
            textNode?.run(SKAction.sequence([SKAction.moveBy(x: 10, y: 0, duration: 0.1), SKAction.moveBy(x: -20, y: 0, duration: 0.1),SKAction.moveBy(x: 10, y: 0, duration: 0.1)]))
        } else if (command.textString == "[bounce]") {
            textNode?.run(SKAction.sequence([SKAction.moveBy(x: 0, y: 10, duration: 0.1), SKAction.moveBy(x: 0, y: -20, duration: 0.1),SKAction.moveBy(x: 0, y: 10, duration: 0.1)]))
        }
	}
}
