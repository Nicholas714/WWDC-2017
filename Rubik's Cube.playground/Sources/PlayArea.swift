import SceneKit
import UIKit
import SpriteKit

public class PlayArea: NSObject, UIGestureRecognizerDelegate {
    
    static var v: SCNView!
    
    public let view: SCNView
    
    let scene = SCNScene()
    let camera = SCNCamera()
    let cameraNode = SCNNode()
    var cube: RubiksCube! = nil
    lazy var pan: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(swipe(_:)))
    }()
    
    let centerNode = SCNNode()
    
    var beginingAnimationFinished = false
    
    var defaultGestures: [UIGestureRecognizer]!
    
    public override init() {
        self.view = PlayArea.v
        super.init()
        
        // setup view properties
        view.scene = scene
        view.backgroundColor = UIColor.black
        
        // store gestures to be applied later
        view.allowsCameraControl = true
        defaultGestures = view.gestureRecognizers!
        // view.allowsCameraControl = false
        
        // setup camera
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        let look = SCNLookAtConstraint(target: centerNode)
        look.isGimbalLockEnabled = true
        cameraNode.constraints = [look]
        add(node: cameraNode)
        
        //view.defaultCameraController?.interactionMode = .orbitTurntable
        // view.defaultCameraController?.maximumVerticalAngle = 45.0
                
        // creates stars
        for color in UIColor.rubiksColors {
            let exp = SCNParticleSystem()
            exp.loops = true
            exp.birthRate = 100
            exp.emissionDuration = 1.0
            exp.spreadingAngle = 180
            exp.emitterShape = SCNSphere(radius: 50.0)
            exp.particleLifeSpan = 3
            exp.particleLifeSpanVariation = 2
            exp.particleVelocity = 0.5
            exp.particleVelocityVariation = 3
            exp.particleSize = 0.05
            exp.stretchFactor = 0.05
            exp.particleColor = color
            scene.addParticleSystem(exp, transform: SCNMatrix4MakeRotation(0, 0, 0, 0))
        }
    }
    
    var startPanPoint: CGPoint?
    var vertical = false
    var horizontal = false
    var offset: CGFloat = 0
    var selectedContainer: SCNNode?
    var selectedSide: Side?
    
    @objc func swipe(_ gestureRecognize: UIPanGestureRecognizer) {
        if !beginingAnimationFinished {
            return
        }
        
        if let cube = cube {
            if cube.animating {
                return
            }
            
            let velocity = gestureRecognize.velocity(in: view)
            let point = gestureRecognize.location(in: view)
            let isVertical = abs(velocity.y) > abs(velocity.x)
            let isHorizontal = abs(velocity.x) > abs(velocity.y)
            let p = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(p, options: [:])
            
            if selectedSide == nil {
                selectedSide = side(from: hitResults.first)
                
                if selectedSide == nil {
                    return
                }
            }
            
            if startPanPoint == nil {
                startPanPoint = gestureRecognize.location(in: view)
            }
            
            if !vertical && !horizontal {
                vertical = isVertical
                horizontal = isHorizontal
            }
            
            if let rubiksScene = self.view.overlaySKScene as? RubiksScene {
                rubiksScene.removePlayInfo()
            }
            
            // selects the col/row to be rotated
            if gestureRecognize.state == .began {
                guard let node = hitResults.first?.node, node.position.y >= -2 else {
                    return
                }
                
                if vertical {
                    // change z, otherwise change y
                    if selectedSide == .left || selectedSide == .right {
                        selectedContainer = cube.col(z: node.position.z)
                    } else {
                        selectedContainer = cube.col(x: node.position.x)
                    }
                } else {
                    selectedContainer = cube.row(y: node.position.y)
                }
                add(node: selectedContainer!)
            }
            
            // rotates col/row
            if isVertical && vertical {
                offset = point.y - startPanPoint!.y // they share the same point pan
                if selectedSide == .left || selectedSide == .back {
                    // switch its rotation direction
                    offset = startPanPoint!.y - point.y
                }
                if selectedSide == .left || selectedSide == .right {
                    selectedContainer?.rotation = SCNVector4(x: 0, y: 0, z: 1, w: Float(offset * CGFloat(Double.pi / 180)))
                } else {
                    selectedContainer?.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(offset * CGFloat(Double.pi / 180)))
                }
                
            } else if isHorizontal && horizontal {
                offset = point.x - startPanPoint!.x
                selectedContainer?.rotation = SCNVector4(x: 0, y: 1, z: 0, w: Float(offset * CGFloat(Double.pi / 180)))
            }
            
            // when it ends snap the col/row into the closest angle
            if gestureRecognize.state == .ended {
                if let container = selectedContainer {
                    cube.snap(container: container, vertical: vertical, side: selectedSide!, finished: {
                        for node in self.selectedContainer?.childNodes ?? [SCNNode]() {
                            node.transform = self.selectedContainer!.convertTransform(node.transform, to: nil)
                            self.add(node: node)
                        }
                        self.selectedContainer = nil
                        self.selectedSide = nil
                        self.startPanPoint = nil
                        self.vertical = false
                        self.horizontal = false
                        self.offset = 0;
                        self.cube.animating = false
                    })
                }
                
            }
            
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let p1 = gestureRecognizer.location(in: view)
        let hitResults1 = view.hitTest(p1, options: [:])
        let p2 = otherGestureRecognizer.location(in: view)
        let hitResults2 = view.hitTest(p2, options: [:])
        
        if hitResults1.isEmpty && hitResults2.isEmpty {
            if let rubiksScene = self.view.overlaySKScene as? RubiksScene {
                rubiksScene.removeBackgroundInfo()
            }
            return true
        } else {
            if gestureRecognizer == pan {
                return true
            }
            return false
        }
    }
    
    func side(from: SCNHitTestResult?) -> Side? {
        guard let from = from else {
            return nil
        }
        
        let pos = from.worldCoordinates
        
        let top = SCNVector3(0, 5, 0).distance(to: pos)
        let bottom = SCNVector3(0, -5, 0).distance(to: pos)
        let left = SCNVector3(-5, 0, 0).distance(to: pos)
        let right = SCNVector3(5, 0, 0).distance(to: pos)
        let back = SCNVector3(0, 0, 5).distance(to: pos)
        let front = SCNVector3(0, 0, -5).distance(to: pos)
        
        let all = [top, bottom, left, right, back, front]
        
        if top.isSmallest(from: all) {
            return .top
        } else if bottom.isSmallest(from: all) {
            return .bottom
        } else if left.isSmallest(from: all) {
            return .left
        } else if right.isSmallest(from: all) {
            return .right
        } else if back.isSmallest(from: all) {
            return .back
        } else if front.isSmallest(from: all) {
            return .front
        }
        
        return nil
    }
    
    func add(node: SCNNode) {
        self.scene.rootNode.addChildNode(node)
    }
    
}
