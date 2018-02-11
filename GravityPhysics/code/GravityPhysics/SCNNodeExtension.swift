//
//  SCNNodeExtension.swift
//  DynamicObjectPlacement
//
//  Created by Raymond Weiss on 2/3/18.
//  Copyright © 2018 ray. All rights reserved.
//

import SceneKit

extension SCNNode {
    func moveUp() {
        let up = SCNVector3(0.0, 0.1, 0.0)
        let moveUp = SCNAction.move(by: up, duration: 0.5)
        self.runAction(moveUp)
    }
    
    func moveDown() {
        let down = SCNVector3(0.0, -0.1, 0.0)
        let movedown = SCNAction.move(by: down, duration: 0.5)
        self.runAction(movedown)
    }
    
    func moveLeft() {
        let left = SCNVector3(-0.1, 0.0, 0.0)
        let moveLeft = SCNAction.move(by: left, duration: 0.5)
        self.runAction(moveLeft)
    }
    
    func moveRight() {
        let right = SCNVector3(0.1, 0.0, 0.0)
        let moveRight = SCNAction.move(by: right, duration: 0.5)
        self.runAction(moveRight)
    }
    
    func moveForward() {
        let forward = SCNVector3(0.0, 0.0, -0.2)
        let moveForward = SCNAction.move(by: forward, duration: 0.5)
        self.runAction(moveForward)
    }
    
    func moveBackward() {
        let backward = SCNVector3(0.0, 0.0, 0.2)
        let moveBackward = SCNAction.move(by: backward, duration: 0.5)
        self.runAction(moveBackward)
    }
    
    func deleteNode() {
        self.removeFromParentNode()
    }
}

