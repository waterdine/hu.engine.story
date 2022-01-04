//
//  StoryScenes.swift
//  Shared
//
//  Created by A. A. Bills on 28/07/2021.
//

import Foundation
import Flat47Game

class CutSceneScene: VisualScene {
    var Flag: String? = nil
    var VariableToSet: String? = nil
    var VariableText: String? = nil
    var DisableSpeedText: Bool? = nil
    var SubScene: String? = nil
    var Image: String = ""
    var Scale: String? = nil
    var OffsetX: String? = nil
    var OffsetY: String? = nil
    var Rotation: Float? = nil
    var Text: [TextLine] = []
    
    enum CutSceneCodingKeys: String, CodingKey {
        case Flag
        case VariableToSet
        case VariableText
        case DisableSpeedText
        case SubScene
        case Image
        case Scale
        case OffsetX
        case OffsetY
        case Rotation
        case Text
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["Flag"] != nil) {
            Flag = scriptParameters["Flag"]
        }
        
        if (scriptParameters["DisableSpeedText"] != nil) {
            DisableSpeedText = (scriptParameters["DisableSpeedText"] == "True") ? true : false
        }
        
        if (scriptParameters["VariableToSet"] != nil) {
            VariableToSet = scriptParameters["VariableToSet"]
        }
        
        if (scriptParameters["VariableText"] != nil) {
            VariableText = scriptParameters["VariableText"]
        }
        
        if (scriptParameters["SubScene"] != nil) {
            SubScene = scriptParameters["SubScene"]
        }
        
        if (scriptParameters["Image"] != nil) {
            Image = scriptParameters["Image"]!
        }
        
        if (scriptParameters["Scale"] != nil) {
            Scale = scriptParameters["Scale"]
        }
        
        if (scriptParameters["OffsetX"] != nil) {
            OffsetX = scriptParameters["OffsetX"]
        }
        
        if (scriptParameters["OffsetY"] != nil) {
            OffsetY = scriptParameters["OffsetY"]
        }
        
        if (scriptParameters["Rotation"] != nil) {
            Rotation = Float(scriptParameters["Rotation"]!)!
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CutSceneCodingKeys.self)
        Flag = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.Flag)
        VariableToSet = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.VariableToSet)
        VariableText = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.VariableText)
        DisableSpeedText = try container.decodeIfPresent(Bool.self, forKey: CutSceneCodingKeys.DisableSpeedText)
        SubScene = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.SubScene)
        Image = try container.decode(String.self, forKey: CutSceneCodingKeys.Image)
        Scale = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.Scale)
        OffsetX = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.OffsetX)
        OffsetY = try container.decodeIfPresent(String.self, forKey: CutSceneCodingKeys.OffsetY)
        Rotation = try container.decodeIfPresent(Float.self, forKey: CutSceneCodingKeys.Rotation)
        Text = try container.decode([TextLine].self, forKey: CutSceneCodingKeys.Text)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CutSceneCodingKeys.self)
        try container.encodeIfPresent(Flag, forKey: CutSceneCodingKeys.Flag)
        try container.encodeIfPresent(VariableToSet, forKey: CutSceneCodingKeys.VariableToSet)
        try container.encodeIfPresent(VariableText, forKey: CutSceneCodingKeys.VariableText)
        try container.encodeIfPresent(DisableSpeedText, forKey: CutSceneCodingKeys.DisableSpeedText)
        try container.encodeIfPresent(SubScene, forKey: CutSceneCodingKeys.SubScene)
        try container.encode(Image, forKey: CutSceneCodingKeys.Image)
        try container.encodeIfPresent(Scale, forKey: CutSceneCodingKeys.Scale)
        try container.encodeIfPresent(OffsetX, forKey: CutSceneCodingKeys.OffsetX)
        try container.encodeIfPresent(OffsetY, forKey: CutSceneCodingKeys.OffsetY)
        try container.encodeIfPresent(Rotation, forKey: CutSceneCodingKeys.Rotation)
        try container.encode(Text, forKey: CutSceneCodingKeys.Text)
    }
    
    override func getDescription() -> String {
        return (Transition == nil) ? "CutScene" : "CutScene, \(Transition!)"
    }
    
    func cutSceneScriptLine() -> String {
        var scriptLine: String = ""
        
        if (Flag != nil) {
            scriptLine += ", Flag: " + Flag!
        }
        
        if (VariableToSet != nil) {
            scriptLine += ", VariableToSet: " + VariableToSet!
        }
        
        if (VariableText != nil) {
            scriptLine += ", VariableText: " + VariableText!
        }
        
        if (DisableSpeedText != nil) {
            scriptLine += ", DisableSpeedText: " + ((DisableSpeedText! == true) ? "True" : "False")
        }
        
        if (SubScene != nil) {
            scriptLine += ", SubScene: " + SubScene!
        }
        
        scriptLine += ", Image: " + Image
        
        if (Scale != nil) {
            scriptLine += ", Scale: " + Scale!
        }
        
        if (OffsetX != nil) {
            scriptLine += ", OffsetX: " + OffsetX!
        }
        
        if (OffsetY != nil) {
            scriptLine += ", OffsetY: " + OffsetY!
        }
        
        if (Rotation != nil) {
            scriptLine += ", Rotation: \(Rotation!)"
        }
        
        return scriptLine
    }

    func superScriptLine(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        return super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        scriptLine += cutSceneScriptLine()
        
        return scriptLine
    }

    override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        for textLine in Text {
            if (strings[textLine.textString] == nil) {
                lines.append(textLine.textString)
            } else {
                lines.append(strings[textLine.textString]!)
            }
        }
        
        return lines
    }
}

