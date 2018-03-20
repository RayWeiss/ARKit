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
    var waypoints: [Waypoint]
    var count: Int {
        get {
            return self.waypoints.count
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(waypoints, forKey: "waypoints")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.waypoints = (aDecoder.decodeObject(forKey: "waypoints") as? [Waypoint])!
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
