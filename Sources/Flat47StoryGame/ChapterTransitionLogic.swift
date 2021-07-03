//
//  ChapterChangeState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.12, *)
@available(iOS 11.0, *)
class ChapterTransitionLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> ChapterTransitionLogic {
		guard let scene = ChapterTransitionLogic(fileNamed: "ChapterTransition" + gameLogic.getAspectSuffix()) else {
			print("Failed to load ChapterTransition.sks")
			abort()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.defaultTransition = true
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let horizontalNumberLabel = self.childNode(withName: "//HorizontalNumber") as? SKLabelNode
		horizontalNumberLabel?.text = Bundle.main.localizedString(forKey: (self.data?["HorizontalNumber"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
		let horizontalTitleLabel = self.childNode(withName: "//HorizontalTitle") as? SKLabelNode
		horizontalTitleLabel?.text = Bundle.main.localizedString(forKey: (self.data?["HorizontalTitle"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
		let verticalNumberLabel = self.childNode(withName: "//VerticalNumber") as? SKLabelNode
		if (self.data?["VerticalNumber"] != nil) {
			verticalNumberLabel?.text = Bundle.main.localizedString(forKey: (self.data?["VerticalNumber"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
		}
		let verticalTitleLabel = self.childNode(withName: "//VerticalTitle") as? SKLabelNode
		if (self.data?["VerticalTitle"] != nil) {
			verticalTitleLabel?.text = Bundle.main.localizedString(forKey: (self.data?["VerticalTitle"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
		}
		let showPressToContinue = self.data?["ShowPressToContinue"] as? Bool
		let pressNode = self.childNode(withName: "//Press")
		pressNode?.isHidden = (showPressToContinue == nil || showPressToContinue! == false)
	}
}