class StoryScene: CutSceneScene {
    var Speaker: String = ""
    var SpeakerImage: String = ""
    var RoyalSpeaker: Bool? = nil
    var Offset: Int? = nil
    var Theme: String? = nil
    
    enum StoryCodingKeys: String, CodingKey {
        case Speaker
        case SpeakerImage
        case RoyalSpeaker
        case Offset
        case Theme
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["Speaker"] != nil) {
            Speaker = scriptParameters["Speaker"]!
        }
        
        if (scriptParameters["RoyalSpeaker"] != nil) {
            RoyalSpeaker = (scriptParameters["RoyalSpeaker"] == "True") ? true : false
        }
        
        if (scriptParameters["SpeakerImage"] != nil) {
            SpeakerImage = scriptParameters["SpeakerImage"]!
        }
        
        if (scriptParameters["Offset"] != nil) {
            Offset = Int(scriptParameters["Offset"]!)!
        }
        
        if (scriptParameters["Theme"] != nil) {
            Theme = scriptParameters["Theme"]!
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: StoryCodingKeys.self)
        Speaker = try container.decode(String.self, forKey: StoryCodingKeys.Speaker)
        SpeakerImage = try container.decode(String.self, forKey: StoryCodingKeys.SpeakerImage)
        RoyalSpeaker = try container.decodeIfPresent(Bool.self, forKey: StoryCodingKeys.RoyalSpeaker)
        Offset = try container.decodeIfPresent(Int.self, forKey: StoryCodingKeys.Offset)
        Theme = try container.decodeIfPresent(String.self, forKey: StoryCodingKeys.Theme)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: StoryCodingKeys.self)
        try container.encode(Speaker, forKey: StoryCodingKeys.Speaker)
        try container.encode(SpeakerImage, forKey: StoryCodingKeys.SpeakerImage)
        try container.encodeIfPresent(RoyalSpeaker, forKey: StoryCodingKeys.RoyalSpeaker)
        try container.encodeIfPresent(Offset, forKey: StoryCodingKeys.Offset)
        try container.encodeIfPresent(Theme, forKey: StoryCodingKeys.Theme)
    }
    
    override func getDescription() -> String {
        return "Story, \(Speaker)"
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.superScriptLine(index: index, strings: strings, indexMap: indexMap)
        
        scriptLine += ", Speaker: " + Speaker
        
        scriptLine += ", SpeakerImage: " + SpeakerImage
        
        if (RoyalSpeaker != nil) {
            scriptLine += ", RoyalSpeaker: " + ((RoyalSpeaker! == true) ? "True" : "False")
        }
        
        if (Offset != nil) {
            scriptLine += ", Offset: \(Offset!)"
        }
        
        scriptLine += super.cutSceneScriptLine()
        
        return scriptLine
    }
}

