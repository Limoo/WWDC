import Foundation
import SpriteKit

//Enumeration of the needed collision layers
public enum CollisionLayer : UInt32 {
    case zero = 0
    case one = 1
    case two = 2
}

//Enumeration of the available stages
public enum Stage {
    case one
    case two
}

public class WWDCScene: SKScene, SKPhysicsContactDelegate {
    
    //Edges of the screen so nodes doesnt escape the screen
    private var leftEdgeCollider: SKPhysicsBody?
    private var bottomEdgeCollider: SKPhysicsBody?
    private var rightEdgeCollider: SKPhysicsBody?
    
    //Tims node
    private var timNode: PersonNode?
    
    //The developer nodes displayed
    private var developerNodes: [PersonNode] = []
    
    //The current dragged item
    private var draggedNode: SKNode?
    
    //State to check if the game is over
    private var gameIsOver = false
    
    //State to know when the game can be restarded
    private var canBeRestarded = false
    
    //Image names of the items that can be used
    private let itemImageNames: [String] = ["MacBook","iPhone","iPad","Homepod","Earpods", "AppleWatch"]
    
    //Default person count
    public var personCount = 200
    
    //The current played stage of the game
    public var stage: Stage = .one {
        didSet{
            if let scene = WWDCScene(fileNamed: "WWDCScene") {
                scene.stage = self.stage
                scene.scaleMode = .aspectFit
                scene.personCount = self.personCount
                self.view?.presentScene(scene)
            }
        }
    }
    
