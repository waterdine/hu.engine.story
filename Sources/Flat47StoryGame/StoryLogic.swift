//
//  StoryState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
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
        
        /*for <#item#> in <#items#> {
         characters.append(baseCharacter);
        }*/
		let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
		let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
		let isRoyalSpeaker: Bool? = self.data?["RoyalSpeaker"] as? Bool
        let speaker = Bundle.main.localizedString(forKey: ((self.data?["Speaker"] as? String)!), value: nil, table: "Story")
        let font = Bundle.main.localizedString(forKey: "CharacterFontName", value: nil, table: "Story")
		if (isRoyalSpeaker != nil && isRoyalSpeaker!) {
            speakerRoyalLabel.text = speaker
            speakerRoyalLabel.fontName = font
			speakerRoyalLabel.isHidden = false
			speakerLabel.isHidden = true
		} else {
			speakerLabel.text = speaker
            speakerLabel.fontName = font
			speakerRoyalLabel.isHidden = true
			speakerLabel.isHidden = false
		}
		
		var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
		
		if (isRoyalSpeaker != nil && isRoyalSpeaker!) {
			speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
		}
		
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		let speakerImage: String? = self.data?["SpeakerImage"] as? String
		if (speakerImage != nil) {
			let speakerimagePath: String? = Bundle.main.path(forResource: speakerImage, ofType: ".png")
			if (speakerimagePath != nil) {
				let scale = speakerImageNode?.userData!["scale"] as! CGFloat
				speakerImageNode?.isHidden = false
				speakerImageNode?.texture = SKTexture(imageNamed: speakerimagePath!)
				speakerImageNode?.size = CGSize(width: (speakerImageNode?.texture?.size())!.width * scale, height: (speakerImageNode?.texture?.size())!.height * scale)
				speakerImageNode?.alpha = 1.0
				speakerImageNode?.position.x = speakerAreaNode!.position.x;
			} else {
				speakerImageNode?.isHidden = true
			}
		} else {
			speakerImageNode?.isHidden = true
		}
		
		if (originalSpeakerY != nil) {
			speakerImageNode?.position.y = originalSpeakerY!
			originalSpeakerY = nil
		}
		
		let imageRotation = self.data?["Rotation"] as? Float
		if (imageRotation != nil) {
			speakerImageNode?.zRotation = CGFloat((Double(imageRotation!) / 180.0) * Double.pi)
			originalSpeakerY = speakerImageNode?.position.y
			speakerImageNode?.position.y = self.frame.maxY - (speakerImageNode?.size.height)! / 2.0
		} else {
			speakerImageNode?.zRotation = 0.0
		}
		
		let textList: NSArray? = self.data?["Text"] as? NSArray
		if (textList != nil && textList!.count > 0 && ((textList?[0] as! String) == "[enterleft]" || (textList?[0] as! String) == "[enterright]") ) {
			speakerImageNode?.isHidden = true
		}
			
		let storyImageNode = self.childNode(withName: "//StoryImage")
		let disableOffset = storyImageNode?.userData?["disableOffset"] as? Bool
		if (disableOffset == nil || disableOffset! == false) {
			let imageOffset = self.data?["Offset"] as? Int
			if (imageOffset != nil) {
				storyImageNode?.position = CGPoint(x: CGFloat(imageOffset!) * storyImageNode!.xScale, y: 0)
			} else {
				storyImageNode?.position = CGPoint(x: 0, y: 0)
			}
		}
		
		let textArea = shakeNode.childNode(withName: "//TextArea") as? SKSpriteNode
		var theme = self.data?["Theme"] as? String
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
