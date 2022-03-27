//
//  CharacterChoice.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 27/03/2021.
//

import SpriteKit
import 虎_engine_base

enum PlayerType {
	case M, F, None
}

#if os(OSX)
typealias UITextFieldDelegate = NSTextFieldDelegate
typealias UITextField = NSTextField
#endif

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class CharacterChoiceLogic: GameScene, UITextFieldDelegate {

	var createArea: SKSpriteNode?
	var fArea: SKSpriteNode?
	var mArea: SKSpriteNode?
	var nameArea: SKSpriteNode?
	var selectedNodeBorder: SKSpriteNode?
	var nameAreaLabel: SKLabelNode?
	var nameField: UITextField?
	
	var playerName: String = "Press to edit..."
	var playerType: PlayerType = .None
	
	class func newScene(gameLogic: GameLogic) -> CharacterChoiceLogic {
        guard let scene = gameLogic.loadScene(scene: "Default.CharacterChoice", classType: CharacterChoiceLogic.classForKeyedUnarchiver()) as? CharacterChoiceLogic else {
            print("Failed to load CharacterChoice.sks")
            return CharacterChoiceLogic()
        }
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		nameArea = self.childNode(withName: "//NameArea") as? SKSpriteNode
		fArea = self.childNode(withName: "//FArea") as? SKSpriteNode
		mArea = self.childNode(withName: "//MArea") as? SKSpriteNode
		createArea = self.childNode(withName: "//CreateArea") as? SKSpriteNode
		nameAreaLabel = self.childNode(withName: "//NameAreaLabel") as? SKLabelNode
		selectedNodeBorder = self.childNode(withName: "//SelectedNodeBorder") as? SKSpriteNode
		selectedNodeBorder?.isHidden = true
		nameField = UITextField()
		nameField?.delegate = self
#if !os(OSX)
		nameField?.autocorrectionType = .no
#endif
		nameField?.isHidden = true
		view.addSubview(nameField!)
	}
    
    override func interactionEnded(_ point: CGPoint, timestamp: TimeInterval) {
		if (nameArea!.frame.contains(point)) {
			nameField?.becomeFirstResponder()
			playerName = nameAreaLabel!.text!
			nameAreaLabel!.text = ""
#if !os(OSX)
			nameField!.text = ""
#endif
		} else if (fArea!.frame.contains(point)) {
			playerType = .F
			selectedNodeBorder?.isHidden = false
			selectedNodeBorder?.position = fArea!.position
		} else if (mArea!.frame.contains(point)) {
            playerType = .M
			selectedNodeBorder?.isHidden = false
			selectedNodeBorder?.position = mArea!.position
		} else if (createArea!.frame.contains(point)) {
			if (playerType != .None && playerName != "" && playerName != "Press to edit...") {
                self.gameLogic!.gameState.variables["PlayerName"] = playerName
				if (playerType == .F) {
                    self.gameLogic!.gameState.variables["PlayerPronoun1"] = "She"
                    self.gameLogic!.gameState.variables["PlayerPronoun2"] = "Hers"
                    self.gameLogic!.gameState.variables["PlayerPronoun3"] = "Her"
                    self.gameLogic!.gameState.variables["PlayerPronoun4"] = "she"
                    self.gameLogic!.gameState.variables["PlayerPronoun5"] = "hers"
                    self.gameLogic!.gameState.variables["PlayerPronoun6"] = "her"
                    self.gameLogic!.gameState.variables["PlayerPronoun7"] = "Herself"
                    self.gameLogic!.gameState.variables["PlayerPronoun8"] = "herself"
                    self.gameLogic!.gameState.variables["PlayerPronoun9"] = "gal"
                    self.gameLogic!.gameState.variables["Honorific"] = "Ma'am"
                    self.gameLogic!.gameState.variables["Honorifics"] = "Madams"
                    self.gameLogic!.gameState.variables["Title"] = "Mrs"
                    self.gameLogic!.gameState.variables["OppositePronoun1"] = "He"
                    self.gameLogic!.gameState.variables["OppositePronoun2"] = "His"
                    self.gameLogic!.gameState.variables["OppositePronoun3"] = "Him"
                    self.gameLogic!.gameState.variables["OppositePronoun4"] = "he"
                    self.gameLogic!.gameState.variables["OppositePronoun5"] = "his"
                    self.gameLogic!.gameState.variables["OppositePronoun6"] = "him"
                    self.gameLogic!.gameState.variables["OppositePronoun7"] = "Himself"
                    self.gameLogic!.gameState.variables["OppositePronoun8"] = "himself"
                    self.gameLogic!.gameState.variables["OppositePronoun9"] = "guy"
				} else if (playerType == .M) {
                    self.gameLogic!.gameState.variables["PlayerPronoun1"] = "He"
                    self.gameLogic!.gameState.variables["PlayerPronoun2"] = "His"
                    self.gameLogic!.gameState.variables["PlayerPronoun3"] = "Him"
                    self.gameLogic!.gameState.variables["PlayerPronoun4"] = "he"
                    self.gameLogic!.gameState.variables["PlayerPronoun5"] = "his"
                    self.gameLogic!.gameState.variables["PlayerPronoun6"] = "him"
                    self.gameLogic!.gameState.variables["PlayerPronoun7"] = "Himself"
                    self.gameLogic!.gameState.variables["PlayerPronoun8"] = "himself"
                    self.gameLogic!.gameState.variables["PlayerPronoun9"] = "guy"
                    self.gameLogic!.gameState.variables["Honorific"] = "Sir"
                    self.gameLogic!.gameState.variables["Honorifics"] = "Sirs"
                    self.gameLogic!.gameState.variables["Title"] = "Mr"
                    self.gameLogic!.gameState.variables["OppositePronoun1"] = "She"
                    self.gameLogic!.gameState.variables["OppositePronoun2"] = "Hers"
                    self.gameLogic!.gameState.variables["OppositePronoun3"] = "Her"
                    self.gameLogic!.gameState.variables["OppositePronoun4"] = "she"
                    self.gameLogic!.gameState.variables["OppositePronoun5"] = "hers"
                    self.gameLogic!.gameState.variables["OppositePronoun6"] = "her"
                    self.gameLogic!.gameState.variables["OppositePronoun7"] = "Herself"
                    self.gameLogic!.gameState.variables["OppositePronoun8"] = "herself"
                    self.gameLogic!.gameState.variables["OppositePronoun9"] = "gal"
				}
				self.gameLogic?.saveState()
				self.gameLogic?.nextScene()
			}
		} else {
			nameField?.resignFirstResponder()
			if (playerName == "") {
                playerName = "Press to edit..."
			}
			nameAreaLabel!.text = playerName
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let length = range.location + (range.length == 0 ? string.count : range.length - 1)
#if !os(OSX)
		var candidateString: String = textField.text!
#else
        var candidateString: String = ""
#endif
		let neededChars = length - candidateString.count
		if (neededChars > 0) {
			for _ in 0 ... neededChars {
				candidateString.append(".")
			}
		}
		
		var startIndex: String.Index = candidateString.startIndex;
		var endIndex: String.Index = startIndex;
		candidateString.formIndex(&startIndex, offsetBy: range.location)
		candidateString.formIndex(&endIndex, offsetBy: length)
		candidateString.replaceSubrange(startIndex ... endIndex, with: string)
		if (candidateString.contains(" ") || candidateString.count > 12) {
			return false
		}
		
		playerName = candidateString
		nameAreaLabel!.text = playerName
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nameField?.resignFirstResponder()
#if !os(OSX)
		playerName = (nameField?.text)!
#endif
		nameAreaLabel!.text = playerName
		return true
	}
}
