//
//  ViewController.swift
//  Ikea
//
//  Created by Matthew Harding on 1/24/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var collectionView: UICollectionView!

    let itemsArray: [String] = ["cup", "vase", "table", "raptor", "horse", "wolf", "ducky"]
    var selectedItem: String?
    var rotatingNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.sceneView.delegate = self
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.automaticallyUpdatesLighting = true
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]

        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.registerGestureRecognizers()
    }

    func registerGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped))
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(rotate))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.addGestureRecognizer(pinchGestureRecognizer)
        self.sceneView.addGestureRecognizer(longPressGestureRecognizer)
    }
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let pinchLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(pinchLocation)
        if !hitTest.isEmpty {
            print("Pinched!")
            let results = hitTest.first!
            let node = results.node
            let pinchAction = SCNAction.scale(by: sender.scale, duration: 0)
            node.runAction(pinchAction)
            sender.scale = 1.0
        } else {
            print("Didn't really pinch")
        }
    }

    @objc func rotate(sender: UILongPressGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let holdLocation = sender.location(in: sceneView)

        let hitTest = sceneView.hitTest(holdLocation)
        if !hitTest.isEmpty {
            let node = hitTest.first!.node
            rotatingNode = node
            if sender.state == .began {
                print("Rotating...")
                if node.action(forKey: "rotate") == nil {
                    let rotateAction = SCNAction.rotateBy(x: 0, y: .pi * 2, z: 0, duration: 2)
                    let forever = SCNAction.repeatForever(rotateAction)
                    node.runAction(forever, forKey: "rotate")
                }
            } else if sender.state == .ended {
                print("Stop rotating.")
                rotatingNode?.removeAllActions()
                rotatingNode = nil
            }

        } else {
            print("Didn't really rotate")
        }


    }

    func centerPivot(for node: SCNNode) {
        let min = node.boundingBox.min
        let max = node.boundingBox.max
        node.pivot = SCNMatrix4MakeTranslation(
            min.x + (max.x - min.x)/2,
            min.y + (max.y - min.y)/2,
            min.z + (max.z - min.z)/2
        )
    }

    @objc func tapped(sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: sceneView)
        let hitTest = sceneView.hitTest(tapLocation, types: .existingPlane) // TODO (this makes it extend forever)
        if !hitTest.isEmpty {
            print("Touched horiz surface")
            addItem(hitTestResult: hitTest.first!)
        } else {
            print("Tapped")
        }
    }

    func addItem(hitTestResult: ARHitTestResult) {
        if let selectedItem = self.selectedItem {
            let transform = hitTestResult.worldTransform
            let thirdColumn = transform.columns.3
            let position = SCNVector3(thirdColumn.x, thirdColumn.y, thirdColumn.z)
            let node = createNode(selectedItem, position)
            addDropAnimation2(node, mass: getMass(selectedItem))
            sceneView.scene.rootNode.addChildNode(node)
        }
    }

    private func getMass(_ selectedItem: String) -> CGFloat {
        switch selectedItem {
        case "ducky":
            return 2
        case "cup":
            return 2
        case "horse":
            return 10
        case "wolf":
            return 10
        case "raptor":
            return 10
        case "vase":
            return 3
        default:
            return 1
        }
    }

    func createNode(_ selectedItem: String, _ position: SCNVector3) -> SCNNode {
        let scene = SCNScene(named: "Models.scnassets/\(selectedItem).scn")
        let node = (scene?.rootNode.childNode(withName: selectedItem, recursively: false))!
        self.centerPivot(for: node)
        node.position = position
        if ["cup", "ducky", "vase"].contains(selectedItem) {
            node.eulerAngles.y = random(limit: 2 * .pi)
        }
        return node
    }

    private func addDropAnimation(_ node: SCNNode) {
        let delta: Float = 0.3
        let duration = 0.15

        node.position.y += delta
        node.opacity = 0.7
        let fallAction = SCNAction.move(by: SCNVector3(0, -delta, 0), duration: duration)
        let fadeInAction = SCNAction.fadeIn(duration: duration)
        let action = SCNAction.group([fallAction, fadeInAction])
        node.runAction(action, forKey: "drop")
    }

    private func addDropAnimation2(_ node: SCNNode, mass: CGFloat) {
        let shape = SCNPhysicsShape(node: node, options: [.keepAsCompound: true])
//        let shape = boundingBoxToShape(node.boundingBox.min, node.boundingBox.max)
        let body = SCNPhysicsBody(type: .dynamic, shape: shape)
        body.mass = mass

        let delta: Float = 1.0
        node.position.y += delta

        node.physicsBody = body
    }

    private func boundingBoxToShape(_ min: SCNVector3, _ max: SCNVector3) -> SCNPhysicsShape {
        let box = SCNBox(width: CGFloat(max.x - min.x), height: CGFloat(max.y - min.y), length: CGFloat(max.z - min.z), chamferRadius: 0)
        return SCNPhysicsShape(geometry: box, options: [.keepAsCompound: true])
    }

    private func random(limit: Float) -> Float {
        return Float(arc4random_uniform(UInt32(limit * 1000))) / 1000
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        cell.label.text = itemsArray[indexPath.row]
        cell.backgroundColor = UIColor.orange
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.green
        selectedItem = itemsArray[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.backgroundColor = UIColor.orange
    }



    /*
     * ARSCNViewDelegate Renderer functions
     */

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let planeNode = createFloor(planeAnchor: planeAnchor)
        planeNode.reset(occlusion: true, physics: true)

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

        planeNode.reset(occlusion: true, physics: true)
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

