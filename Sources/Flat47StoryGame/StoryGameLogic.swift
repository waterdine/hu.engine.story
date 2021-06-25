//
//  File.swift
//  
//
//  Created by x414e54 on 17/06/2021.
//

import Foundation
import Flat47Game

// This is a free function because OOP sucks monkey ass and I am not perpetuating that BS any longer ^_^/
@available(iOS 11.0, *)
public func RegisterStoryGameScenes(gameLogic: GameLogic) {
	//RegisterGameLogicScenes()
	gameLogic.sceneTypes["Choice"] = ChoiceLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["RandomChoice"] = RandomChoiceLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["CutScene"] = CutSceneLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["TempCutScene"] = CutSceneLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["ChapterTransition"] = ChapterTransitionLogic.newScene(gameLogic: gameLogic)
	gameLogic.sceneTypes["Story"] = StoryLogic.newScene(gameLogic: gameLogic)
}
