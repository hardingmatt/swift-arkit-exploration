//
//  OccludingNode.swift
//
//  Created by Matthew Harding on 1/24/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import ARKit

extension SCNNode {

    func resetOcclusion() {
        // Reset children
        self.enumerateChildNodes{ (childNode, _) in
            childNode.removeFromParentNode()
        }
        self.addChildNode(createMaskNode())
    }

    private func createMaskNode() -> SCNNode {
        let geometry = self.geometry?.copy() as! SCNGeometry
        geometry.firstMaterial = createMaskMaterial()
        return SCNNode(geometry: geometry)
    }

    private func createMaskMaterial() -> SCNMaterial {
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        maskMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        maskMaterial.isDoubleSided = true
        return maskMaterial
    }

}
