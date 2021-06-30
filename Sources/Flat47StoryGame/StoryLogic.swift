//
//  StoryState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.13, *)
@available(iOS 11.0, *)
class StoryLogic: CutSceneLogic {
	
	var originalSpeakerY: CGFloat? = nil
	
	override class func newScene(gameLogic: GameLogic) -> StoryLogic {
		guard let scene = StoryLogic(fileNamed: "Story" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Story.sks")
			abort()
		}
 
		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic
		scene.stickyText = false
		scene.requiresMusic = true
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
		let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
		let isRoyalSpeaker: Bool? = self.data?["RoyalSpeaker"] as? Bool
		if (isRoyalSpeaker != nil && isRoyalSpeaker!) {
			speakerRoyalLabel.text = self.data?["Speaker"] as? String
			speakerRoyalLabel.isHidden = false
			speakerLabel.isHidden = true
		} else {
			speakerLabel.text = self.data?["Speaker"] as? String
			speakerRoyalLabel.isHidden = true
			speakerLabel.isHidden = false
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
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
		
		let isRoyalSpeaker: Bool? = self.data?["RoyalSpeaker"] as? Bool
		if (isRoyalSpeaker != nil && isRoyalSpeaker!) {
			speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
		}
		
		let halfWidth = (speakerImageNode?.frame.width)! / 2.0
		if (command == "[jump]") {
			speakerImageNode?.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1), SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1)]))
		} else if (command == "[enterleft]") {
			speakerImageNode?.position = CGPoint(x: self.frame.minX - halfWidth, y: (speakerImageNode?.position.y)!)
			speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode?.position.x)!, duration: 0.7))
			speakerImageNode?.isHidden = false
		} else if (command == "[enterright]") {
			speakerImageNode?.position = CGPoint(x: self.frame.maxX + halfWidth, y: (speakerImageNode?.position.y)!)
			speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode?.position.x)!, duration: 0.7))
			speakerImageNode?.isHidden = false
		} else if (command == "[fadeout]") {
			speakerImageNode?.run(SKAction.fadeOut(withDuration: 0.7))
			textNode?.run(SKAction.fadeOut(withDuration: 0.7))
		}
	}
}
