//
//  RealWorldNode.swift
//  LocationIntegration
//
//  Created by Raymond Weiss on 3/10/18.
//  Copyright © 2018 ray. All rights reserved.
//

import SceneKit

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
    
    func setRealWorldPosition(fromPair pair: (SCNVector3, SCNVector3)) {
        
    }
    
    func setARPosition(fromPair pair: (SCNVector3, SCNVector3)) {
        
    }
}
