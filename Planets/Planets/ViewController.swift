//
//  ViewController.swift
//  Planets
//
//  Created by Matthew Harding on 1/22/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()

    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.session.run(configuration)
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }

    override func viewDidAppear(_ animated: Bool) {
        addEarth()
        print(Planet.Earth.imagename())
    }

    func addEarth() {
        let earth = createEarth()
        sceneView.scene.rootNode.addChildNode(earth)
    }

    private func createEarth() -> SCNNode {
        let sphere = SCNSphere(radius: 0.2)
//        sphere.segmentCount = 50
        sphere.firstMaterial?.diffuse.contents = Planet.Earth.image()
        sphere.firstMaterial?.specular.contents = UIImage.init(named: "2k_earth_specular_map.jpg")
        sphere.firstMaterial?.emission.contents = UIImage.init(named: "2k_earth_clouds.jpg")

        let planet = SCNNode(geometry: sphere)
        planet.position = SCNVector3(0, -0.4, -1.0)

        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8.0)
        let forever = SCNAction.repeatForever(action)
        planet.runAction(forever)

        return planet
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}