open class Choice: Identifiable, Codable {
    public var id: UUID = UUID()
    public var Text: String = ""
    public var SkipTo: Int? = nil
    public var Flag: String? = nil
    public var HideOnFlag: String? = nil
    public var Variable: String? = nil
    public var Break: Bool? = nil
    
    enum ChoiceCodingKeys: String, CodingKey {
        case Text
        case SkipTo
        case Flag
        case HideOnFlag
        case Variable
        case Break
    }

    init() {
    }
    
    init(from choiceParameters: [String : String], strings: inout [String : String]) {
        Text = choiceParameters["Chapter"]! + "_" + choiceParameters["SceneNumber"]! + "_choice_" + choiceParameters["Choice"]!
        strings[Text] = choiceParameters["Text"]!
        
        if (choiceParameters["SkipTo"] != nil) {
            SkipTo = Int(choiceParameters["SkipTo"]!)
        }

        if (choiceParameters["Flag"] != nil) {
            Flag = choiceParameters["Flag"]!
        }
        
        if (choiceParameters["HideOnFlag"] != nil) {
            HideOnFlag = choiceParameters["HideOnFlag"]!
        }
        
        if (choiceParameters["Variable"] != nil) {
            Variable = choiceParameters["Variable"]!
        }
        
        if (choiceParameters["Break"] != nil) {
            Break = (choiceParameters["Break"] == "True") ? true : false
        }
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ChoiceCodingKeys.self)
        Text = try container.decode(String.self, forKey: ChoiceCodingKeys.Text)
        SkipTo = try container.decodeIfPresent(Int.self, forKey: ChoiceCodingKeys.SkipTo)
        Flag = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Flag)
        HideOnFlag = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.HideOnFlag)
        Variable = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Variable)
        Break = try container.decodeIfPresent(Bool.self, forKey: ChoiceCodingKeys.Break)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ChoiceCodingKeys.self)
        try container.encode(Text, forKey: ChoiceCodingKeys.Text)
        try container.encodeIfPresent(SkipTo, forKey: ChoiceCodingKeys.SkipTo)
        try container.encodeIfPresent(Flag, forKey: ChoiceCodingKeys.Flag)
        try container.encodeIfPresent(HideOnFlag, forKey: ChoiceCodingKeys.HideOnFlag)
        try container.encodeIfPresent(Variable, forKey: ChoiceCodingKeys.Variable)
        try container.encodeIfPresent(Break, forKey: ChoiceCodingKeys.Break)
    }
}

class ChoiceScene: VisualScene {
    var Flag: String? = nil
    var VariableToSet: String? = nil
    var DirectingText: String = ""
    var Choices: [Choice]? = nil
    var Image: String = ""
    
    enum ChoiceCodingKeys: String, CodingKey {
        case SkipTo
        case Flag
        case VariableToSet
        case DirectingText
        case Choices
        case HideOnFlag
        case Variables
        case Choice1Text
        case Choice2Text
        case Choice3Text
        case Choice4Text
        case Image
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        if (scriptParameters["Flag"] != nil) {
            Flag = scriptParameters["Flag"]!
        }
        
        if (scriptParameters["VariableToSet"] != nil) {
            VariableToSet = scriptParameters["VariableToSet"]!
        }
// Lucia's Boop!        
        if (scriptParameters["Image"] != nil) {
            Image = scriptParameters["Image"]!
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ChoiceCodingKeys.self)
        
