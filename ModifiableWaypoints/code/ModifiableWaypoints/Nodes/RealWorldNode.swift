//
//  RealWorldNode.swift
//  LocationIntegration
//
//  Created by Raymond Weiss on 3/10/18.
//  Copyright © 2018 ray. All rights reserved.
//

import SceneKit
import CoreLocation

class RealWorldNode: SCNNode {
    var latitude: Double?
    var longitude: Double?
    
    override public init() {
        super.init()
    }
    
    public init(node: SCNNode, lat: Double, lon: Double) {
        self.latitude = lat
        self.longitude = lon
        super.init()
        self.geometry = node.geometry
        self.scale = node.scale
        self.position = node.position
        self.name = node.name
    }
    
    public init(node: SCNNode) {
        super.init()
        self.geometry = node.geometry
        self.scale = node.scale
        self.position = node.position
        self.name = node.name
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(self.latitude, forKey: "latitude")
        aCoder.encode(self.longitude, forKey: "longitude")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.latitude = aDecoder.decodeObject(forKey: "latitude") as? Double
        self.longitude = aDecoder.decodeObject(forKey: "longitude") as? Double
    }
    
    func setRealWorldPosition(fromPair pair: (CLLocationCoordinate2D, SCNVector3)) {
        let metersPerDegreeLatitude = MathHelper.metersPerDegreeLatitude(atDegreesLatitude: pair.0.latitude)
        let metersPerDegreeLongitude = MathHelper.metersPerDegreeLongitude(atDegreesLatitude: pair.0.latitude)
        
        let dX = Double(self.position.x - pair.1.x)
        let dZ = Double(pair.1.z - self.position.z)
        let dLon = dX / metersPerDegreeLongitude
        let dLat = dZ / metersPerDegreeLatitude
        self.longitude = pair.0.longitude + dLon
        self.latitude = pair.0.latitude + dLat
    }
    
    func setARPosition(fromPair pair: (CLLocationCoordinate2D, SCNVector3)) {
        guard let lat = self.latitude else { print("rwNode lat not set"); return }
        guard let lon = self.longitude else { print("rwNode lon not set"); return }
        let metersPerDegreeLatitude = MathHelper.metersPerDegreeLatitude(atDegreesLatitude: pair.0.latitude)
        let metersPerDegreeLongitude = MathHelper.metersPerDegreeLongitude(atDegreesLatitude: pair.0.latitude)
        
        let dLon = lon - pair.0.longitude
        let dLat = pair.0.latitude - lat
        let dX = Float(dLon * metersPerDegreeLongitude)
        let dZ = Float(dLat * metersPerDegreeLatitude)
        self.position.x = pair.1.x + dX
        self.position.z = pair.1.z + dZ
    }
}
