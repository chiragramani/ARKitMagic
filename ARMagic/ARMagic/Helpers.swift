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
        var (min, max) = presentation.boundingBox
        let size = max - min
        /*
         I observed that the condition check -> node.presentation.worldPosition.y > min.y was failing all the time by a margin of 0.25.
         That's why subtracting 0.25. I know its a hack - would really appreciate if you can show me the right way of doing it.
         */
        min = SCNVector3(presentation.worldPosition.x - size.x/2, presentation.worldPosition.y - 0.25, presentation.worldPosition.z - size.z/2)
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