        Choices = try container.decodeIfPresent([Choice].self, forKey: ChoiceCodingKeys.Choices)
        if (Choices == nil) {
            Choices = []
            let Choice1Text = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Choice1Text)
            if (Choice1Text != nil) {
                let choice: Choice = Choice()
                choice.Text = Choice1Text!
                Choices!.append(choice)
            }
            let Choice2Text = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Choice2Text)
            if (Choice2Text != nil) {
                let choice: Choice = Choice()
                choice.Text = Choice2Text!
                Choices!.append(choice)
            }
            let Choice3Text = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Choice3Text)
            if (Choice3Text != nil) {
                let choice: Choice = Choice()
                choice.Text = Choice3Text!
                Choices!.append(choice)
            }
            let Choice4Text = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Choice4Text)
            if (Choice4Text != nil) {
                let choice: Choice = Choice()
                choice.Text = Choice4Text!
                Choices!.append(choice)
            }
        }
        
        do {
            let SkipTo = try container.decode([Int].self, forKey: ChoiceCodingKeys.SkipTo)
            if (Choices != nil) {
                for (Index, Item) in SkipTo.enumerated() {
                    Choices?[Index + 1].SkipTo = Item
                }
            }
        } catch {
            let SkipTo = try container.decodeIfPresent(Int.self, forKey: ChoiceCodingKeys.SkipTo)
            if (SkipTo != nil && Choices!.count > 1) {
                Choices?[1].SkipTo = SkipTo
            }
        }
        
        let Variables = try container.decodeIfPresent([String].self, forKey: ChoiceCodingKeys.Variables)
        if (Choices != nil && Variables != nil) {
            for (Index, Item) in Variables!.enumerated() {
                Choices?[Index].Variable = Item
            }
        }
        
        let HideOnFlags = try container.decodeIfPresent([String].self, forKey: ChoiceCodingKeys.HideOnFlag)
        if (Choices != nil && HideOnFlags != nil) {
            for (Index, Item) in HideOnFlags!.enumerated() {
                Choices?[Index].HideOnFlag = Item
            }
        }
        
        Flag = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.Flag)
        VariableToSet = try container.decodeIfPresent(String.self, forKey: ChoiceCodingKeys.VariableToSet)
        DirectingText = try container.decode(String.self, forKey: ChoiceCodingKeys.DirectingText)
        Image = try container.decode(String.self, forKey: ChoiceCodingKeys.Image)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ChoiceCodingKeys.self)
        try container.encode(Choices, forKey: ChoiceCodingKeys.Choices)
        try container.encodeIfPresent(Flag, forKey: ChoiceCodingKeys.Flag)
        try container.encodeIfPresent(VariableToSet, forKey: ChoiceCodingKeys.VariableToSet)
        try container.encode(DirectingText, forKey: ChoiceCodingKeys.DirectingText)
        try container.encode(Image, forKey: ChoiceCodingKeys.Image)
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (Flag != nil) {
            scriptLine += ", Flag: " + Flag!
        }
        
        if (VariableToSet != nil) {
            scriptLine += ", VariableToSet: " + VariableToSet!
        }
        
        scriptLine += ", Image: " + Image
        
        return scriptLine
    }
    
    override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = []
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        lines.append("DirectingText: " + strings[DirectingText]!)
        
        if (Choices != nil) {
            for (Index, Choice) in Choices!.enumerated() {
                var scriptLine = "Choice\(Index+1)Text: " + strings[Choice.Text]!
                
                var separator: Bool = false
                
                if (Choice.SkipTo != nil) {
                    separator = true
                    if (indexMap[Choice.SkipTo!] != nil) {
                        scriptLine += " // SkipTo: \(indexMap[Choice.SkipTo!]!)"
                    } else {
                        scriptLine += " // SkipTo: \(Choice.SkipTo!)"
                    }
                }
                
                if (Choice.Variable != nil) {
                    if (separator) {
                        scriptLine += ", "
                    } else {
                        scriptLine += " // "
                    }
                    scriptLine += "Variable: \(Choice.Variable!)"
                }
                
                if (Choice.HideOnFlag != nil) {
                    if (separator) {
                        scriptLine += ", "
                    } else {
                        scriptLine += " // "
                    }
                    scriptLine += "HideOnFlag: \(Choice.HideOnFlag!)"
                }
                
                if (Choice.Flag != nil) {
                    if (separator) {
                        scriptLine += ", "
                    } else {
                        scriptLine += " // "
                    }
                    scriptLine += "Flag: \(Choice.Flag!)"
                }
                
                if (Choice.Break != nil) {
                    if (separator) {
                        scriptLine += ", "
                    } else {
                        scriptLine += " // "
                    }
                    scriptLine += "Break: \(Choice.Break!)"
                }
                
                lines.append(scriptLine)
            }
        }
        
        return lines
    }
}

