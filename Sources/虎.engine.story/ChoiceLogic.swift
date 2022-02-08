//
//  FinalChoiceState.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class ChoiceLogic: GameScene {
	
	var choiceNodes: [SKSpriteNode] = []
    var choiceLabels: [SKLabelNode] = []
	
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
        choiceNodes.append(self.childNode(withName: "//Choice1") as! SKSpriteNode)
        choiceNodes.append(self.childNode(withName: "//Choice2") as! SKSpriteNode)
        choiceNodes.append(self.childNode(withName: "//Choice3") as! SKSpriteNode)
        choiceNodes.append(self.childNode(withName: "//Choice4") as! SKSpriteNode)
        choiceLabels.append(self.childNode(withName: "//Choice1Label") as! SKLabelNode)
        choiceLabels.append(self.childNode(withName: "//Choice2Label") as! SKLabelNode)
        choiceLabels.append(self.childNode(withName: "//Choice3Label") as! SKLabelNode)
        choiceLabels.append(self.childNode(withName: "//Choice4Label") as! SKLabelNode)
		
        //let hideOnFlags = (data as! ChoiceScene).HideOnFlag
		let directionLabel = self.childNode(withName: "//DirectingLabel") as? SKLabelNode
        directionLabel!.text = gameLogic!.localizedString(forKey: (data as! ChoiceScene).DirectingText, value: nil, table: self.gameLogic!.getChapterTable())
        
        for choiceNode in choiceNodes {
            choiceNode.isHidden = true
        }
        
        for choiceLabel in choiceLabels {
            choiceLabel.text = ""
        }
        
        for (index, choice) in (data as! ChoiceScene).Choices!.enumerated() {
            //
            if (choiceLabels.count > index) {
                let choiceLabel = choiceLabels[index]
                let choiceNode = choiceNodes[index]
                choiceLabel.text = gameLogic!.localizedString(forKey: choice.Text, value: nil, table: self.gameLogic!.getChapterTable())
                choiceLabel.text = self.gameLogic!.unwrapVariables(text: choiceLabel.text!)
                /*if (choice3Node != nil) {
                    choiceNode?.size.height = max(choiceNode!.frame.height, choiceLabel!.frame.height)
                }*/
                choiceNode.isHidden = (choice.HideOnFlag == nil || choice.HideOnFlag! == "" || !self.gameLogic!.flags.contains(choice.HideOnFlag!)) ? false : true
            }
        }
		/*
		if (choice3Node != nil) {
			choice2Node?.size.height = max(choice3Node!.frame.height, choice2Label!.frame.height)
			choice2Node?.position.y = (choice1Node?.position.y)! - (choice1Node?.frame.height)! * 1.2
		}*/
		
		let storyImage = self.childNode(withName: "//StoryImage") as? SKSpriteNode
        let image: String = (data as! StoryScene).Image
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
		
        let flag: String? = (data as! StoryScene).Flag
        let variableToSet = (data as! StoryScene).VariableToSet
        for choice in (data as! ChoiceScene).Choices! {
            if (variableToSet != nil) {
                self.gameLogic?.variables[variableToSet!] = gameLogic!.localizedString(forKey: choice.Text, value: nil, table: self.gameLogic!.getChapterTable())
            }
            if (choice.SkipTo != nil) {
                self.gameLogic?.setScene(index: choice.SkipTo!)
            }
            if (flag != nil) {
                self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
            }
        }
		/*if (choice1Node != nil && !choice1Node!.isHidden && choice1Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = gameLogic!.localizedString(forKey: variables![0], value: nil, table: self.gameLogic!.getChapterTable())
			}
			self.gameLogic?.nextScene()
			if (flag != nil) {
				self.gameLogic?.flags.append(flag!)
			}
		} else if (choice2Node != nil && !choice2Node!.isHidden && choice2Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = gameLogic!.localizedString(forKey: variables![1], value: nil, table: self.gameLogic!.getChapterTable())
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
				self.gameLogic?.variables[variableToSet!] = gameLogic!.localizedString(forKey: variables![2], value: nil, table: self.gameLogic!.getChapterTable())
			}
			let skipToSceneList = self.data?["SkipTo"] as! [Int]
			self.gameLogic?.setScene(index: skipToSceneList[1])
			if (flag != nil) {
				self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
			}
		} else if (choice4Node != nil && !choice4Node!.isHidden && choice4Node!.frame.contains(point)) {
			if (variableToSet != nil && variables != nil) {
				self.gameLogic?.variables[variableToSet!] = gameLogic!.localizedString(forKey: variables![3], value: nil, table: self.gameLogic!.getChapterTable())
			}
			let skipToSceneList = self.data?["SkipTo"] as! [Int]
			self.gameLogic?.setScene(index: skipToSceneList[2])
			if (flag != nil) {
				self.gameLogic?.flags.removeAll(where: { $0 == (flag!) })
			}
		}*/
	}
}
