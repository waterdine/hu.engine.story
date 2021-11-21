//
//  StoryState.swift
//  RevengeOfTheSamurai iOS
//
//  Created by x414e54 on 11/02/2021.
//

import SpriteKit
import Flat47Game

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class CharacterLogic: GameSubScene {
	
    var originalSpeakerY: CGFloat = 0.0
    var speakerImageNode: SKSpriteNode? = nil
    var isRoyalSpeaker: Bool = false
    
    public init(gameLogic: GameLogic?, shakeNode: SKNode, startHidden: Bool, data: NSDictionary) {
        super.init(gameLogic: gameLogic)

        speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
        
        let speakerRoyalLabel = shakeNode.childNode(withName: "//SpeakerRoyal") as! SKLabelNode
        let speakerLabel = shakeNode.childNode(withName: "//Speaker") as! SKLabelNode
        isRoyalSpeaker = data["RoyalSpeaker"] as? Bool ?? false
        let speaker = Bundle.main.localizedString(forKey: ((data["Speaker"] as? String)!), value: nil, table: "Story")
        let font = Bundle.main.localizedString(forKey: "CharacterFontName", value: nil, table: "Story")
        if (isRoyalSpeaker) {
            speakerRoyalLabel.text = speaker
            speakerRoyalLabel.fontName = font
            speakerRoyalLabel.isHidden = false
            speakerLabel.isHidden = true
        } else {
            speakerLabel.text = speaker
            speakerLabel.fontName = font
            speakerRoyalLabel.isHidden = true
            speakerLabel.isHidden = false
        }
        
        var speakerAreaNode = shakeNode.childNode(withName: "//SpeakerArea") as? SKSpriteNode
        
        if (isRoyalSpeaker) {
            speakerAreaNode = shakeNode.childNode(withName: "//SpeakerAreaRoyal") as? SKSpriteNode
        }
        
        speakerImageNode = shakeNode.childNode(withName: "//SpeakerImage") as? SKSpriteNode
        let speakerImage: String? = data["SpeakerImage"] as? String
        if (speakerImage != nil) {
            let speakerimagePath: String? = Bundle.main.path(forResource: speakerImage, ofType: ".png")
            if (speakerimagePath != nil) {
                let scale = speakerImageNode?.userData!["scale"] as! CGFloat
                speakerImageNode?.isHidden = false
                speakerImageNode?.texture = SKTexture(imageNamed: speakerimagePath!)
                speakerImageNode?.size = CGSize(width: (speakerImageNode?.texture?.size())!.width * scale, height: (speakerImageNode?.texture?.size())!.height * scale)
                speakerImageNode?.alpha = 1.0
                speakerImageNode?.position.x = speakerAreaNode!.position.x;
            } else {
                speakerImageNode?.isHidden = true
            }
        } else {
            speakerImageNode?.isHidden = true
        }
        
        /*if (originalSpeakerY != nil) {
            speakerImageNode?.position.y = originalSpeakerY!
            originalSpeakerY = nil
        }*/ // atode: Must persist
        
        let imageRotation = data["Rotation"] as? Float
        if (imageRotation != nil) {
            speakerImageNode?.zRotation = CGFloat((Double(imageRotation!) / 180.0) * Double.pi)
            originalSpeakerY = speakerImageNode!.position.y
            speakerImageNode?.position.y = self.frame.maxY - (speakerImageNode?.size.height)! / 2.0
        } else {
            speakerImageNode?.zRotation = 0.0
        }
        
        speakerImageNode?.isHidden = startHidden
        
        /*let textArea = shakeNode.childNode(withName: "//TextArea") as? SKSpriteNode
        var theme = data?["Theme"] as? String
        if (theme == nil) {
            theme = "Theme1"
        }
        let textNode = shakeNode.childNode(withName: "//Text") as? SKLabelNode
        let themeColor = textArea?.userData?[theme as Any] as? String
        if (themeColor != nil) {
            if (themeColor! == "White") {
                textArea?.color = UIColor.white
                textNode?.fontColor = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
            } else if (themeColor! == "0058D0") {
                textArea?.color = UIColor.init(red: 0.0, green: 88.0 / 255.0, blue: 208.0 / 255.0, alpha: 1.0)
                textNode?.fontColor = UIColor.white
            } else if (themeColor! == "Black") {
                textArea?.color = UIColor.black
                textNode?.fontColor = UIColor.white
            }
        }*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func processTextCommand(command: String, speakerAreaNode: SKSpriteNode) {
        let halfWidth = (speakerImageNode?.frame.width)! / 2.0
        if (command == "[jump]") {
            speakerImageNode?.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1), SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1)]))
        } else if (command == "[enterleft]") {
            speakerImageNode?.position = CGPoint(x: self.frame.minX - halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false
        } else if (command == "[enterright]") {
            speakerImageNode?.position = CGPoint(x: self.frame.maxX + halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false
        } else if (command == "[fadeout]") {
            speakerImageNode?.run(SKAction.fadeOut(withDuration: 0.7))
        }
    }
}
