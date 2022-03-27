//
//  StorySceneSerialisers.swift
//  
//
//  Created by ito.antonia on 05/01/2022.
//

import Foundation
import 虎_engine_base

class StoryGameSceneSerialiser: BaseSceneSerialiser {
    public override init() {
        super.init()
    }

    open override func decode(from scriptParameters: [String : String], sceneType: String, strings: inout [String : String]) -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
            case "Story":
                scene = StoryScene.init(from: scriptParameters, strings: &strings)
                break
            case "CutScene":
                scene = CutSceneScene.init(from: scriptParameters, strings: &strings)
                break
            case "Choice":
                scene = ChoiceScene.init(from: scriptParameters, strings: &strings)
                break
            case "ChapterTransition":
                scene = ChapterTransitionScene.init(from: scriptParameters, strings: &strings)
                break
            default:
                break
        }
        return scene
    }

    open override func decode(from decoder: Decoder, sceneType: String) throws -> BaseScene? {
        var scene: BaseScene? = nil
        switch sceneType {
        case "Story":
            scene = try StoryScene.init(from: decoder)
            break
        case "CutScene":
            scene = try CutSceneScene.init(from: decoder)
            break
        case "Choice":
            scene = try ChoiceScene.init(from: decoder)
            break
        case "ChapterTransition":
            scene = try ChapterTransitionScene.init(from: decoder)
            break
        default:
            break
        }
        return scene
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
    
    open override func appendText(scene: BaseScene, text: String, textBucket: String, scriptNumber: String, sceneNumber: String, lineIndex: Int, strings: inout [String : String], command: Bool, sceneLabelMap: inout [String : Int]) {
        let line: TextLine = TextLine()
        line.textString = text
        if (textBucket.isEmpty) {
            let lineString = "line_\(lineIndex)"
            let lineReference = scriptNumber + "_" + sceneNumber + "_" + lineString
            switch scene.Scene {
            case "Story":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (scene as! StoryScene).Text.append(line)
                break
            case "CutScene":
                if (!command) {
                    strings[lineReference] = String(text)
                    line.textString = lineReference
                }
                (scene as! CutSceneScene).Text.append(line)
                break
            case "Choice":
                if (text.starts(with: "DirectingText")) {
                    (scene as! ChoiceScene).DirectingText = scriptNumber + "_" + sceneNumber + "_direction"
                    strings[(scene as! ChoiceScene).DirectingText] = text.replacingOccurrences(of: "DirectingText: ", with: "")
                } else if (text.starts(with: "Choice")) {
                    let choiceSplit = text.replacingOccurrences(of: "//", with: "±").split(separator: "±")
                    let choiceTextSplit = choiceSplit[0].split(separator: ":")
                    let choiceNumber: String = String(choiceTextSplit[0]).replacingOccurrences(of: "Text", with: "").replacingOccurrences(of: "Choice", with: "").trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    let choiceText: String = String(choiceTextSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":", "/"])
                    var choiceParameters: [String : String] = ["Text" : choiceText]
                    choiceParameters["Choice"] = choiceNumber
                    if (choiceSplit.count > 1) {
                        let choiceParameterSplit = choiceSplit[1].split(separator: ",")
                        for parameterCombined in choiceParameterSplit {
                            if (!parameterCombined.starts(with: "Choice")) {
                                let parameterSplit = parameterCombined.split(separator: ":")
                                let parameter = String(parameterSplit[0]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                let value = String(parameterSplit[1]).trimmingCharacters(in: [" ", "-", ",", ":"])
                                choiceParameters[parameter] = value
                            }
                        }
                    }
                    
                    // Map the SkipTos to SceneLabels
                    if (choiceParameters["SkipTo"] != nil) {
                        var newSkipTo = ""
                        for skipToUntrimmed in choiceParameters["SkipTo"]!.split(separator: ";") {
                            let skipToTrimmed = skipToUntrimmed.trimmingCharacters(in: [" ", ",", ";"])
                            var skipToNumber = Int(skipToTrimmed)
                            if (skipToNumber == nil) {
                                if (sceneLabelMap[skipToTrimmed] == nil) {
                                    let newIndex = -(sceneLabelMap.count + 1)
                                    sceneLabelMap[skipToTrimmed] = newIndex
                                    skipToNumber = newIndex
                                } else {
                                    skipToNumber = sceneLabelMap[skipToTrimmed]!
                                }
                            }
                            
                            if (!newSkipTo.isEmpty) {
                                newSkipTo += ";"
                            }
                            
                            newSkipTo += "\(skipToNumber!)"
                        }
                        choiceParameters["SkipTo"] = newSkipTo
                    }
                    
                    choiceParameters["Chapter"] = scriptNumber
                    choiceParameters["SceneNumber"] = sceneNumber
                    let choice = Choice.init(from: choiceParameters, strings: &strings)
                    let choiceIndex = Int(choiceNumber)!
                    // atode: Check choiceIndex > 0 and handle it otherwise
                    if ((scene as! ChoiceScene).Choices == nil) {
                        (scene as! ChoiceScene).Choices = []
                    }
                    
                    for _ in (scene as! ChoiceScene).Choices!.count..<choiceIndex {
                        (scene as! ChoiceScene).Choices!.append(Choice())
                    }
                    (scene as! ChoiceScene).Choices?[choiceIndex - 1] = choice
                }
            case "ChapterTransition":
                if (text.starts(with: "HorizontalNumber")) {
                    (scene as! ChapterTransitionScene).HorizontalNumber = scriptNumber + "_horizontal_number"
                    strings[(scene as! ChapterTransitionScene).HorizontalNumber] = text.replacingOccurrences(of: "HorizontalNumber: ", with: "")
                } else if (text.starts(with: "HorizontalTitle")) {
                    (scene as! ChapterTransitionScene).HorizontalTitle = scriptNumber + "_horizontal_title"
                    strings[(scene as! ChapterTransitionScene).HorizontalTitle] = text.replacingOccurrences(of: "HorizontalTitle: ", with: "")
                } else if (text.starts(with: "VerticalNumber")) {
                    (scene as! ChapterTransitionScene).VerticalNumber = scriptNumber + "_vertical_number"
                    strings[(scene as! ChapterTransitionScene).VerticalNumber!] = text.replacingOccurrences(of: "VerticalNumber: ", with: "")
                } else if (text.starts(with: "VerticalTitle")) {
                    (scene as! ChapterTransitionScene).VerticalTitle = scriptNumber + "_vertical_title"
                    strings[(scene as! ChapterTransitionScene).VerticalTitle!] = text.replacingOccurrences(of: "VerticalTitle: ", with: "")
                }
            default: break
            }
        }
    }
             
    open override func stringsLines(scene: BaseScene, index: Int, strings: [String : String]) -> [String] {
        var lines: [String] = []
        switch scene.Scene {
            case "Story":
                lines.append(contentsOf: (scene as! StoryScene).toStringsLines(index: index, strings: strings))
                for textLine in (scene as! StoryScene).Text {
                    if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                        lines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                    }
                }
                break
            case "CutScene":
                lines.append(contentsOf: (scene as! CutSceneScene).toStringsLines(index: index, strings: strings))
                for textLine in (scene as! CutSceneScene).Text {
                    if (!textLine.textString.starts(with: "[") && !textLine.textString.isEmpty) {
                        lines.append("\"" + textLine.textString + "\" = \"" + strings[textLine.textString]!.replacingOccurrences(of: "\"", with: "\\\"") + "\";")
                    }
                }
                break
            case "Choice":
                lines.append(contentsOf: (scene as! ChoiceScene).toStringsLines(index: index, strings: strings))
                lines.append("\"" + (scene as! ChoiceScene).DirectingText + "\" = \"" + strings[(scene as! ChoiceScene).DirectingText]! + "\";")
                for choice in (scene as! ChoiceScene).Choices! {
                    lines.append("\"" + choice.Text + "\" = \"" + strings[choice.Text]! + "\";")
                }
                break
            case "ChapterTransition":
                lines.append("/* " + strings[(scene as! ChapterTransitionScene).HorizontalNumber]! + " */\n")
                lines.append(contentsOf: (scene as! ChapterTransitionScene).toStringsLines(index: index, strings: strings))
                lines.append("\"" + (scene as! ChapterTransitionScene).HorizontalNumber + "\" = \"" + strings[(scene as! ChapterTransitionScene).HorizontalNumber]! + "\";")
                lines.append("\"" + (scene as! ChapterTransitionScene).HorizontalTitle + "\" = \"" + strings[(scene as! ChapterTransitionScene).HorizontalTitle]! + "\";")
                if ((scene as! ChapterTransitionScene).VerticalNumber != nil) {
                    lines.append("\"" + (scene as! ChapterTransitionScene).VerticalNumber! + "\" = \"" + strings[(scene as! ChapterTransitionScene).VerticalNumber!]! + "\";")
                }
                if ((scene as! ChapterTransitionScene).VerticalTitle != nil) {
                    lines.append("\"" + (scene as! ChapterTransitionScene).VerticalTitle! + "\" = \"" + strings[(scene as! ChapterTransitionScene).VerticalTitle!]! + "\";")
                }
                break
            default:
                break
        }
        return lines
    }
    
    open override func resolveSkipToIndexes(scene: BaseScene, indexMap: [Int : Int]) {
        switch scene.Scene {
        case "Choice":
            for (index, item) in (scene as! ChoiceScene).Choices!.enumerated() {
                if (item.SkipTo != nil && indexMap[item.SkipTo!] != nil) {
                    (scene as! ChoiceScene).Choices![index].SkipTo = indexMap[item.SkipTo!]!
                }
            }
            break
        default: break
        }
    }
}
