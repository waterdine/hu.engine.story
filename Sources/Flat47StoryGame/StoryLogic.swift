//
//  StoryState.swift
//  Flat47StoryGame iOS
//
//  Created by A. A. Bills on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class StoryLogic: CutSceneLogic {
	
	var originalSpeakerY: CGFloat? = nil
    //var characters: [CharacterLogic] = []
    var character: CharacterLogic? = nil
	
	override class func newScene(gameLogic: GameLogic) -> StoryLogic {
		guard let scene = StoryLogic(fileNamed: "Story" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Story.sks")
			abort()
		}
 
		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.stickyText = false
		scene.requiresMusic = true
        let fontSizeScale: CGFloat = CGFloat(Float.init(Bundle.main.localizedString(forKey: "CharacterFontScale", value: nil, table: "Story"))!)
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
        
        character = CharacterLogic(gameLogic: gameLogic, shakeNode: shakeNode, startHidden: startHidden, data: data!)
        
		let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
		let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
        let font = Bundle.main.localizedString(forKey: "CharacterFontName", value: nil, table: "Story")
        if (character!.isRoyalSpeaker) {
            speakerRoyalLabel.text = character!.speaker
            speakerRoyalLabel.fontName = font
			speakerRoyalLabel.isHidden = false
			speakerLabel.isHidden = true
		} else {
            speakerLabel.text = character!.speaker
            speakerLabel.fontName = font
			speakerRoyalLabel.isHidden = true
			speakerLabel.isHidden = false
		}
		
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		
		if (originalSpeakerY != nil) {
			speakerImageNode?.position.y = originalSpeakerY!
			originalSpeakerY = nil
		}
		
        let imageRotation = (data as! StoryScene).Rotation
		if (imageRotation != nil) {
			speakerImageNode?.zRotation = CGFloat((Double(imageRotation!) / 180.0) * Double.pi)
			originalSpeakerY = speakerImageNode?.position.y
			speakerImageNode?.position.y = self.frame.maxY - (speakerImageNode?.size.height)! / 2.0
		} else {
			speakerImageNode?.zRotation = 0.0
		}
			
		let storyImageNode = self.childNode(withName: "//StoryImage")
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
        if (character != nil) {
            character!.update(currentTime, animatingText: animatingText)
        }
    }
	
	override func readyForNextAction(currentTime: TimeInterval, delay: Double) -> Bool {
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		return super.readyForNextAction(currentTime: currentTime, delay: delay) && !speakerImageNode!.hasActions()
	}
	
	override func processTextCommand(command: String) {
		super.processTextCommand(command: command)
        
        if (character != nil) {
            var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
            
            if (character!.isRoyalSpeaker) {
                speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
            }
            character?.processTextCommand(command: command, speakerAreaNode: speakerAreaNode!)
        }
        
        let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		
		if (command == "[jump]") {
		} else if (command == "[enterleft]") {
		} else if (command == "[enterright]") {
		} else if (command == "[fadeout]") {
			textNode?.run(SKAction.fadeOut(withDuration: 0.7))
		}
	}
}
