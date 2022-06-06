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
    var shortName: String = ""
    var speaker: String = ""
    var speakerImages: [String: SKTexture] = [:]
    var enableMouth: Bool = false
    var lastTime: Double = 0.0
    
    var currentOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    var wantedOffset: CGSize = CGSize(width: 0.0, height: 0.0)
    var currentScale: Float = 1.0
    var wantedScale: Float = 1.0
    
    public init(gameLogic: GameLogic?, shakeNode: SKNode, startHidden: Bool, isRoyalSpeaker: Bool, speaker: String, shortName: String, speakerImage: String?, imageRotation: Float?, speakerAreaNode: SKSpriteNode?, scale: CGFloat, position: CGFloat) {
        super.init(gameLogic: gameLogic)

        self.speaker = speaker
        self.shortName = shortName
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
                let defaultTexture = speakerImages["MouthClosed.png"]
                if (defaultTexture != nil) {
                    speakerImageNode?.texture = defaultTexture
                    speakerImageNode?.isHidden = false
                    speakerImageNode?.size = CGSize(width: (speakerImageNode?.texture?.size())!.width, height: (speakerImageNode?.texture?.size())!.height)
                    speakerImageNode?.setScale(speakerImageNode!.xScale * scale)
                    speakerImageNode?.alpha = 1.0
                    speakerImageNode?.position.x = 0
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
        
        originalSpeakerY = position
        
        if (imageRotation != nil) {
            speakerImageNode?.zRotation = CGFloat((Double(imageRotation!) / 180.0) * Double.pi)
            speakerImageNode?.position.y = position / 2.0
        } else {
            speakerImageNode?.zRotation = 0.0
        }
        
        speakerImageNode?.isHidden = startHidden
        
        wantedScale = 1.0
        currentScale = 1.0
        
        currentOffset = CGSize(width: 0.0, height: 0.0)
        wantedOffset = currentOffset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ currentTime: TimeInterval, animatingText: Bool, textSpeechPause: Bool) {
        
        var delta = currentTime - lastTime
        if (lastTime == 0) {
            delta = 0
        }
        lastTime = currentTime
        
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
        
        if (wantedScale != currentScale) {
            if (wantedScale < currentScale) {
                currentScale -= Float(delta / 10.0)
                if (currentScale < 0.0) {
                    currentScale = wantedScale
                }
                if (currentScale < wantedScale) {
                    currentScale = wantedScale
                }
            } else if (wantedScale > currentScale) {
                currentScale += Float(delta / 10.0)
                if (currentScale > 1.0) {
                    currentScale = wantedScale
                }
                if (currentScale > wantedScale) {
                    currentScale = wantedScale
                }
            }
            speakerImageNode?.shader?.uniformNamed("u_scale")?.floatValue = currentScale
        }
        
        if (wantedOffset != currentOffset) {
            if (wantedOffset.width < currentOffset.width) {
                currentOffset.width -= CGFloat(delta / 10.0)
                if (currentOffset.width < 0.0) {
                    currentOffset.width = wantedOffset.width
                }
                if (currentOffset.width < wantedOffset.width) {
                    currentOffset.width = wantedOffset.width
                }
            } else if (wantedOffset.width > currentOffset.width) {
                currentOffset.width += CGFloat(delta / 10.0)
                if (currentOffset.width > 1.0) {
                    currentOffset.width = wantedOffset.width
                }
                if (currentOffset.width > wantedOffset.width) {
                    currentOffset.width = wantedOffset.width
                }
            }
            
            if (wantedOffset.height < currentOffset.height) {
                currentOffset.height -= CGFloat(delta / 10.0)
                if (currentOffset.height < 0.0) {
                    currentOffset.height = wantedOffset.height
                }
                if (currentOffset.height < wantedOffset.height) {
                    currentOffset.height = wantedOffset.height
                }
            } else if (wantedOffset.height > currentOffset.height) {
                currentOffset.height += CGFloat(delta / 10.0)
                if (currentOffset.height > 1.0) {
                    currentOffset.height = wantedOffset.height
                }
                if (currentOffset.height > wantedOffset.height) {
                    currentOffset.height = wantedOffset.height
                }
            }
            speakerImageNode?.shader?.uniformNamed("u_offset_x")?.floatValue = Float(currentOffset.width)
            speakerImageNode?.shader?.uniformNamed("u_offset_y")?.floatValue = Float(currentOffset.height)
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
        /*} else if (command.textString == "[exitleft]") {
            speakerImageNode?.position = CGPoint(x: self.frame.minX - halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false
        } else if (command.textString == "[exitright]") {
            speakerImageNode?.position = CGPoint(x: self.frame.maxX + halfWidth, y: (speakerImageNode?.position.y)!)
            speakerImageNode?.run(SKAction.moveTo(x: (speakerAreaNode.position.x), duration: 0.7))
            speakerImageNode?.isHidden = false*/
        } else if (command.textString == "[fadeout]") {
            speakerImageNode?.run(SKAction.fadeOut(withDuration: 0.7))
        } else if (command.textString?.starts(with: "[pos:") ?? false) {
            var pos = command.textString?.replacingOccurrences(of: "[pos:", with: "") ?? "0.0,0.0"
            pos = pos.trimmingCharacters(in: ["]"])
            let parts: [Substring] = pos.split(separator: ",")
            if (parts.count == 1) {
                let offset = Float.init(parts[0])
                wantedOffset.width = CGFloat(offset!)
                wantedOffset.height = CGFloat(offset!)
            } else if (parts.count == 2) {
                let offsetX = Float.init(parts[0])
                let offsetY = Float.init(parts[1])
                wantedOffset.width = CGFloat(offsetX!)
                wantedOffset.height = CGFloat(offsetY!)
            }
        } else if (command.textString?.starts(with: "[scale:") ?? false) {
            var scale = command.textString?.replacingOccurrences(of: "[scale:", with: "") ?? "1.0"
            scale = scale.trimmingCharacters(in: ["]"])
            wantedScale = Float.init(scale)!
        }
    }
}
