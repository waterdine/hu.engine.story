//
//  FinalChoiceState.swift
//  Flat47StoryGame iOS
//
//  Created by A. A. Bills on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class ChoiceLogic: GameScene {
	
	var choice1Node: SKSpriteNode?
	var choice2Node: SKSpriteNode?
	var choice3Node: SKSpriteNode?
	var choice4Node: SKSpriteNode?
	
	class func newScene(gameLogic: GameLogic) -> ChoiceLogic {
		guard let scene = ChoiceLogic(fileNamed: "Choice" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Choice.sks")
			abort()
		}

		scene.scaleMode = gameLogic.getScaleMode()
		scene.gameLogic = gameLogic
		scene.requiresMusic = true
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		choice1Node = self.childNode(withName: "//Choice1") as? SKSpriteNode
		choice2Node = self.childNode(withName: "//Choice2") as? SKSpriteNode
		choice3Node = self.childNode(withName: "//Choice3") as? SKSpriteNode
		choice4Node = self.childNode(withName: "//Choice4") as? SKSpriteNode
		
		let hideOnFlags = self.data?["HideOnFlag"] as? [String]
		let directionLabel = self.childNode(withName: "//DirectingLabel") as? SKLabelNode
		directionLabel!.text = Bundle.main.localizedString(forKey: (self.data?["DirectingText"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
				
		let choice1Label = self.childNode(withName: "//Choice1Label") as? SKLabelNode
		choice1Label!.text = Bundle.main.localizedString(forKey: (self.data?["Choice1Text"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
		choice1Label!.text = self.gameLogic!.unwrapVariables(text: choice1Label!.text!)
		if (choice3Node != nil) {
			choice1Node?.size.height = max(choice3Node!.frame.height, choice1Label!.frame.height)
		}
		choice1Node?.isHidden = (hideOnFlags == nil || hideOnFlags![0] == "" || !self.gameLogic!.flags.contains(hideOnFlags![0])) ? false : true
		
		let choice2Label = self.childNode(withName: "//Choice2Label") as? SKLabelNode
		if (self.data?["Choice2Text"] != nil) {
			choice2Label!.text = Bundle.main.localizedString(forKey: (self.data?["Choice2Text"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
			choice2Label!.text = self.gameLogic!.unwrapVariables(text: choice2Label!.text!)
			choice2Node?.isHidden = (hideOnFlags == nil || hideOnFlags![1] == "" || !self.gameLogic!.flags.contains(hideOnFlags![1])) ? false : true
		} else {
			choice2Label?.text = ""
			choice2Node?.isHidden = true
		}
		if (choice3Node != nil) {
			choice2Node?.size.height = max(choice3Node!.frame.height, choice2Label!.frame.height)
			choice2Node?.position.y = (choice1Node?.position.y)! - (choice1Node?.frame.height)! * 1.2
		}
		
		let choice3Label = self.childNode(withName: "//Choice3Label") as? SKLabelNode
		if (self.data?["Choice3Text"] != nil) {
			choice3Label!.text = Bundle.main.localizedString(forKey: (self.data?["Choice3Text"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
			choice3Label!.text = self.gameLogic!.unwrapVariables(text: choice3Label!.text!)
			choice3Node?.isHidden = (hideOnFlags == nil || hideOnFlags![2] == "" || !self.gameLogic!.flags.contains(hideOnFlags![2])) ? false : true
		} else {
			choice3Label?.text = ""
			choice3Node?.isHidden = true
		}
		
		let choice4Label = self.childNode(withName: "//Choice4Label") as? SKLabelNode
		if (self.data?["Choice4Text"] != nil) {
			choice4Label!.text = Bundle.main.localizedString(forKey: (self.data?["Choice4Text"] as! String), value: nil, table: self.gameLogic!.getChapterTable())
			choice4Label!.text = self.gameLogic!.unwrapVariables(text: choice4Label!.text!)
			choice4Node?.isHidden = (hideOnFlags == nil || hideOnFlags![3] == "" || !self.gameLogic!.flags.contains(hideOnFlags![3])) ? false : true
		} else {
			choice4Label?.text = ""
			choice4Node?.isHidden = true
		}
		
		let storyImage = self.childNode(withName: "//StoryImage") as? SKSpriteNode
		let image: String = self.data?["Image"] as! String
		let imagePath = Bundle.main.path(forResource: image, ofType: ".png")
		if (imagePath != nil) {
			storyImage?.isHidden = false
			storyImage?.texture = SKTexture(imageNamed: imagePath!)
		} else {
			storyImage?.isHidden = true
		}
	}
	
	override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (super.handleToolbar(point)) {
			gameMenu?.isHidden = false
			return
		}
	   
		if (gameMenu?.isHidden == false) {
			gameMenu?.interactionEnded(point, timestamp: timestamp)
			return
		}
		
		let flag: String? = self.data?["Flag"] as? String
		let variableToSet = self.data?["VariableToSet"] as? String
		let variables = self.data?["Variables"] as? [String]
		if (choice1Node != nil && !choice1Node!.isHidden && choice1Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = Bundle.main.localizedString(forKey: variables![0], value: nil, table: self.gameLogic!.getChapterTable())
			}
			self.gameLogic?.nextScene()
			if (flag != nil) {
				self.gameLogic?.flags.append(flag!)
			}
		} else if (choice2Node != nil && !choice2Node!.isHidden && choice2Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = Bundle.main.localizedString(forKey: variables![1], value: nil, table: self.gameLogic!.getChapterTable())
			}
			let skipToSceneList = self.data?["SkipTo"] as? [Int]
			if (skipToSceneList != nil) {
				self.gameLogic?.setScene(index: skipToSceneList![0])
			} else {
				self.gameLogic?.setScene(index: self.data?["SkipTo"] as! Int)
			}
			if (flag != nil) {
				self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
			}
		} else if (choice3Node != nil && !choice3Node!.isHidden && choice3Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = Bundle.main.localizedString(forKey: variables![2], value: nil, table: self.gameLogic!.getChapterTable())
			}
			let skipToSceneList = self.data?["SkipTo"] as! [Int]
			self.gameLogic?.setScene(index: skipToSceneList[1])
			if (flag != nil) {
				self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
			}
		} else if (choice4Node != nil && !choice4Node!.isHidden && choice4Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = Bundle.main.localizedString(forKey: variables![3], value: nil, table: self.gameLogic!.getChapterTable())
			}
			let skipToSceneList = self.data?["SkipTo"] as! [Int]
			self.gameLogic?.setScene(index: skipToSceneList[2])
			if (flag != nil) {
				self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
			}
		}
	}
}
