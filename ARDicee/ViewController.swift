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

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResults = results.first {
                // Create a new scene
                //let scene = SCNScene(named: "art.scnassets/ship.scn")!
                let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!

                // if let block allows checking for presence of diceNode before adding to sceneView
                if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
                    diceNode.position = SCNVector3(
                        x: hitResults.worldTransform.columns.3.x,
                        y: hitResults.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                        z: hitResults.worldTransform.columns.3.z
                    )
                    sceneView.scene.rootNode.addChildNode(diceNode)
                }
            }
        }
    }
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor {
            
            let planeAnchor = anchor as! ARPlaneAnchor //down cast
            
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
            
            node.addChildNode(planeNode)
        } else {
            return
        }
    }
}
