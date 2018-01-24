//
//  ViewController.swift
//  FloorIsLava
//
//  Created by Matthew Harding on 1/24/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self

        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.autoenablesDefaultLighting = true

        // Run the view's session
        sceneView.session.run(configuration)
    }

    /*
     * ARSCNViewDelegate Renderer functions
     */

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createFloor(planeAnchor: planeAnchor)
        planeNode.resetOcclusion()

        node.addChildNode(planeNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor,
            let planeNode = node.childNodes.first,
            let plane = planeNode.geometry as? SCNPlane
            else { return }

        planeNode.simdPosition = float3(planeAnchor.center.x, -0.02, planeAnchor.center.z)

        let width = planeAnchor.extent.x
        let height = planeAnchor.extent.z
        plane.width = CGFloat(width)
        plane.height = CGFloat(height)
        plane.firstMaterial = createMaterial(width, height)

        planeNode.resetOcclusion()
    }

    /*
     * Helper functions
     */

    private func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let width = planeAnchor.extent.x
        let height = planeAnchor.extent.z

        let plane = SCNPlane(width: CGFloat(width), height: CGFloat(height))
        plane.firstMaterial = createMaterial(width, height)

        let floorNode = SCNNode(geometry: plane)
        floorNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y - 0.02, planeAnchor.center.z)
        floorNode.eulerAngles.x = -.pi/2
        return floorNode
    }

    private func createMaterial(_ width: Float, _ height: Float) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"grid.png")
        material.diffuse.wrapS = .repeat
        material.diffuse.wrapT = .repeat
        material.isDoubleSided = false
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1)
        return material
    }

}
