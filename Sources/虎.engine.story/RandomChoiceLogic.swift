//
//  File.swift
//  
//
//  Created by ito.antonia on 17/06/2021.
//

import AVKit
import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class RandomChoiceLogic: GameScene {
	
	class func newScene(gameLogic: GameLogic) -> ChoiceLogic {
        let scene: ChoiceLogic = gameLogic.loadScene(scene: "Default.Choice", resourceBundle: "虎.engine.story", classType: ChoiceLogic.classForKeyedUnarchiver()) as! ChoiceLogic

		return scene
	}
}

/*switch
case "RandomChoice":
	let variableName: String = sceneData?["VariableToSet"] as! String
	let possibleFlags: [String] = sceneData?["Flags"] as! [String]
	let variableTextLookups: [String] = sceneData?["VariableText"] as! [String]
	let index = Int.random(in: 0 ... possibleFlags.count - 1)
	
	let variableText = gameLogic!.localizedString(forKey: variableTextLookups[index], value: nil, table: getChapterTable())
	variables[variableName] = variableText
	flags.append(possibleFlags[index])
	
	setScene(index: self.currentSceneIndex! + 1)
	return
}*/
