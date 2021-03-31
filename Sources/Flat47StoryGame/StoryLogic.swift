//
//  StoryState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import GameplayKit
import Flat47Game

@available(iOS 11.0, *)
class StoryLogic: CutSceneLogic {
	
	override class func newScene(gameLogic: GameLogic) -> StoryLogic {
		guard let scene = StoryLogic(fileNamed: "Story" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Story.sks")
			abort()
		}
 
		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic;
		scene.stickyText = false;
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
		speakerLabel.text = self.data?["Speaker"] as? String
		
		let speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
		let speakerImage: String? = self.data?["SpeakerImage"] as? String
		if (speakerImage != nil) {
			let speakerimagePath: String? = Bundle.main.path(forResource: speakerImage, ofType: ".png")
			if (speakerimagePath != nil) {
				speakerImageNode?.isHidden = false
				speakerImageNode?.texture = SKTexture(imageNamed: speakerimagePath!)
				speakerImageNode?.size = CGSize(width: (speakerImageNode?.texture?.size())!.width * 0.2, height: (speakerImageNode?.texture?.size())!.height * 0.2)
				speakerImageNode?.alpha = 1.0
			} else {
				speakerImageNode?.isHidden = true
			}
		} else {
			speakerImageNode?.isHidden = true
		}
		
		let textArea = shakeNode.childNode(withName: "//TextArea") as? SKSpriteNode
		var theme = self.data?["Theme"] as? String
		if (theme == nil) {
			theme = "Theme1"
		}
		let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
		let themeColor = textArea!.userData![theme as Any] as! String
		if (themeColor == "White") {
			textArea?.color = UIColor.white
			textNode?.fontColor = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
		} else if (themeColor == "0058D0") {
			textArea?.color = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
			textNode?.fontColor = UIColor.white
		} else if (themeColor == "Black") {
			textArea?.color = UIColor.black
			textNode?.fontColor = UIColor.white
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
		let halfWidth = (speakerImageNode?.frame.width)! / 2.0
		if (command == "[jump]") {
			speakerImageNode?.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1), SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1)]))
		} else if (command == "[enterleft]") {
			speakerImageNode?.position = CGPoint(x: self.frame.minX - halfWidth, y: (speakerImageNode?.position.y)!)
			speakerImageNode?.run(SKAction.moveBy(x: (speakerImageNode?.frame.width)!, y: 0.0, duration: 0.7))
		} else if (command == "[enterright]") {
			speakerImageNode?.position = CGPoint(x: self.frame.maxX + halfWidth, y: (speakerImageNode?.position.y)!)
			speakerImageNode?.run(SKAction.moveBy(x: -(speakerImageNode?.frame.width)!, y: 0.0, duration: 0.7))
		} else if (command == "[fadeout]") {
			speakerImageNode?.run(SKAction.fadeOut(withDuration: 0.7))
			textNode?.run(SKAction.fadeOut(withDuration: 0.7))
		}
	}
}
