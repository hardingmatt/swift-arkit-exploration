//
//  ViewController.swift
//  World Tracking
//
//  Created by Matthew Harding on 1/22/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {



    @IBOutlet weak var drawButton: UIButton!


    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

//    var pointerNode: SCNNode?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.showsStatistics = true
        self.sceneView.autoenablesDefaultLighting = true

        self.sceneView.delegate = self
    }

    func getCurrentCameraPosition(pointOfView: SCNNode, percentOrientation: Float) -> SCNVector3 {
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31 * percentOrientation, -transform.m32 * percentOrientation, -transform.m33 * percentOrientation)
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let currentPositionOfCamera = location + orientation
        return currentPositionOfCamera
    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
//        print(time)
        guard let pointOfView = sceneView.pointOfView else { return }

        let currentPositionOfCamera = getCurrentCameraPosition(pointOfView: pointOfView, percentOrientation: 0.1)

        DispatchQueue.main.async {
//            if let pointer = self.pointerNode, pointer.parent != nil {
//                pointer.removeFromParentNode()
//            }

            if self.drawButton.isHighlighted {
                let penTip = self.makeNode(geometry: SCNSphere(radius: 0.02), color: .blue, position: currentPositionOfCamera)
                self.sceneView.scene.rootNode.addChildNode(penTip)
//                self.pointerNode = nil
//            } else {
//                self.pointerNode = self.makeNode(geometry: SCNSphere(radius: 0.01), color: .red, position: currentPositionOfCamera)
//                self.sceneView.scene.rootNode.addChildNode(self.pointerNode!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func reset(_ sender: Any) {
        restartSession()
        self.sceneView.delegate = self
    }

    func restartSession() {
        DispatchQueue.main.async {
            self.sceneView.session.pause()
            self.sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in
                print(node)
                if node.parent != nil {
                    node.removeFromParentNode()
                } else {
                    print("Parent was nil")
                }
            }
            self.sceneView.session.run(self.configuration, options: [.resetTracking, .removeExistingAnchors])
        }
    }

    @IBAction func add(_ sender: Any) {
//        addRoundedCube()
//        addCylinder()
//        addFloor()
//        addSphere(color: .black, segmentCount: 50)
//        addPath()
        addHouse()
    }

    func addHouse() {
        guard let pointOfView = sceneView.pointOfView else { return }
        let currentPositionOfCamera = getCurrentCameraPosition(pointOfView: pointOfView, percentOrientation: 1.0)

        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let pyramid = SCNPyramid(width: 0.1, height: 0.05, length: 0.1)
        let door = SCNPlane(width: 0.02, height: 0.05)

//        let x = randomNumbers(firstNum: -0.5, secondNum: 0.5)
        let house = makeNode(geometry: box, color: .blue, position: currentPositionOfCamera)
        house.addChildNode(makeNode(geometry: pyramid, color: .red, position: SCNVector3(0, 0.05, 0)))
        house.addChildNode(makeNode(geometry: door, color: .green, position: SCNVector3(0, -0.025, 0.052)))
//        house.eulerAngles = SCNVector3(Float(180.degreesToRadians), 0, 0)
        self.sceneView.scene.rootNode.addChildNode(house)
    }

    func makeNode(geometry: SCNGeometry, color: UIColor, position: SCNVector3) -> SCNNode {
        geometry.firstMaterial?.diffuse.contents = color
//        geometry.firstMaterial?.specular.contents = UIColor.white
        let node = SCNNode(geometry: geometry)
        node.position = position
        return node
    }
    func addPath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x:1,y:1), controlPoint1: CGPoint(x:0.1,y:0), controlPoint2: CGPoint(x:0.9,y:1.0))
        path.addQuadCurve(to: CGPoint(x:2, y:0), controlPoint: CGPoint(x:1.5, y:0.2))
        let shape = SCNShape(path: path, extrusionDepth: 0.1)

        let node = SCNNode(geometry: shape)
        node.position = SCNVector3(0, 0, -0.8)
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func addRoundedCube(color: UIColor = .blue) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.05)
        box.firstMaterial?.specular.contents = UIColor.white
        box.firstMaterial?.diffuse.contents = color
        box.chamferSegmentCount = 50

        let node = SCNNode(geometry: box)
        node.position = SCNVector3(0.5, 0, -0.3)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func addCylinder(color: UIColor = .black) {
        let node = SCNNode()
        node.geometry = SCNCylinder(radius: 0.1, height: 0.5)
        node.geometry?.firstMaterial?.specular.contents = UIColor.white
        node.geometry?.firstMaterial?.diffuse.contents = color
        node.position = SCNVector3(0, 0, -0.5)
        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func addSphere(color: UIColor = .red, segmentCount: Int = 10) {
        let sphere = SCNSphere(radius: 0.1)
        sphere.segmentCount = segmentCount
        sphere.firstMaterial?.specular.contents = UIColor.white
        sphere.firstMaterial?.diffuse.contents = color

        let node = SCNNode()
        node.geometry = sphere
        let x = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        let y = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        let z = randomNumbers(firstNum: -0.3, secondNum: 0.3)
        node.position = SCNVector3(x, y, z)
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    func addFloor(color: UIColor = .white) {
        let node = SCNFloor()
        node.firstMaterial?.specular.contents = UIColor.white
        node.firstMaterial?.diffuse.contents = color
        node.reflectivity = 0.8
        node.length = 5.0
//        self.sceneView.scene.rootNode.addChildNode(node)
    }
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
    }
}

extension Int {

    var degreesToRadians: Double { return Double(self) * .pi/180}
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
}

