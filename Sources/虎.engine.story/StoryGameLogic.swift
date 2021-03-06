//
//  File.swift
//  
//
//  Created by ito.antonia on 17/06/2021.
//

import Foundation
import 虎_engine_base

// This is a free function because OOP is more difficult to keep data structures and logic separate, for GPU like kernels. ^_^/
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

public func RegisterStoryGameSceneInitialisers(sceneListSerialiser: inout SceneListSerialiser) {
    sceneListSerialiser.serialisers.append(StoryGameSceneSerialiser())
}

public func LoadStoryGameModuleResourceBundle(bundles: inout [String:Bundle]) {
    bundles["虎.engine.story"] = Bundle.init(url: Bundle.main.resourceURL!.appendingPathComponent("虎.engine.story_虎.engine.story.bundle"))!
}

public func RegisterStoryGameSettings(settings: inout [String])
{
    settings.append("FontScale");
    settings.append("ButtonFontName");
    settings.append("CharacterFontName");
    settings.append("CharacterFontScale");
}
