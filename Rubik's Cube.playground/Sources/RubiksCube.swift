import SceneKit
import UIKit

public class RubiksCube {
    
    var animating: Bool = false
    let area: PlayArea
    lazy var skScene: RubiksScene = {
        return RubiksScene(size: self.area.view.frame.size)
    }()
    private var hasBeenAdded = false
    
    public init(area: PlayArea, fake: Bool = false) {
        self.area = area
        area.cube = self
        
        var toAnimate = [SCNNode]()
        // makes colored 27 SCNBox that makes up the cube
        for x in -1...1 {
            for y in -1...1 {
                for z in -1...1 {
                    let box = SCNBox(width: 0.9, height: 0.9, length: 0.9, chamferRadius: 0.0)
                    
                    let greenMaterial = SCNMaterial()
                    greenMaterial.diffuse.contents = UIColor.rubBlack
                    if z + 1 > 1 {
                        greenMaterial.diffuse.contents = UIColor.rubGreen
                    }
                    
                    let redMaterial = SCNMaterial()
                    redMaterial.diffuse.contents = UIColor.rubBlack
                    if x + 1 > 1 {
                        redMaterial.diffuse.contents = UIColor.rubRed
                    }
                    
                    let blueMaterial = SCNMaterial()
                    blueMaterial.diffuse.contents = UIColor.rubBlack
                    if z - 1 < -1 {
                        blueMaterial.diffuse.contents = UIColor.rubBlue
                    }
                    
                    let orangeMaterial = SCNMaterial()
                    orangeMaterial.diffuse.contents = UIColor.rubBlack
                    if x - 1 < -1 {
                        orangeMaterial.diffuse.contents = UIColor.rubOrange
                    }
                    
                    let whiteMaterial = SCNMaterial()
                    whiteMaterial.diffuse.contents = UIColor.rubBlack
                    if y + 1 > 1 {
                        whiteMaterial.diffuse.contents = UIColor.rubWhite
                    }
                    
                    let yellowMaterial = SCNMaterial()
                    yellowMaterial.diffuse.contents = UIColor.rubBlack
                    if y - 1 < -1 {
                        yellowMaterial.diffuse.contents = UIColor.rubYellow
                    }
                    
                    box.materials = [greenMaterial, redMaterial, blueMaterial, orangeMaterial, whiteMaterial, yellowMaterial]
                    
                    let node = SCNNode(geometry: box)
                    node.position = SCNVector3(x, y, z)
                    
                    if !fake {
                        area.add(node: node)
                        toAnimate.append(node)
                    } else {
                        area.add(node: node)
                        node.isHidden = true
                    }
                }
            }
        }
        
        if fake {
            return
        }
        
        // background Rubik's Cube that is hidden and scrambled that will replace
        let fakeCube = RubiksCube(area: area, fake: true)
        fakeCube.scramble()
        
        // keeps track of hidden nodes
        var hidden = [SCNNode]()
        for n in self.area.scene.rootNode.childNodes {
            if let geo = n.geometry, geo is SCNBox && n.isHidden {
                hidden.append(n)
            }
        }
        
        var animations = [SCNNode : SCNAction]()
        
        for node in toAnimate {
            let replaced = hidden.removeRandom()
            let pos = replaced.position
            let rot = replaced.rotation
            
            // fancy animation that pulls everything together
            let fall = SCNAction.sequence([
                
                SCNAction.wait(duration: 3.0),
                
                SCNAction.group([SCNAction.fadeOut(duration: 7.0), SCNAction.move(by: SCNVector3((-30...30).randomInt, (-30...30).randomInt, -20), duration: 7.0), SCNAction.rotateBy(x: CGFloat(Double.pi * 2), y: CGFloat(Double.pi * 2), z: CGFloat(Double.pi * 2), duration: 7.0), SCNAction.scale(to: 0.5, duration: 7.0)]),
                
                SCNAction.run({ (node) in
                    if self.area.view.overlaySKScene == nil {
                        self.area.view.overlaySKScene = self.skScene
                    }
                }),
                
                SCNAction.group([SCNAction.run({ (node) in
                    if let _ = node.geometry, let _ = replaced.geometry { // just to be safe...
                        node.geometry!.materials = replaced.geometry!.materials
                    }
                }), SCNAction.fadeIn(duration: 7.0), SCNAction.rotate(toAxisAngle: rot, duration: 7.0), SCNAction.move(to: pos, duration: 7.0), SCNAction.scale(to: 1.0, duration: 7.0)]),
                
                SCNAction.wait(duration: 3.1), // wait 3.1 seconds while the other animations occur
                
                SCNAction.run({ (node) in
                    self.animating = false
                    self.area.beginingAnimationFinished = true
                    self.area.view.allowsCameraControl = true
                    
                    if !self.hasBeenAdded {
                        self.area.pan.delegate = self.area
                        self.area.view.addGestureRecognizer(self.area.pan)
                        for gesture in self.area.defaultGestures {
                            gesture.delegate = self.area
                            self.area.view.addGestureRecognizer(gesture)
                        }
                        self.hasBeenAdded = true
                    }
                })
                
                ])
            animations[node] = fall
        }
        
        for (node, animation) in animations {
            node.runAction(animation)
        }
    }
    
