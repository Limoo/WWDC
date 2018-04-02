import Foundation
import SpriteKit

extension CGPoint {
    
    //An extension to simply calculate the distance between two points
    public func distanceTo(point: CGPoint) -> CGFloat {
        let distance = CGFloat(sqrt(pow((point.x - self.x), 2.0)) + sqrt(pow((point.y - self.y), 2.0)))
        return distance
    }
}
