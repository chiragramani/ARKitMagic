//
//  Helpers.swift
//  ARMagic
//
//  Created by Chirag Ramani on 01/04/18.
//  Copyright © 2018 Chirag Ramani. All rights reserved.
//

import SceneKit

/// Source: Udacity's ARKit Slack Channel.

extension SCNNode {
    func contains(node: SCNNode) -> Bool {
        var (min, max) = presentation.boundingBox // Initialize both the max and min information for the hat tube at once
        let size = max - min // Hat's tube size, you can also get the hat's position and use it over here
        // Get the max and min using the position of the hat and gotten sizes
        min = SCNVector3(presentation.worldPosition.x - size.x/2, presentation.worldPosition.y, presentation.worldPosition.z - size.z/2)
        max = SCNVector3(presentation.worldPosition.x + size.x/2, presentation.worldPosition.y + size.y, presentation.worldPosition.z + size.z/2)
        return node.presentation.worldPosition.x > min.x &&
            node.presentation.worldPosition.y > min.y &&
            node.presentation.worldPosition.z > min.z &&
            node.presentation.worldPosition.x < max.x &&
            node.presentation.worldPosition.y < max.y &&
            node.presentation.worldPosition.z < max.z
    }
}

func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
}
