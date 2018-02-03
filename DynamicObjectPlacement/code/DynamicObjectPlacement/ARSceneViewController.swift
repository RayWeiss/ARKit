//
//  ARSceneViewController.swift
//  DynamicObjectPlacement
//
//  Created by Raymond Weiss on 1/26/18.
//  Copyright © 2018 ray. All rights reserved.
//

import ARKit

class ARSceneViewController: UIViewController {
    
    var arSceneView = ARSCNView()
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupARSceneView()
        addControlPanelView()
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutControlPanelView()
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
        
        // add gesture recognizers
        addTapGestureToSceneView()
        addPinchGestureToSceneView()
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
    
    func addControlPanelView() {
        var arStatusBarHeight = CGFloat(0.0)
        if arSceneView.showsStatistics {
            arStatusBarHeight = CGFloat(20.0)
        }
        let controlPanelHeight = CGFloat(50.0)
        let controlPanelWidth = self.view.bounds.width
        let numberOfButtons = CGFloat(4.0)
        let buttonWidth = controlPanelWidth / numberOfButtons
        
        // Configure control panel
        let controlPanelView = UIView(frame: CGRect(x: 0.0, y: self.view.bounds.height - (arStatusBarHeight + controlPanelHeight), width: controlPanelWidth, height: controlPanelHeight))
        controlPanelView.backgroundColor = .gray
        controlPanelView.alpha = 0.5
        controlPanelView.accessibilityIdentifier = "controlPanelView"
        
        // Configure left button
        let leftButton = UIButton(frame: CGRect(x: buttonWidth * 0.0, y: 0.0, width: buttonWidth, height: controlPanelHeight))
        leftButton.setTitle(" V", for: .normal)
        leftButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        controlPanelView.addSubview(leftButton)
        
        // Configure up button
        let upButton = UIButton(frame: CGRect(x: buttonWidth * 1.0, y: 0.0, width: buttonWidth, height: controlPanelHeight))
        upButton.setTitle("V", for: .normal)
        upButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: CGFloat.pi)
        upButton.addTarget(self, action: #selector(moveUp), for: .touchUpInside)
        controlPanelView.addSubview(upButton)
        
        // Configure down button
        let downButton = UIButton(frame: CGRect(x: buttonWidth * 2.0, y: 0.0, width: buttonWidth, height: controlPanelHeight))
        downButton.setTitle("V", for: .normal)
        downButton.addTarget(self, action: #selector(moveDown), for: .touchUpInside)
        controlPanelView.addSubview(downButton)
        
        // Configure right button
        let rightButton = UIButton(frame: CGRect(x: buttonWidth * 3.0, y: 0.0, width: buttonWidth, height: controlPanelHeight))
        rightButton.setTitle(" V", for: .normal)
        rightButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        controlPanelView.addSubview(rightButton)
        
        // Configure delete button
        let deleteButton = UIButton(frame: CGRect(x: buttonWidth * 4.0, y: 0.0, width: buttonWidth, height: controlPanelHeight))
        deleteButton.setTitle("X", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteSelected), for: .touchUpInside)
        controlPanelView.addSubview(deleteButton)
        
        self.arSceneView.addSubview(controlPanelView)
    }
    
    func layoutControlPanelView() {
        guard let firstSubview = self.arSceneView.subviews.first else {return }
        
        if firstSubview.accessibilityIdentifier == "controlPanelView" {
            let controlPanelView = firstSubview
            
            var arStatusBarHeight = CGFloat(0.0)
            if arSceneView.showsStatistics {
                arStatusBarHeight = CGFloat(20.0)
            }
            
            let controlPanelHeight = CGFloat(50.0)
            let controlPanelWidth = self.arSceneView.bounds.width
            let numberOfButtons = CGFloat(controlPanelView.subviews.count)
            let buttonWidth = controlPanelWidth / numberOfButtons
            
            controlPanelView.frame = CGRect(x: 0.0, y: self.arSceneView.bounds.height - (arStatusBarHeight + controlPanelHeight), width: controlPanelWidth, height: controlPanelHeight)
            
            var buttonIndex = 0
            for button in controlPanelView.subviews {
                button.frame = CGRect(x: buttonWidth * CGFloat(buttonIndex), y: 0.0, width: buttonWidth, height: controlPanelHeight)
                buttonIndex += 1
            }
        }
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
    
    func handleShake() {
        toggleDebugConfiguration()
        layoutControlPanelView()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == UIEventSubtype.motionShake {
            handleShake()
        }
    }
}

// Mark: Current Work
extension ARSceneViewController {
    
    func getSelectedNode() -> SCNNode? {
        for child in arSceneView.scene.rootNode.childNodes {
            if child.isSelected {
                return child
            }
        }
        return nil
    }
    
    @objc func moveLeft(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.moveLeft()
    }
    
    @objc func moveUp(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.moveUp()
    }
    
    @objc func moveDown(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.moveDown()
    }
    
    @objc func moveRight(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.moveRight()
    }
    
    @objc func deleteSelected(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.deleteNode()
    }
    
    // MARK: Tap Gesture
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.didTap(withGestureRecognizer:)))
        self.arSceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: self.arSceneView)
        
        let hitTestResults = self.arSceneView.hitTest(tapLocation)
        
        if let node = hitTestResults.first?.node {
            if node.isSelected {
                node.unselectNode()
            } else {
                // unselect other nodes
                for child in arSceneView.scene.rootNode.childNodes {
                    if child.isSelected {
                        child.unselectNode()
                    }
                }
                node.selectNode()
            }
            
        } else {
            let featurePointHitTestResult = self.arSceneView.hitTest(tapLocation, types: .featurePoint)
            if let firstResult = featurePointHitTestResult.first {
                let hitLocation = firstResult.worldTransform.columns.3
                let position = SCNVector3(hitLocation.x, hitLocation.y, hitLocation.z)
                addSphere(atPosition: position)
            }
        }
    }
    
    // MARK: Pinch gesture
    func addPinchGestureToSceneView() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPinch(withGestureRecognizer:)))
        self.arSceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func didPinch(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        guard let node = getSelectedNode() else { return }

        if recognizer.scale < 1.0 {
            node.moveForward()
        } else {
            node.moveBackward()
        }
        
    }

    // MARK: Add Object Function
    func addSphere(withRadius radius: Float = 0.1, atPosition posistion: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        let sphere = SCNSphere(radius: CGFloat(radius))
        let sphereNode = SCNNode()
        sphereNode.geometry = sphere
        sphereNode.position = posistion
        sphereNode.isSelected = false
        self.arSceneView.scene.rootNode.addChildNode(sphereNode)
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
        // runs old session configuration relative to current position
//        arSceneView.session.run(configuration)
//        guard let configuration = session.configuration else { return }
        
        // resets session completely
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        arSceneView.session.run(configuration,
                                options: [.resetTracking,
                                          .removeExistingAnchors])
    }

}
