import UIKit
import SpriteKit
import SceneKit

public class RubiksScene: SKScene {
    
    // overlay SKScene
    
    var backgroundDirections: SKLabelNode!
    var playDirections: SKLabelNode!
    var wwdc: SKLabelNode!
    var loaded = false
    
    // creates texts onto the screen & starts fancy "explosion" animations
    override init(size: CGSize) {
        super.init(size: size)
        
        self.scaleMode = .aspectFit
        
        wwdc = SKLabelNode(text: " WWDC17")
        wwdc.fontSize = 21.0
        wwdc.isHidden = true
        wwdc.position = CGPoint(x: self.frame.midX, y: 10)
        self.addChild(wwdc)
        
        let orb = SKSpriteNode(texture: SKTexture(imageNamed: "Orb.PNG"))
        let startSize = orb.size
        orb.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        orb.alpha = 0.0
        orb.size = CGSize(width: 10, height: 10)
        self.addChild(orb)
        
        let titleWWDC = SKLabelNode(text: " WWDC17")
        titleWWDC.fontSize = 60.0
        titleWWDC.alpha = 0.0
        titleWWDC.fontColor = UIColor.black
        titleWWDC.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        self.addChild(titleWWDC)
        
        let flyIn = SKAction.sequence([
            
            SKAction.group([
                
                SKAction.fadeIn(withDuration: 6.2),
                SKAction.scale(to: startSize, duration: 6.2)
                
                ]),
            
            SKAction.scale(by: 40, duration: 3.0),
            
            SKAction.scale(to: 0.0, duration: 0.8),
            
            SKAction.run {
                orb.removeFromParent()
                titleWWDC.removeFromParent()
                self.wwdc.isHidden = false
                self.sendInformation()
            }
            ])
        
        let titleFlyIn = SKAction.sequence([
            
            SKAction.wait(forDuration: 6.0),
            
            SKAction.fadeIn(withDuration: 1.0),
            
            SKAction.wait(forDuration: 2.5),
            
            SKAction.scale(to: 0.0, duration: 0.8),
            
            ])
        
        titleWWDC.run(titleFlyIn)
        orb.run(flyIn)
        
        loaded = true
    }
    
    // simple text on screen
    func sendInformation() {
        
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        
        playDirections = SKLabelNode(text: "Drag a column or row on the Rubik's Cube to make a move")
        playDirections.fontSize = 19.0
        playDirections.position = CGPoint(x: self.frame.midX, y: self.frame.height - 125)
        playDirections.alpha = 0.0
        self.addChild(playDirections)
        
        backgroundDirections = SKLabelNode(text: "Drag around the background to pan around the scene")
        backgroundDirections.fontSize = 19.0
        backgroundDirections.position = CGPoint(x: self.frame.midX, y: self.frame.height - 100)
        backgroundDirections.alpha = 0.0
        self.addChild(backgroundDirections)
        
        backgroundDirections.run(fadeIn)
        playDirections.run(fadeIn)
        
    }
    
    // when they pan the screen remove pan directions
    func removeBackgroundInfo() {
        backgroundDirections.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.run({
            self.backgroundDirections.removeFromParent()
        })]))
    }
    
    // when they play the rubiks cube remove how to play directions
    func removePlayInfo() {
        playDirections.run(SKAction.sequence([SKAction.fadeOut(withDuration: 1.0), SKAction.run({
            self.playDirections.removeFromParent()
        })]))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}   
