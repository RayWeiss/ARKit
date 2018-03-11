//
//  MathHelper.swift
//  LocationIntegration
//
//  Created by Raymond Weiss on 3/10/18.
//  Copyright © 2018 ray. All rights reserved.
//
import Foundation
import SceneKit

class MathHelper {
    static func metersPerDegreeLatitude(atDegreesLatitude latitude: Double) -> Double {
        let rads = latitude * .pi / 180
        return 111132.92 - 559.82 * cos(2 * rads) + 1.175 * cos(4 * rads) - 0.0023 * cos(6 * rads)
    }
    
    static func metersPerDegreeLongitude(atDegreesLatitude latitude: Double) -> Double {
        let rads = latitude * .pi / 180
        return 111412.84 * cos(rads) - 93.5 * cos(3 * rads) + 0.118 * cos(5 * rads)
    }
    
    static func calculateXZAngleBetweenPositions(_ a: SCNVector3, _ b: SCNVector3, angleMeasure measure: AngleMeasure) -> Float {
        let deltaX = a.x - b.x
        let deltaZ = a.z - b.z
        var thetaDeg = atan(deltaZ / deltaX) * (180 / .pi)
        
        if deltaX < 0.0 && deltaZ > 0.0 {
            thetaDeg = 180 + thetaDeg
        } else if deltaX < 0.0 && deltaZ < 0.0 {
            thetaDeg = 180 + thetaDeg
        } else if deltaX > 0.0 && deltaZ < 0.0 {
            thetaDeg = 360 + thetaDeg
        }
        
        if case .degrees = measure {
            return thetaDeg
        } else if case .radians = measure {
            return thetaDeg / (180 / .pi)
        } else {
            return 0.0
        }
    }
    
}
