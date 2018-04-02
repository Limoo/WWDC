import Foundation
import SpriteKit

public class PersonNode : SKSpriteNode {
    
    //An enumeration to represent the current state of the node
    public enum State {
        case idle
        case walkLeft(x:CGFloat, y:CGFloat)
        case walkRight(x:CGFloat, y:CGFloat)
        case talking
    }
    
    //The previous state of the node to react to movement sequences
    private var previousSate: State = .idle
    
    //Defines the moving speed of the node
    public var movementSpeed = 0.02
    
    //The label when the node starts talking
    private var talkLabelNode: SKLabelNode?
    
    //Defines which images represent the node
    public var kind = 0
    
    //The current state of the node
    public var state: State = .idle {
        didSet {
            self.previousSate = oldValue
            switch self.state {
            case .idle:
                self.idle()
                break
            case let .walkRight(x, y), let .walkLeft(x, y):
                self.moveRandom(x: x, y: y)
                break
            case .talking:
                break
            }
        }
    }
    
    //The words a node can say
    private let words = ["if","case","let","switch","import","func","public","private","var","static", "self", "true", "false", "enum", "class"]
    
    //In these variables the walking textures are saved after the node gets initialised
    private var walkLeftTextures: [SKTexture] = []
    private var walkRightTextures: [SKTexture] = []
    private var idleLeftTextures: [SKTexture] = []
    private var idleRightTextures: [SKTexture] = []
    
    //The initial setup for the nodes. It load the images and set their physic properties
    public func setup() {
        self.assignImages()
        self.texture?.filteringMode = .nearest
        
        let size = CGSize(width: self.frame.width, height: self.frame.height/2)
        let center = CGPoint(x: 0, y: -(self.frame.height/4))
        self.physicsBody = SKPhysicsBody(rectangleOf: size, center: center)
        
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.collisionBitMask = CollisionLayer.one.rawValue
        self.physicsBody?.contactTestBitMask = CollisionLayer.one.rawValue
        self.physicsBody?.isDynamic = true
    }
    
    //Load the images sepcified which kind this node should represent
    private func assignImages() {
        walkLeftTextures = [SKTexture(imageNamed: "\(kind)WalkLeft1"), SKTexture(imageNamed: "\(kind)WalkLeft2"), SKTexture(imageNamed: "\(kind)WalkLeft3")]
        walkRightTextures = [SKTexture(imageNamed: "\(kind)WalkRight1"), SKTexture(imageNamed: "\(kind)WalkRight2"), SKTexture(imageNamed: "\(kind)WalkRight3")]
        idleLeftTextures = [SKTexture(imageNamed: "\(kind)IdleLeft1"), SKTexture(imageNamed: "\(kind)IdleLeft2")]
        idleRightTextures = [SKTexture(imageNamed: "\(kind)IdleRight1"), SKTexture(imageNamed: "\(kind)IdleRight2")]
    }
    
    
    //Lets the node stay idle  move to random positions in random intervals
    private func idle() {
        let rnd = Double(Int(arc4random_uniform(5)))
        var textures: [SKTexture] = []
        
        switch self.previousSate {
        case .walkRight(_, _), .idle, .talking:
            textures = self.idleRightTextures
            break
        case .walkLeft(_, _):
            textures = self.idleLeftTextures
            break
        }
        
        self.run(.repeatForever(.animate(with: textures, timePerFrame: 0.5)))
                self.run(.wait(forDuration: rnd), completion: {
                    self.removeAllActions()
        
                    let rndX = CGFloat(arc4random_uniform(41)) - 20
                    let rndY = CGFloat(arc4random_uniform(41)) - 20
                    rndX > 0 ? (self.state = .walkRight(x: rndX, y: rndY)) : (self.state = .walkLeft(x: rndX, y: rndY))
                })
    }
    
    //Lets the node move by a random interval. Also show the needed images for the movement
    private func moveRandom(x:CGFloat, y:CGFloat) {
        self.removeAllActions()
        var textures: [SKTexture] = []
        if x > 0 {
            textures = self.walkRightTextures
        }
        else {
            textures = self.walkLeftTextures
        }
        self.run(.repeatForever(.animate(with: textures, timePerFrame: 0.5)))
        self.run(.moveBy(x: x, y: y, duration: 0.5), completion: {
            self.removeAllActions()
            self.state = .idle
        })
    }
    
    //Lets the node move to a point. Also show the needed images for the movement
    public func moveTo(point:CGPoint, finished:@escaping(() -> Void)) {
        self.removeAllActions()
        var textures: [SKTexture] = []
        
        if point.x > self.position.x {
            textures = self.walkRightTextures
        }
        else {
            textures = self.walkLeftTextures
        }
        let distance = Double(self.position.distanceTo(point: point))
        
        self.run(.repeatForever(.animate(with: textures, timePerFrame: 0.5)))
        self.run(.move(to: point, duration: self.movementSpeed*distance), completion: {
            self.removeAllActions()
            self.state = .talking
            finished()
        })
    }
    
    // Lets the node talk by placing a label above
    public func startTalking() {
        self.removeAllActions()
        self.talkLabelNode = SKLabelNode(fontNamed: "Menlo")
        self.talkLabelNode?.zPosition = 3
        self.talkLabelNode?.text = self.words[Int(arc4random_uniform(UInt32(self.words.count)))]
        self.talkLabelNode?.fontSize = 10
        self.talkLabelNode?.fontColor = UIColor(red: 170/255, green: 13/255, blue: 145/255, alpha: 1.0)
        self.talkLabelNode?.position = CGPoint(x: self.position.x, y: self.position.y + (self.frame.height/2))
        self.parent?.addChild(talkLabelNode!)
        self.continueTalking()
    }
    
    //Lets the node continue talking by changing the displayed word
    private func continueTalking() {
        self.run(.wait(forDuration: 1), completion: {
            self.talkLabelNode?.text = self.words[Int(arc4random_uniform(UInt32(self.words.count)))]
            self.talkLabelNode?.position = CGPoint(x: self.position.x, y: self.position.y + (self.frame.height/2))
            self.continueTalking()
        })
    }

}
