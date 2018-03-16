//
//  SelectableNode.swift
//  EnhancedDynamicObjectPlacement
//
//  Created by Raymond Weiss on 2/4/18.
//  Copyright © 2018 ray. All rights reserved.
//

import SceneKit

class SelectableNode: SCNNode {
    var isSelected: Bool = false
    
    override public init() {
        super.init()
    }
    
    public init(geometry: SCNGeometry?) {
        super.init()
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func selectNode() {
        isSelected = true
        for child in self.childNodes {
            child.geometry?.firstMaterial?.blendMode = .multiply
        }
        self.geometry?.firstMaterial?.blendMode = .multiply
    }
    
    func unselectNode() {
        isSelected = false
        for child in self.childNodes {
            child.geometry?.firstMaterial?.blendMode = .alpha
        }
        self.geometry?.firstMaterial?.blendMode = .alpha
        
    }
}

