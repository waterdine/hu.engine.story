//
//  File.swift
//  
//
//  Created by Sen on 05/01/2022.
//

import Foundation
import Flat47Game

class StoryGameSceneSerialiser: BaseSceneSerialiser {
    public override init() {
        super.init()
    }

    open override func create(from scriptParameters: [String : String], strings: inout [String : String]) -> BaseScene? {
        return nil
    }

    open override func decode(from scriptParameters: [String : String], strings: inout [String : String]) throws {
    }

    open override func decode(from decoder: Decoder, scene: BaseScene) throws {
    }

    open override func encode(to encoder: Encoder, scene: BaseScene) throws {
        switch scene.Scene {
        case "Story":
            try (scene as! StoryScene).encode(to: encoder)
            break
        case "CutScene":
            try (scene as! CutSceneScene).encode(to: encoder)
            break
        case "Choice":
            try (scene as! ChoiceScene).encode(to: encoder)
            break
        case "ChapterTransition":
            try (scene as! ChapterTransitionScene).encode(to: encoder)
            break
        default:
            break
        }
    }

    open override func update(scene: BaseScene) -> BaseScene? {
        var newData: BaseScene? = nil
        switch scene.Scene {
        case "Story":
            if (!(scene is StoryScene)) {
                newData = StoryScene()
            }
            break
        case "CutScene":
            if (!(scene is CutSceneScene)) {
                newData = CutSceneScene()
            }
            break
        case "Choice":
            if (!(scene is ChoiceScene)) {
                newData = ChoiceScene()
            }
            break
        case "ChapterTransition":
            if (!(scene is ChapterTransitionScene)) {
                newData = ChapterTransitionScene()
            }
            break
        default:
            break
        }
        return newData
    }
        
    open override func getDescription(scene: BaseScene) -> String {
        switch scene.Scene {
            case "Story":
                return (scene as! StoryScene).getDescription()
            case "CutScene":
                return (scene as! CutSceneScene).getDescription()
            case "Choice":
                return (scene as! ChoiceScene).getDescription()
            case "ChapterTransition":
                return (scene as! ChapterTransitionScene).getDescription()
            default:
                return ""
        }
    }

    open override func toStringsHeader(scene: BaseScene, index: Int, strings: [String : String]) -> String {
        return ""
    }

    open override func toScriptHeader(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return ""
    }

    open override func toStringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        return []
    }

    open override func toScriptLines(scene: BaseScene, index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        return []
    }
}
