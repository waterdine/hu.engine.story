//
//  File.swift
//  
//
//  Created by x414e54 on 17/06/2021.
//

import AVKit
import SpriteKit
import Flat47Game

@available(OSX 10.12, *)
@available(iOS 11.0, *)
class RandomChoiceLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> ChoiceLogic {
		guard let scene = ChoiceLogic(fileNamed: "Choice" + gameLogic.getAspectSuffix()) else {
			print("Failed to load Choice.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic;
		
		return scene
	}
}

/*switch
case "RandomChoice":
	let variableName: String = sceneData?["VariableToSet"] as! String
	let possibleFlags: [String] = sceneData?["Flags"] as! [String]
	let variableTextLookups: [String] = sceneData?["VariableText"] as! [String]
	let index = Int.random(in: 0 ... possibleFlags.count - 1)
	
	let variableText = Bundle.main.localizedString(forKey: variableTextLookups[index], value: nil, table: getChapterTable())
	variables[variableName] = variableText
	flags.append(possibleFlags[index])
	
	setScene(index: self.currentSceneIndex! + 1)
	return
}*/