    //In here the initial drawing is setup
    override public func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.drawBackground()
        self.addScreenEdgeCollider()
        self.spawnDevelopers(count: self.personCount)
        self.drawTim()
        self.drawInterface()
        self.drawFinish()
    }
    
    //Draws the background of the current stage
    private func drawBackground() {
        var backgroundName = ""
        if self.stage == .one {
            backgroundName = "BG1"
        }
        else {
            backgroundName = "BG2"
        }
        let background = SKSpriteNode(imageNamed: backgroundName)
        background.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
        background.setScale(1.6)
        addChild(background)
    }
    
    //Spawns as many developer as specified in personCount
    private func spawnDevelopers(count: Int) {
        for i in 0...count {
            let rndXPos = CGFloat(arc4random_uniform(UInt32(self.frame.width) + 1))
            let rndYPos = CGFloat(arc4random_uniform(UInt32(self.frame.height - 50 ) + 1)) + 100
            
            let devKind = (i % 5) + 1
            let developer = PersonNode(imageNamed: "\(devKind)IdleRight1")
            developer.kind = devKind
            developer.position = CGPoint(x: rndXPos, y: rndYPos)
            developer.setup()
            developer.name = "developer"
            developer.zPosition = 2
            addChild(developer)
            developer.state = .idle
            self.developerNodes.append(developer)
        }
    }
    
    //Adds the edges to the screen
    private func addScreenEdgeCollider() {
        leftEdgeCollider = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: 0, y: self.frame.height))
        bottomEdgeCollider = SKPhysicsBody(edgeFrom: CGPoint(x: 0, y: 0), to: CGPoint(x: self.frame.width, y: 0))
        rightEdgeCollider = SKPhysicsBody(edgeFrom: CGPoint(x: self.frame.width, y: 0), to: CGPoint(x: self.frame.width, y: self.frame.height))
        
        leftEdgeCollider?.collisionBitMask = CollisionLayer.one.rawValue
        bottomEdgeCollider?.collisionBitMask = CollisionLayer.one.rawValue
        rightEdgeCollider?.collisionBitMask = CollisionLayer.one.rawValue
    }
    
    //Lets Tim drive to the event with his car
    private func drawTim() {
        if self.stage == .one {
            let car = SKSpriteNode(imageNamed: "car")
            car.position = CGPoint(x: -(car.frame.width/2), y: car.frame.height/2)
            car.zPosition = 4
            self.addChild(car)
            car.run(.moveTo(x: self.frame.width/2, duration: 1), completion: {
                self.addTimNode()
                car.run(.wait(forDuration: 1), completion: {
                    car.run(.moveTo(x: self.frame.width + (car.frame.width/2), duration: 1), completion: {})
                })
            })
        }
        else {
            self.addTimNode()
        }
    }
    
    //Adds the actual node for Tim to the screen
    private func addTimNode() {
        self.timNode = PersonNode(imageNamed: "6IdleRight1")
        self.timNode?.movementSpeed = 0.007
        self.timNode?.zPosition = 3
        self.timNode?.kind = 6
        self.timNode?.setup()
        self.timNode?.name = "tim"
        self.timNode?.position = CGPoint(x: self.frame.width / 2, y: 30)
        self.addChild(self.timNode!)
    }
    
    //Draws the menu interface and the given items
    private func drawInterface() {
        let interfaceBackground = PersonNode(imageNamed: "UI")
        interfaceBackground.name = "menu"
        interfaceBackground.position = CGPoint(x: (interfaceBackground.frame.width/2), y: self.frame.height/2)
        interfaceBackground.zPosition = 3
        self.addChild(interfaceBackground)
        
        let inset: CGFloat = 5
        var itemPosY = interfaceBackground.position.y - (interfaceBackground.frame.height/2)
        
        for itemName in self.itemImageNames {
            let item = SKSpriteNode(imageNamed: itemName)
            itemPosY += inset + (item.frame.height)
            item.position = CGPoint(x: interfaceBackground.position.x, y: itemPosY)
            item.name = "item"
            item.zPosition = 3
            //item.setScale(1.5)
            self.addChild(item)
        }
    }
    
    //Plays a game over sequence
    private func gameOver() {
        if !self.gameIsOver {
            self.gameIsOver = true
            self.timNode?.removeAllActions()
            let greyLayer = SKSpriteNode(imageNamed: "greyLayer")
            greyLayer.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            greyLayer.setScale(1.6)
            greyLayer.alpha = 0
            greyLayer.zPosition = 4
            self.addChild(greyLayer)
            greyLayer.run(.fadeIn(withDuration: 1), completion: {
                let gameOverFont = SKSpriteNode(imageNamed: "tooLate")
                gameOverFont.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
                gameOverFont.zPosition = 4
                self.addChild(gameOverFont)
                self.canBeRestarded = true
            })
        }
    }
    
    //Draws the finish node to the screen that tim has to reach
    private func drawFinish() {
        let finishNode = SKSpriteNode(imageNamed: "finish")
        finishNode.name = "finish"
        
        switch self.stage {
        case .one:
             finishNode.position = CGPoint(x: self.frame.width / 2, y: self.frame.height - 30)
            break
        case .two:
             finishNode.position = CGPoint(x: (self.frame.width / 8) * 7, y: self.frame.height - 80)
            break
        }
        finishNode.physicsBody = SKPhysicsBody(rectangleOf: finishNode.frame.size)
        finishNode.physicsBody?.allowsRotation = false
        finishNode.physicsBody?.affectedByGravity = false
        finishNode.physicsBody?.collisionBitMask = 0
        finishNode.physicsBody?.contactTestBitMask = CollisionLayer.two.rawValue
        finishNode.physicsBody?.categoryBitMask = CollisionLayer.two.rawValue
        self.addChild(finishNode)
    }
    
    //Play the finish sequence when Tims reaches the stage
    private func animateFinishSequence() {
        if !self.gameIsOver {
            self.gameIsOver = true
            let greyLayer = SKSpriteNode(imageNamed: "greyLayer")
            greyLayer.position = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
            greyLayer.setScale(1.6)
            greyLayer.alpha = 0
            greyLayer.zPosition = 4
            self.addChild(greyLayer)
            greyLayer.run(.fadeIn(withDuration: 1), completion: {
                let timFinishNode = SKSpriteNode(imageNamed:"timCook")
                timFinishNode.position = CGPoint(x: self.frame.width - (timFinishNode.frame.width/2), y: -(timFinishNode.frame.height/2))
                timFinishNode.zPosition = 5
                self.addChild(timFinishNode)
                timFinishNode.run(.moveTo(y: timFinishNode.frame.height/2, duration: 3), completion: {
                    let bubble = SKSpriteNode(imageNamed: "bubble")
                    bubble.alpha = 0
                    bubble.position = CGPoint(x: timFinishNode.position.x - 300, y: timFinishNode.position.y + 150)
                    bubble.zPosition = 5
                    self.addChild(bubble)
                    bubble.run(.fadeIn(withDuration: 1), completion: {
                        self.canBeRestarded = true
                    })
                })
            })
        }
    }
    
    //Makes the placed item not placable again
    private func didPlaceItem(node: SKNode) {
        node.zPosition = 1
        node.name = ""
    }
    
    //React to touches like moving tim or placing an item
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.gameIsOver {
            if self.canBeRestarded {
                self.stage = .one
            }
        }
        
        if let touch = touches.first {
            let location = touch.location(in: self)
            let node = self.nodes(at: location).first
            if node?.name == "item" {
                self.draggedNode = node
            }
            else if node?.name == "menu" {
                return
            }
            else {
                self.timNode?.moveTo(point: location, finished: {})
            }
        }
    }
    
    //Used to drag a item
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.draggedNode?.position = touch.location(in: self)
        }
    }
    
    //React when an actual touch is completed like placing an item in let the developers move to it
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            self.draggedNode?.position = touch.location(in: self)
            if let node = self.draggedNode {
                self.didPlaceItem(node: node)
                let developerInRange = self.developerNodes.filter{node.position.distanceTo(point: $0.position) < 150}
                for developer in developerInRange {
                    let halfwayPoint = CGPoint(x: ((node.position.x + developer.position.x)/2), y: ((node.position.y + developer.position.y)/2))
                    developer.moveTo(point: halfwayPoint, finished: {
                        developer.startTalking()
                    })
                }
            }
            self.draggedNode = nil
        }
    }
    
    //Cancel a dragged node
    override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let _ = touches.first {
            self.draggedNode = nil
        }
    }
    
    //Function to react to sepcial collisions like tim with an developer
    public func didBegin(_ contact: SKPhysicsContact) {
        if let aNode = contact.bodyA.node, let bNode = contact.bodyB.node {
            if (aNode.name == "tim" || bNode.name == "tim") && (aNode.name == "developer" || bNode.name == "developer") {
                self.gameOver()
                (aNode as! PersonNode).startTalking()
                (bNode as! PersonNode).startTalking()
            }
            else if(aNode.name == "tim" || bNode.name == "tim") && (aNode.name == "finish" || bNode.name == "finish"){
                if self.stage == .one {
                    self.stage = .two
                }
                else {
                    self.animateFinishSequence()
                }
            }
        }
    }
    

}

