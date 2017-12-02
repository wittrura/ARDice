//
//  ViewController.swift
//  ARDicee
//
//  Created by Ryan Wittrup on 12/1/17.
//  Copyright © 2017 Ryan Wittrup. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]() // initialize empty array to hold all created nodes / dice

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // created geometry with scenekit box
        //let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
        //let sphere = SCNSphere(radius: 0.2)
        
        // material to 'wrap' cube
        //let material = SCNMaterial()
        //material.diffuse.contents = UIColor.red
        
        // drape texture map on material
        //material.diffuse.contents = UIImage(named: "art.scnassets/moon.jpg")
        
        // add material to cube's materials array
        //sphere.materials = [material]
        
        // create a point in 3D space, assign position, assign an object to display aka geometry
        //let node = SCNNode()
        //node.position = SCNVector3(x: 0, y: 0.1, z: -0.5) // -z axis is AWAY from user
        //node.geometry = sphere
        
        // root node can have any number of child nodes
        //sceneView.scene.rootNode.addChildNode(node)
        
        sceneView.autoenablesDefaultLighting = true
        
//        // Create a new scene
//        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
//        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
//
//        // if let block allows checking for presence of diceNode before adding to sceneView
//        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
//            diceNode.position = SCNVector3(x: 0, y: 0, z: -0.1)
//            sceneView.scene.rootNode.addChildNode(diceNode)
//        }
//
//        // Set the scene to the view
//        //sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    //MARK: - Dice Rendering Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location: ARHitTestResult) -> Void {
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        // if let block allows checking for presence of diceNode before adding to sceneView
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            // set the position of the node based off the real-world dimensions from the hitResult
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, // to lay flat rather than centered
                z: location.worldTransform.columns.3.z
            )
            
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    
    func roll(dice: SCNNode) -> Void {
        let randomX = Float((arc4random_uniform(4) + 1)) * (Float.pi / 2)
        let randomZ = Float((arc4random_uniform(4) + 1)) * (Float.pi / 2)
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX) * 5,
            y: 0,
            z: CGFloat(randomZ) * 5,
            duration: 0.5)
        )
    }
    
    func rollAllDice() -> Void {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(dice: dice)
            }
        }
    }
    
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        rollAllDice()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAllDice()
        print("shook phone")
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    
    //MARK: - ARSCNViewDelegateMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // guard statement to replace if... else
        // try to downcast planeAnchor to ARPlaneAnchor
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
    }
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        // planes are always defined by x and z dimenions for horizontal plane detection, y is AWLAYS ZERO
        // define new plan based on added anchor
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        // transfrom from standard x, y to x, z
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
        
        return planeNode
    }
}