    func row(y: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.position.y >= -2 && (node.position.y.isclose(to: y) || node.presentation.position.y.isclose(to: y)) {
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(x: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.position.y >= -2 && (node.position.x.isclose(to: x) || node.presentation.position.x.isclose(to: x)) {
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(z: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.position.y >= -2 && (node.position.z.isclose(to: z) || node.presentation.position.z.isclose(to: z)) {
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func row(yy: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.y.isClose(to: yy) || node.presentation.position.y.isClose(to: yy)) {
                node.removeFromParentNode()
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(xx: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.x.isClose(to: xx) || node.presentation.position.x.isClose(to: xx)) {
                node.removeFromParentNode()
                container.addChildNode(node)
            }
        }
        return container
    }
    
    func col(zz: Float) -> SCNNode {
        let container = SCNNode()
        
        for node in area.scene.rootNode.childNodes {
            if let geo = node.geometry, geo is SCNBox && node.isHidden && node.position.y >= -2 && (node.position.z.isClose(to: zz) || node.presentation.position.z.isClose(to: zz)) {
                node.removeFromParentNode()
                container.addChildNode(node)
            }
        }
        return container
    }
    
    // scrambles cube randomly 63 times
    func scramble() {
        for _ in 0...20 {
            
            for _ in 0...2 {
                var container = SCNNode()
                let randomLevel = Float(Int(arc4random_uniform(2)) - 1)
                let randomTwist = Float(Int(arc4random_uniform(3)))
                var axis = SCNVector4()
                
                if randomTwist == 0 {
                    container = row(yy: randomLevel)
                    axis = SCNVector4(x: 0, y: 1, z: 0, w: Float.randomRotation())
                } else if randomTwist == 1 {
                    container = col(xx: randomLevel)
                    axis = SCNVector4(x: 1, y: 0, z: 0, w: Float.randomRotation())
                } else if randomTwist == 2 {
                    container = col(zz: randomLevel)
                    axis = SCNVector4(x: 0, y: 0, z: 1, w: Float.randomRotation())
                }
                
                container.rotation = axis
                for node in container.childNodes {
                    node.transform = container.convertTransform(node.transform, to: nil)
                    node.isHidden = true
                    node.removeFromParentNode()
                    area.add(node: node)
                }
                container.removeFromParentNode()
            }
        }
        
    }
    
    // snaps cow/col to closest rotation
    func snap(container: SCNNode, vertical: Bool, side: Side, finished: @escaping () -> ()) {
        self.animating = true
        
        let roundedOffset = Float(Int((abs(area.offset).truncatingRemainder(dividingBy: 360)) / 90.0 + 0.5) * 90) * Float(Double.pi / 180) * (area.offset < 0 ? -1 : 1)
        
        var rot: SCNVector4!
        
        if vertical {
            if side == .left || side == .right {
                rot = SCNVector4(x: 0, y: 0, z: 1, w: roundedOffset)
            } else {
                rot = SCNVector4(x: 1, y: 0, z: 0, w: roundedOffset)
            }
        } else {
            rot = SCNVector4(x: 0, y: 1, z: 0, w: roundedOffset)
        }
        
        container.runAction(SCNAction.sequence([SCNAction.rotate(toAxisAngle: rot, duration: 0.2), SCNAction.run({ (node) in
            finished()
            self.animating = false
        })]))
    }
}
