//
//  ChapterChangeState.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class ChapterTransitionLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> ChapterTransitionLogic {
        let scene: ChapterTransitionLogic = gameLogic.loadScene(scene: "Default.ChapterTransition", classType: ChapterTransitionLogic.classForKeyedUnarchiver()) as! ChapterTransitionLogic

		scene.defaultTransition = true
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		let horizontalNumberLabel = self.childNode(withName: "//HorizontalNumber") as? SKLabelNode
        horizontalNumberLabel?.text = gameLogic!.localizedString(forKey: (data as! ChapterTransitionScene).HorizontalNumber, value: nil, table: self.gameLogic!.getChapterTable())
		let horizontalTitleLabel = self.childNode(withName: "//HorizontalTitle") as? SKLabelNode
		horizontalTitleLabel?.text = gameLogic!.localizedString(forKey: (data as! ChapterTransitionScene).HorizontalTitle, value: nil, table: self.gameLogic!.getChapterTable())
		let verticalNumberLabel = self.childNode(withName: "//VerticalNumber") as? SKLabelNode
		if ((data as! ChapterTransitionScene).VerticalNumber != nil) {
			verticalNumberLabel?.text = gameLogic!.localizedString(forKey: (data as! ChapterTransitionScene).VerticalNumber!, value: nil, table: self.gameLogic!.getChapterTable())
		}
		let verticalTitleLabel = self.childNode(withName: "//VerticalTitle") as? SKLabelNode
		if ((data as! ChapterTransitionScene).VerticalTitle != nil) {
			verticalTitleLabel?.text = gameLogic!.localizedString(forKey: (data as! ChapterTransitionScene).VerticalTitle!, value: nil, table: self.gameLogic!.getChapterTable())
		}
        let showPressToContinue = (data as! ChapterTransitionScene).ShowPressToContinue
		let pressNode = self.childNode(withName: "//Press") as? SKLabelNode
		pressNode?.isHidden = (showPressToContinue == nil || showPressToContinue! == false)
        pressNode?.text = gameLogic!.localizedString(forKey: "Press to continue...", value: nil, table: "Story")
	}
}
