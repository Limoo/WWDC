
//: # Too late for WWDC
//: This game puts you in an ironic scenario where Tim Cook is too late for the WWDC opening and has to get into the convention center as fast as possible. You can move Tim by simply clicking. By dragging and placing some cool hardware from the left menu you can distract the attending developers so they clear the way and start programming together. Tim then can find a pass through and get into the convention centre by stepping on the finish flag. Try not get in an conversation or Tim might be too late for the WWDC opening. If you fail just restard the game by simply clicking on the screen.

import PlaygroundSupport
import SpriteKit

//: How crowded can  it get a WWDC?
//: You can change this variable to see how crowded it can get at WWDC. Also by increasing/decreasing this the game gets easier or harder.
let personsAtWWDC = 200

//: Here the the scene is initialised. The game logic is placed inside the Sources folder to increase the performance.
let sceneView = SKView(frame: CGRect(x:0 , y:0, width: 640, height: 480))
if let wwdc = WWDCScene(fileNamed: "WWDCScene") {
    wwdc.scaleMode = .aspectFit
    wwdc.personCount = personsAtWWDC
    sceneView.presentScene(wwdc)
}
PlaygroundSupport.PlaygroundPage.current.liveView = sceneView


