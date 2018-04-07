//
//  WaypointContainer.swift
//  ModifiableWaypoints
//
//  Created by Raymond Weiss on 3/20/18.
//  Copyright © 2018 ray. All rights reserved.
//

import SceneKit
import Foundation
import CoreLocation

class WaypointContainer: NSObject, NSCoding {
    var waypoints: [Waypoint] = []
    var count: Int {
        get {
            return self.waypoints.count
        }
    }
    
    override init() {
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(waypoints, forKey: "waypoints")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.waypoints = (aDecoder.decodeObject(forKey: "waypoints") as? [Waypoint])!
    }
    
    func add(waypoint: Waypoint) {
        waypoint.name = self.getNextWaypointID()
        self.waypoints.append(waypoint)
    }
    
    func removeWaypoint(atIndex index: Int) {
        self.waypoints.remove(at: index)
    }
    
    func removeWaypoint(withName name: String) {
        for (index, waypoint) in waypoints.enumerated() {
            if waypoint.name == name {
                waypoints.remove(at: index)
            }
        }
    }
    
    func addWaypoints(toNode node: SCNNode) {
        self.waypoints.forEach { waypoint in
            node.addChildNode(waypoint)
        }
    }
    
    func index(of: String) -> Int? {
        for (index, waypoint) in waypoints.enumerated() {
            if waypoint.name == of {
                return index
            }
        }
        return nil
    }
    
    func getNextWaypointID() -> String {
        return Date().getCurrentDatetimeString()
    }
    
    func setGeographicCoordinates(fromPair pair: (CLLocationCoordinate2D, SCNVector3)) {
        waypoints.forEach { waypoint in
            waypoint.setGeographicCoordinates(fromPair: pair)
        }
    }
    
    func setARPosition(fromPair pair: (CLLocationCoordinate2D, SCNVector3)) {
        waypoints.forEach { waypoint in
            waypoint.setARPosition(fromPair: pair)
        }
    }
}
