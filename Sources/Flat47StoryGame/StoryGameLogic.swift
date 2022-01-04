//
//  File.swift
//  
//
//  Created by A. A. Bills on 17/06/2021.
//

import Foundation
import Flat47Game

// This is a free function because OOP sucks monkey ass and I am not perpetuating that BS any longer ^_^/
@available(OSX 10.13, *)
@available(iOS 9.0, *)
public func RegisterStoryGameScenes(gameLogic: GameLogic) {
	//RegisterGameLogicScenes()
	gameLogic.sceneTypes["Choice"] = ChoiceLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["RandomChoice"] = RandomChoiceLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["CutScene"] = CutSceneLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["TempCutScene"] = CutSceneLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["ChapterTransition"] = ChapterTransitionLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["Story"] = StoryLogic.newScene(gameLogic: gameLogic)
    gameLogic.sceneTypes["CharacterChoice"] = CharacterChoiceLogic.newScene(gameLogic: gameLogic)
}
/*
public func RegisterStoryGameScenes(parser: SceneParser) {
    
}
*/