class ChapterTransitionScene: VisualScene {
    var HorizontalNumber: String = ""
    var HorizontalTitle: String = ""
    var VerticalNumber: String? = nil
    var VerticalTitle: String? = nil
    var ShowPressToContinue: Bool? = nil
    
    enum ChapterTransitionCodingKeys: String, CodingKey {
        case HorizontalNumber
        case HorizontalTitle
        case VerticalNumber
        case VerticalTitle
        case ShowPressToContinue
    }
    
    override init() {
        super.init()
    }
    
    override init(from scriptParameters: [String : String], strings: inout [String : String]) {
        super.init(from: scriptParameters, strings: &strings)
        
        if (scriptParameters["ShowPressToContinue"] != nil) {
            ShowPressToContinue = (scriptParameters["ShowPressToContinue"] == "True") ? true : false
        }
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: ChapterTransitionCodingKeys.self)
        HorizontalNumber = try container.decode(String.self, forKey: ChapterTransitionCodingKeys.HorizontalNumber)
        HorizontalTitle = try container.decode(String.self, forKey: ChapterTransitionCodingKeys.HorizontalTitle)
        VerticalNumber = try container.decodeIfPresent(String.self, forKey: ChapterTransitionCodingKeys.VerticalNumber)
        VerticalTitle = try container.decodeIfPresent(String.self, forKey: ChapterTransitionCodingKeys.VerticalTitle)
        ShowPressToContinue = try container.decodeIfPresent(Bool.self, forKey: ChapterTransitionCodingKeys.ShowPressToContinue)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ChapterTransitionCodingKeys.self)
        try container.encode(HorizontalNumber, forKey: ChapterTransitionCodingKeys.HorizontalNumber)
        try container.encode(HorizontalTitle, forKey: ChapterTransitionCodingKeys.HorizontalTitle)
        try container.encodeIfPresent(VerticalNumber, forKey: ChapterTransitionCodingKeys.VerticalNumber)
        try container.encodeIfPresent(VerticalTitle, forKey: ChapterTransitionCodingKeys.VerticalTitle)
        try container.encodeIfPresent(ShowPressToContinue, forKey: ChapterTransitionCodingKeys.ShowPressToContinue)
    }
    
    override func getDescription() -> String{
        return "Chapter Transition"
    }
    
    override func toScriptHeader(index: Int, strings: [String : String], indexMap: [Int : String]) -> String {
        var scriptLine: String = super.toScriptHeader(index: index, strings: strings, indexMap: indexMap)
        
        if (ShowPressToContinue != nil) {
            scriptLine += ", ShowPressToContinue: " + ((ShowPressToContinue! == true) ? "True" : "False")
        }
        
        return scriptLine
    }
    
    override func toScriptLines(index: Int, strings: [String : String], indexMap: [Int : String]) -> [String] {
        var lines: [String] = ["/* " + strings[HorizontalNumber]! + " */\n"]
        
        lines.append(contentsOf: super.toScriptLines(index: index, strings: strings, indexMap: indexMap))
        
        lines.append("HorizontalNumber: " + strings[HorizontalNumber]!)
        lines.append("HorizontalTitle: " + strings[HorizontalTitle]!)
        lines.append("VerticalNumber: " + strings[VerticalNumber!]!)
        lines.append("VerticalTitle: " + strings[VerticalTitle!]!)
        
        return lines
    }
}
