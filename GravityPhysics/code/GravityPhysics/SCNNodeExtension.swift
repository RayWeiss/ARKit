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
    
    func moveLeft(ofCamera camera: matrix_float4x4) {
        let distance: Float = 0.1
        let cameraDirection = SCNVector3(camera.columns.2.x, 0.0, camera.columns.2.z)
        let adjustedLeftDirection = SCNVector3(-1 * distance * cameraDirection.z, 0.0, distance * cameraDirection.x)
        let moveLeft = SCNAction.move(by: adjustedLeftDirection, duration: 0.5)
        self.runAction(moveLeft)
    }
    
    func moveRight(ofCamera camera: matrix_float4x4) {
        let distance: Float = 0.1
        let cameraDirection = SCNVector3(camera.columns.2.x, 0.0, camera.columns.2.z)
        let adjustedRightDirection = SCNVector3(distance * cameraDirection.z, 0.0, -1 * distance * cameraDirection.x)
        let moveRight = SCNAction.move(by: adjustedRightDirection, duration: 0.5)
        self.runAction(moveRight)
    }
    
    func moveTowards(camera: matrix_float4x4) {
        let distance: Float = 0.2
        let cameraDirection = SCNVector3(camera.columns.2.x, 0.0, camera.columns.2.z)
        let adjustedTowardsDirection = SCNVector3(distance * cameraDirection.x, 0.0, distance * cameraDirection.z)
        let moveTowards = SCNAction.move(by: adjustedTowardsDirection, duration: 0.5)
        self.runAction(moveTowards)
    }

    func moveAwayFrom(camera: matrix_float4x4) {
        let distance: Float = 0.2
        let cameraDirection = SCNVector3(camera.columns.2.x, 0.0, camera.columns.2.z)
        let adjustedAwayDirection = SCNVector3(-1 * distance * cameraDirection.x, 0.0, -1 * distance * cameraDirection.z)
        let moveAway = SCNAction.move(by: adjustedAwayDirection, duration: 0.5)
        self.runAction(moveAway)
    }
}

