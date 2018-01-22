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
        let sun = createPlanet(.Sun)
        let x = Planet.Neptune.scaledDistanceFromSun()
        sun.position = SCNVector3(-x, -0.4, -3.0)

        sun.addChildNode(createPlanet(.Mercury))
        sun.addChildNode(createPlanet(.Venus))
        sun.addChildNode(createPlanet(.Earth))
        sun.addChildNode(createPlanet(.Mars))
        sun.addChildNode(createPlanet(.Jupiter))
        sun.addChildNode(createPlanet(.Saturn))
        sun.addChildNode(createPlanet(.Uranus))
        sun.addChildNode(createPlanet(.Neptune))

        sceneView.scene.rootNode.addChildNode(sun)
    }

    func addEarth() {
        let earth = createPlanet(.Earth)
        sceneView.scene.rootNode.addChildNode(earth)
    }

    private func createPlanet(_ planet: Planet) -> SCNNode {
        let sphere = SCNSphere(radius: planet.scaledRadius())
        sphere.firstMaterial?.diffuse.contents = planet.image()

        if planet == .Earth {
            sphere.firstMaterial?.specular.contents = UIImage.init(named: "2k_earth_specular_map.jpg")
            sphere.firstMaterial?.emission.contents = UIImage.init(named: "2k_earth_clouds.jpg")
        }

        let text = SCNText(string: planet.name(), extrusionDepth: 0.03)
        text.font = UIFont.systemFont(ofSize: 0.1)
        let textNode = SCNNode(geometry: text)
        textNode.position = SCNVector3(0, -planet.scaledRadius(), planet.scaledRadius())

        let node = SCNNode(geometry: sphere)
        node.addChildNode(textNode)

        node.position = SCNVector3(planet.scaledDistanceFromSun(), 0, 0)

        if planet != .Sun {
            let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
        }

        return node
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}
