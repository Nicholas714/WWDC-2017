import SceneKit
import SpriteKit
import UIKit

public extension Float {
    
    // 5% similiar
    func isClose(to: Float) -> Bool {
        return abs(self - to) < 0.05
    }
    
    // is between 5% confidence interval
    func isclose(to: Float) -> Bool {
        return abs(self - to) < 0.05 
    }
    
    // returns a random rotation in 90 degree intervals: 0, 90, 270, 360
    static func randomRotation() -> Float {
        // random between 1 and 359
        let randomDegreeNumber = Int(arc4random_uniform(360) + 1)
        // rounds it to nearest rotation
        let rotation = Float(Int((Double(randomDegreeNumber) / 90.0) + 0.5) * 90) * Float(Double.pi / 180)
        return rotation
    }
}

public extension Array {
    
    // returns random element in an array
    func random() -> Element {
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    // remove random array element and return that element
    mutating func removeRandom() -> Element {
        return self.remove(at: Int(arc4random_uniform(UInt32(self.count))))
    }
}

extension SCNVector3 {
    
    // not exact distance (for efficiency no sqrt), just to find the closest distance to point
    func distance(to: SCNVector3) -> Double {
        let x = self.x - to.x
        let y = self.y - to.y
        let z = self.z - to.z
        
        return Double((x * x) + (y * y) + (z * z))
    }
    
}

extension Double {
    
    // returns the smallest doule from a array
    func isSmallest(from: [Double]) -> Bool {
        for value in from {
            if self < value {
                return false
            }
        }
        return true
    }
    
}

extension UIColor {
    
    // rubiks colors as an array for easy iteration
    static let rubiksColors = [rubGreen, rubRed, rubBlue, rubOrange, rubWhite, rubYellow]
    
    // rubiks colors
    static let rubGreen = UIColor(red:0.00, green:0.61, blue:0.28, alpha:1.00)
    static let rubRed = UIColor(red:0.72, green:0.07, blue:0.20, alpha:1.00)
    static let rubBlue = UIColor(red:0.00, green:0.27, blue:0.68, alpha:1.00)
    static let rubOrange = UIColor(red:1.00, green:0.35, blue:0.00, alpha:1.00)
    static let rubWhite = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.00)
    static let rubYellow = UIColor(red:1.00, green:0.84, blue:0.00, alpha:1.00)
    static let rubBlack = UIColor(red: 0.00, green: 0.00, blue: 0.00, alpha: 1.00)
    static let floor = UIColor(red:0.31, green:0.17, blue:0.08, alpha:1.00)
    
    // return random rubiks color (used for stars)
    static func randomRubiksColor() -> UIColor {
        return rubiksColors[Int(arc4random_uniform(UInt32(rubiksColors.count)))]
    }
    
}

extension ClosedRange {
    
    // return random integer in a range (-100...100).randomInt
    var randomInt: Int {
        get {
            var offset = 0
            
            if lowerBound is Int == false {
                return 0
            }
            
            if (lowerBound as! Int) < 0 {
                offset = abs(lowerBound as! Int)
            }
            
            let mini = UInt32(lowerBound as! Int + offset)
            let maxi = UInt32(upperBound as! Int + offset)
            
            return Int(mini + arc4random_uniform(maxi - mini)) - offset
        }
    }
    
}



