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
    var timeoutTime: TimeInterval? = nil
	
	class func newScene(gameLogic: GameLogic) -> ChoiceLogic {
        let scene: ChoiceLogic = gameLogic.loadScene(scene: "Default.Choice", classType: ChoiceLogic.classForKeyedUnarchiver()) as! ChoiceLogic

		scene.requiresMusic = true
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
        for index in 0 ... 10 {
            let spriteNode = self.childNode(withName: "//Choice\(index)") as? SKSpriteNode
            let labelNode = self.childNode(withName: "//Choice\(index)Label") as? SKLabelNode
            if (spriteNode != nil && labelNode != nil) {
                choiceNodes.append(spriteNode!)
                choiceLabels.append(labelNode!)
            }
        }
		
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
                choiceNode.isHidden = (choice.HideOnFlag == nil || choice.HideOnFlag! == "" || !self.gameLogic!.gameState.flags.contains(choice.HideOnFlag!)) ? false : true
            }
        }
		/*
		if (choice3Node != nil) {
			choice2Node?.size.height = max(choice3Node!.frame.height, choice2Label!.frame.height)
			choice2Node?.position.y = (choice1Node?.position.y)! - (choice1Node?.frame.height)! * 1.2
		}*/
        
		let storyImage = self.childNode(withName: "//StoryImage") as? SKSpriteNode
        let image: String = (data as! ChoiceScene).Image
        let imageUrl = gameLogic?.loadUrl(forResource: image, withExtension: ".png", subdirectory: "Images/Backgrounds")
		if (imageUrl != nil) {
			storyImage?.isHidden = false
            storyImage?.texture = SKTexture(imageNamed: imageUrl!.path)
		} else {
			storyImage?.isHidden = true
		}
	}
	
    // updatefunction with timeout/autopick
    override func update(_ currentTime: TimeInterval) {
        if ((data as! ChoiceScene).Timeout != nil || (data as! ChoiceScene).Timeout! > 0) {
            timeoutTime = currentTime + Double((data as! ChoiceScene).Timeout!)
        }
        if (timeoutTime != nil && currentTime >= timeoutTime!) {
            if ((data as! ChoiceScene).DefaultChoice != nil) {
                let choice = (data as! ChoiceScene).Choices?[(data as! ChoiceScene).DefaultChoice!]
                if (choice!.SkipTo != nil) {
                    self.gameLogic?.setScene(sceneIndex: choice!.SkipTo!, script: nil)
                }
            } else {
                self.gameLogic?.nextScene()
            }
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
		
        let flag: String? = (data as! ChoiceScene).Flag
        let variableToSet = (data as! ChoiceScene).VariableToSet
        for (index, choice) in (data as! ChoiceScene).Choices!.enumerated() {
            if (choiceNodes.count > index) {
                let choiceNode = choiceNodes[index]
                if (!choiceNode.isHidden && choiceNode.frame.contains(point)) {
                    if (variableToSet != nil) {
                        self.gameLogic?.gameState.variables[variableToSet!] = gameLogic!.localizedString(forKey: choice.Text, value: nil, table: self.gameLogic!.getChapterTable())
                    }
                    if (choice.SkipTo != nil) {
                        self.gameLogic?.setScene(sceneIndex: choice.SkipTo!, script: nil)
                    } else {
                        self.gameLogic?.nextScene()
                    }
                    if (flag != nil) {
                        if (index == 0) {
                            self.gameLogic?.gameState.flags.append(flag!)
                        } else {
                            self.gameLogic?.gameState.flags.removeAll(where: { $0 == (flag!) })
                        }
                    }
                    if (choice.Flag != nil) {
                        self.gameLogic?.gameState.flags.append(choice.Flag!)
                    }
                }
            }
        }
	}
}
