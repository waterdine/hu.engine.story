//
//  StoryState.swift
//  虎.engine.story iOS
//
//  Created by ito.antonia on 11/02/2021.
//

import SpriteKit
import 虎_engine_base

@available(OSX 10.13, *)
@available(iOS 9.0, *)
class CharacterLogic: GameSubScene {
	
    var originalSpeakerY: CGFloat = 0.0
    var speakerImageNode: SKSpriteNode? = nil
    var isRoyalSpeaker: Bool = false
    var speaker: String = ""
    var speakerImages: [String: SKTexture] = [:]
    var enableMouth: Bool = false
    
    public init(gameLogic: GameLogic?, shakeNode: SKNode, startHidden: Bool, isRoyalSpeaker: Bool, speaker: String, speakerImage: String?, imageRotation: Float?, speakerAreaNode: SKSpriteNode?) {
        super.init(gameLogic: gameLogic)

        speakerImageNode = SKSpriteNode()
        self.addChild(speakerImageNode!)
        
        if (speakerImage != nil) {
            var resourceName = speakerImage
            var bundleName = "Default"
            if (speakerImage!.contains(".")) {
                let resourceSplit = speakerImage!.split(separator: ".")
                if (resourceSplit.count == 2) {
                    resourceName = String(resourceSplit[1])
                    bundleName = String(resourceSplit[0])
                }
            }
            let images = gameLogic?.loadUrls(forResourcesWithExtension: ".png", bundleName: bundleName, subdirectory: "Images/Characters/" + resourceName! + ".虎model")
            if (images == nil || images!.isEmpty) {
                let image = gameLogic?.loadUrl(forResource: speakerImage!, withExtension: ".png", subdirectory: "Images")
                if (image != nil) {
                    speakerImages["MouthClosed.png"] = SKTexture(imageNamed: image!.path)
                    speakerImages["MouthClosed.png"]?.usesMipmaps = true
                }
            } else {
                for image in images! {
                    let fileName = image.lastPathComponent
                    speakerImages[fileName] = SKTexture(imageNamed: image.path)
                    speakerImages[fileName]?.usesMipmaps = true
                }
            }
            if (speakerImages.count > 0) {
                let scale = (speakerImageNode?.userData!["scale"] as! CGFloat)
                let defaultTexture = speakerImages["MouthClosed.png"]
                if (defaultTexture != nil) {
                    speakerImageNode?.texture = defaultTexture
                    speakerImageNode?.isHidden = false
                    speakerImageNode?.size = CGSize(width: (speakerImageNode?.texture?.size())!.width, height: (speakerImageNode?.texture?.size())!.height)
                    speakerImageNode?.setScale(speakerImageNode!.xScale * scale)
                    speakerImageNode?.alpha = 1.0
                    speakerImageNode?.position.x = speakerAreaNode!.position.x
                } else {
                    speakerImageNode?.isHidden = true
                }
                enableMouth = (speakerImages["MouthClosed.png"] != nil) && (speakerImages["MouthOpen.png"] != nil)
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
    
    func update(_ currentTime: TimeInterval, animatingText: Bool, textSpeechPause: Bool) {
        if (enableMouth) {
            let mouthClosed = speakerImages["MouthClosed.png"]
            let mouthOpen = speakerImages["MouthOpen.png"]
            var newTexture: SKTexture? = speakerImageNode?.texture
            if (animatingText && !textSpeechPause) {
                let stretchedTime = currentTime * 20
                let sqrt3 = sqrt(3)
                let sqrt5 = sqrt(5)
                if ((sin(stretchedTime) + cos(sqrt3 * stretchedTime) + cos(sqrt5 * stretchedTime)) > 0) {
                    newTexture = mouthOpen
                } else {
                    newTexture = mouthClosed
                }
            } else {
                newTexture = mouthClosed
            }
            if (speakerImageNode?.texture != newTexture) {
                speakerImageNode?.texture = newTexture
            }
        }
    }
    
    func processTextCommand(command: TextLine, speakerAreaNode: SKSpriteNode) {
        let halfWidth = (speakerImageNode?.frame.width)! / 2.0
        if (command.textString == "[jump]") {
            speakerImageNode?.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1), SKAction.moveBy(x: 0.0, y: 20.0, duration: 0.2), SKAction.moveBy(x: 0.0, y: -10.0, duration: 0.1)]))
        } else if (command.textString == "[enterleft]") {
            speakerImageNode?.position = CGPoint(x: self.frame.minX - halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false
        } else if (command.textString == "[enterright]") {
            speakerImageNode?.position = CGPoint(x: self.frame.maxX + halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false
        } else if (command.textString == "[fadeout]") {
            speakerImageNode?.run(SKAction.fadeOut(withDuration: 0.7))
        }
    }
}
