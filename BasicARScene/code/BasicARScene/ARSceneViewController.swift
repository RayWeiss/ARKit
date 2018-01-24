//
//  ARSceneViewController.swift
//  BasicARScene
//
//  Created by Raymond Weiss on 1/18/18.
//  Copyright © 2018 ray. All rights reserved.
//

import ARKit

class ARSceneViewController: UIViewController {

    var arSceneView = ARSCNView()
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARSceneView()
        addSphere(atPosition: SCNVector3(0.0, 0.0, -1.0))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arSceneView.session.pause()
    }
    
    // MARK: Add Object Functions
    func addSphere(withRadius radius: Float = 0.1, atPosition posistion: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        let sphere = SCNSphere(radius: CGFloat(radius))
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = posistion
        arSceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    // MARK: Configuration Functions
    func setupARSceneView() {
        // add as subview to view controller's view
        self.view.addSubview(arSceneView)
        
        // handle scene configurations
        configureConstraints()
        configureLighting()
        configureDebugOptions()
        
        
        // set delegate to self
        arSceneView.delegate = self
    }
    
    func configureConstraints() {
        // make AR scene fullscreen
        arSceneView.translatesAutoresizingMaskIntoConstraints = false
        arSceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        arSceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        arSceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        arSceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
    }
    
    func configureLighting() {
        // true by default
        arSceneView.autoenablesDefaultLighting = true
        arSceneView.automaticallyUpdatesLighting = true
    }
    
    func configureDebugOptions() {
        // debug options on by default
        arSceneView.showsStatistics = true
        arSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                    ARSCNDebugOptions.showWorldOrigin]
    }
    
    // MARK: Debug Functions
    func toggleDebugConfiguration() {
        arSceneView.showsStatistics = !arSceneView.showsStatistics
        if arSceneView.debugOptions.isEmpty {
            arSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                        ARSCNDebugOptions.showWorldOrigin]
        } else {
            arSceneView.debugOptions = []
        }
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake {
            handleShake()
        }
    }

    func handleShake() {
        toggleDebugConfiguration()
    }
}

// MARK: Delegate Methods Extension
extension ARSceneViewController: ARSCNViewDelegate {
    // handle session failure
    func session(_ session: ARSession, didFailWithError error: Error) {
        
        // alert user to session failure
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: {action in
            // suspend application
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }))
        self.present(alert, animated: true, completion: nil)
        
        // log session failure error
        print("Session failed due to error: \(error.localizedDescription)")
    }
    
    // handle session interrupt
    func sessionWasInterrupted(_ session: ARSession) {
        print("Session was interrupted")
    }
    
    // handle session interrupt end
    func sessionInterruptionEnded(_ session: ARSession) {
        print("Session interruption ended")
        guard let configuration = session.configuration else { return }
        
//        // runs old session configuration relative to current position
//        arSceneView.session.run(configuration)
        
        // resets session completely
        arSceneView.session.run(configuration,
                                options: [.resetTracking,
                                          .removeExistingAnchors])
    }
    
}
