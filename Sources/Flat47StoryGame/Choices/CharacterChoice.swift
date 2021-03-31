//
//  CharacterChoice.swift
//  TheAmericat iOS
//
//  Created by x414e54 on 27/03/2021.
//

import SpriteKit
import GameplayKit

enum CatType {
	case MCat, FCat, None
}

class CharacterChoiceLogic: GameScene, UITextFieldDelegate {

	var createArea: SKSpriteNode?
	var fCatArea: SKSpriteNode?
	var mCatArea: SKSpriteNode?
	var nameArea: SKSpriteNode?
	var selectedNodeBorder: SKSpriteNode?
	var nameAreaLabel: SKLabelNode?
	var nameField: UITextField?
	
	var catName: String = "Press to edit..."
	var catType: CatType = .None
	
	class func newScene(gameLogic: GameLogic) -> CharacterChoiceLogic {
		guard let scene = CharacterChoiceLogic(fileNamed: "CharacterChoice" + gameLogic.getAspectSuffix()) else {
			print("Failed to load CharacterChoice.sks")
			abort()
		}

		scene.scaleMode = .aspectFill
		scene.gameLogic = gameLogic;
		
		return scene
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		nameArea = self.childNode(withName: "//NameArea") as? SKSpriteNode
		fCatArea = self.childNode(withName: "//FCatArea") as? SKSpriteNode
		mCatArea = self.childNode(withName: "//MCatArea") as? SKSpriteNode
		createArea = self.childNode(withName: "//CreateArea") as? SKSpriteNode
		nameAreaLabel = self.childNode(withName: "//NameAreaLabel") as? SKLabelNode
		selectedNodeBorder = self.childNode(withName: "//SelectedNodeBorder") as? SKSpriteNode
		selectedNodeBorder?.isHidden = true
		nameField = UITextField()
		nameField?.delegate = self
		nameField?.autocorrectionType = .no
		nameField?.isHidden = true
		view.addSubview(nameField!)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		let point: CGPoint = (touches.first?.location(in: self))!
		if (nameArea!.frame.contains(point)) {
			nameField?.becomeFirstResponder()
			catName = nameAreaLabel!.text!
			nameAreaLabel!.text = ""
			nameField!.text = ""
		} else if (fCatArea!.frame.contains(point)) {
			catType = .FCat
			selectedNodeBorder?.isHidden = false
			selectedNodeBorder?.position = fCatArea!.position
		} else if (mCatArea!.frame.contains(point)) {
			catType = .MCat
			selectedNodeBorder?.isHidden = false
			selectedNodeBorder?.position = mCatArea!.position
		} else if (createArea!.frame.contains(point)) {
			if (catType != .None && catName != "" && catName != "Press to edit...") {
				self.gameLogic!.variables["PlayerName"] = catName
				if (catType == .FCat) {
					self.gameLogic!.variables["PlayerPronoun1"] = "She"
					self.gameLogic!.variables["PlayerPronoun2"] = "Hers"
					self.gameLogic!.variables["PlayerPronoun3"] = "Her"
					self.gameLogic!.variables["PlayerPronoun4"] = "she"
					self.gameLogic!.variables["PlayerPronoun5"] = "hers"
					self.gameLogic!.variables["PlayerPronoun6"] = "her"
					self.gameLogic!.variables["Honorific"] = "Ma'am"
				} else if (catType == .MCat) {
					self.gameLogic!.variables["PlayerPronoun1"] = "He"
					self.gameLogic!.variables["PlayerPronoun2"] = "His"
					self.gameLogic!.variables["PlayerPronoun3"] = "Him"
					self.gameLogic!.variables["PlayerPronoun4"] = "he"
					self.gameLogic!.variables["PlayerPronoun5"] = "his"
					self.gameLogic!.variables["PlayerPronoun6"] = "him"
					self.gameLogic!.variables["Honorific"] = "Sir"
				}
				self.gameLogic?.saveState()
				self.gameLogic?.nextScene()
			}
		} else {
			nameField?.resignFirstResponder()
			if (catName == "") {
				catName = "Press to edit..."
			}
			nameAreaLabel!.text = catName
		}
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let length = range.location + (range.length == 0 ? string.count : range.length - 1)
		var candidateString: String = textField.text!
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
		
		catName = candidateString
		nameAreaLabel!.text = catName
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		nameField?.resignFirstResponder()
		catName = (nameField?.text)!
		nameAreaLabel!.text = catName
		return true
	}
}
