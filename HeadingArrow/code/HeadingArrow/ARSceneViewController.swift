//
//  ARSceneViewController.swift
//  DynamicObjectPlacement
//
//  Created by Raymond Weiss on 1/26/18.
//  Copyright © 2018 ray. All rights reserved.
//

import ARKit
import CoreLocation

class ARSceneViewController: UIViewController {
    
    var arSceneView = ARSCNView()
    var arConfiguration = ARWorldTrackingConfiguration()
    let locationManager = CLLocationManager()
    var configurationViewController: ConfigurationViewController!
    
    var defaultObjectToPlaceType: String = "sphere"
    var defaultObjectToPlaceColor: UIColor = .white
    
    let objectsDict: [String: SCNGeometry] = ["box":SCNBox(), "capsule":SCNCapsule(), "cone":SCNCone(), "cylinder":SCNCylinder(),
                                              "sphere":SCNSphere(), "torus":SCNTorus(), "tube":SCNTube(), "pyramid":SCNPyramid()]
    
    var gravityIsOn = false
    
    var directionalArrowDoesNotExist: Bool {
        get {
            if self.arSceneView.scene.rootNode.childNode(withName: "directionalArrow", recursively: false) == nil {
                return true
            } else {
                return false
            }
        }
    }
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupLocationManager()
        setupARConfiguration()
        setupConfigurationViewController()
        setupARSceneView()
        setupARSession()
        addControlPanelView()
        setGravity()
//        addNorthmarker()
//        addPointer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        arSceneView.session.run(self.arConfiguration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        arSceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutControlPanelView()
    }
    
    // MARK: Configuration Functions
    func setupARConfiguration() {
        self.arConfiguration.planeDetection = .horizontal
//        self.arConfiguration.worldAlignment = .gravityAndHeading
    }
    
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
        self.locationManager.requestWhenInUseAuthorization()
    }
    
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
        addGestureRecognizersToSceneView()
    }
    
    func setupARSession() {
        self.arSceneView.session.delegate = self
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
    
    func setupConfigurationViewController() {
        let sotryboard = UIStoryboard(name: "Main", bundle: nil)
        self.configurationViewController = sotryboard.instantiateViewController(withIdentifier: "configurationViewController") as! ConfigurationViewController
        self.configurationViewController.arSceneViewController = self
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
    
    // MARK: Object Interaction
    func addObject(atPosition posistion: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        guard let anyObject = objectsDict[self.defaultObjectToPlaceType] else {
            addObjectFromFile(fileName: self.defaultObjectToPlaceType, atPosition: posistion)
            return
        }
        
        let objectNode = SelectableNode()
        
        switch anyObject {
        case is SCNBox:
            objectNode.geometry = anyObject as! SCNBox
        case is SCNCapsule:
            objectNode.geometry = anyObject as! SCNCapsule
        case is SCNCone:
            objectNode.geometry = anyObject as! SCNCone
        case is SCNCylinder:
            objectNode.geometry = anyObject as! SCNCylinder
        case is SCNSphere:
            objectNode.geometry = anyObject as! SCNSphere
        case is SCNTorus:
            objectNode.geometry = anyObject as! SCNTorus
        case is SCNTube:
            objectNode.geometry = anyObject as! SCNTube
        case is SCNPyramid:
            objectNode.geometry = anyObject as! SCNPyramid
        default:
            return
        }
        
        objectNode.geometry = objectNode.geometry!.copy() as? SCNGeometry   // copy to unshare geometry
        objectNode.geometry?.firstMaterial = objectNode.geometry?.firstMaterial!.copy() as? SCNMaterial   // copy to unshare material
        
        objectNode.geometry?.firstMaterial!.diffuse.contents = self.defaultObjectToPlaceColor
        
        objectNode.scale = SCNVector3(0.1,0.1,0.1)
        objectNode.position = posistion
        objectNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.arSceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    func addObjectFromFile(fileName name: String, atPosition posistion: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        guard let objectScene = SCNScene(named: name) else { return }
        let objectSceneChildNodes = objectScene.rootNode.childNodes
        let objectNode = SelectableNode()
        for childNode in objectSceneChildNodes {
            let childNodeAsSelectable = SelectableNode(geometry: childNode.geometry)
            childNodeAsSelectable.name = "selectableChild"
            objectNode.addChildNode(childNodeAsSelectable)
        }

        objectNode.position = posistion
        self.arSceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    func getSelectedNode() -> SelectableNode? {
        for child in arSceneView.scene.rootNode.childNodes {
            if child is SelectableNode {
                let selectableNode = child as! SelectableNode
                if selectableNode.isSelected {
                    return selectableNode
                }
            }
        }
        return nil
    }
    
    @objc func moveLeft(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        let cameraTransform = currentFrame.camera.transform
        node.moveLeft(ofCamera: cameraTransform)
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
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        let cameraTransform = currentFrame.camera.transform
        node.moveRight(ofCamera: cameraTransform) 
    }
    
    @objc func deleteSelected(_ sender: UIButton) {
        guard let node = getSelectedNode() else { return }
        node.deleteNode()
    }
    
    // MARK:Gravity
    func setGravity() {
        if self.gravityIsOn {
            arSceneView.scene.physicsWorld.gravity = SCNVector3(0, -9.8, 0)
        } else {
            arSceneView.scene.physicsWorld.gravity = SCNVector3(0, 0, 0)
        }
    }
    
    // MARK: Gestures
    func addGestureRecognizersToSceneView() {
        addLeftSwipeGestureRecognizer()
        addTapGestureRecognizers()
        addPinchGestureRecognizer()
    }
    
    // MARK: Left Swipe Gesture
    func addLeftSwipeGestureRecognizer() {
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformLeftSwipe(withGestureRecognizer:)))
        leftSwipeGestureRecognizer.direction = .left
        self.arSceneView.addGestureRecognizer(leftSwipeGestureRecognizer)
    }
    
    @objc func didPerformLeftSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        self.navigateToConfigurationViewController()
    }
    
    func navigateToConfigurationViewController() {
        guard let navigationController = navigationController else { return }
        navigationController.pushViewController(self.configurationViewController, animated: true)
    }
    
    // MARK: Tap Gestures
    func addTapGestureRecognizers() {
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformDoubleTap(withGestureRecognizer:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformSingleTap(withGestureRecognizer:)))
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        let twoFingerSingleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformTwoFingerSingleTap(withGestureRecognizer:)))
        twoFingerSingleTapGestureRecognizer.numberOfTouchesRequired = 2
        twoFingerSingleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        
        self.arSceneView.addGestureRecognizer(doubleTapGestureRecognizer)
        self.arSceneView.addGestureRecognizer(singleTapGestureRecognizer)
        self.arSceneView.addGestureRecognizer(twoFingerSingleTapGestureRecognizer)
    }
    
    @objc func didPerformSingleTap(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        let tapLocation = recognizer.location(in: self.arSceneView)
        
        let hitTestResults = self.arSceneView.hitTest(tapLocation)
        
        if let node = hitTestResults.first?.node {
            guard var selectableNode = node as? SelectableNode else { return }
            if selectableNode.name == "selectableChild" {
                if let parent = selectableNode.parent {
                    if parent is SelectableNode {
                        let parentAsSelectable = parent as! SelectableNode
                        selectableNode = parentAsSelectable
                    }
                }
            }
            
            if selectableNode.isSelected {
                selectableNode.unselectNode()
            } else {
                if let selectedNode = getSelectedNode() {
                    selectedNode.unselectNode()
                }
                selectableNode.selectNode()
            }
            
        } else {
            let featurePointHitTestResult = self.arSceneView.hitTest(tapLocation, types: .featurePoint)
            if let firstResult = featurePointHitTestResult.first {
                let hitLocation = firstResult.worldTransform.columns.3
                let position = SCNVector3(hitLocation.x, hitLocation.y, hitLocation.z)
                addObject(atPosition: position)
            }
        }
    }
    
    @objc func didPerformTwoFingerSingleTap(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        print("Two finger tap")
    }
    
    @objc func didPerformDoubleTap(withGestureRecognizer recognizer: UITapGestureRecognizer) {
        print("tap tap")
        self.addDirectionalArrowToARSceneInFrontOfARCamera()
    }
    
    // MARK: Pinch Gesture
    func addPinchGestureRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPinch(withGestureRecognizer:)))
        self.arSceneView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    @objc func didPinch(withGestureRecognizer recognizer: UIPinchGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        guard let node = getSelectedNode() else { return }
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        let cameraTransform = currentFrame.camera.transform
        
        if recognizer.scale < 1.0 {
            node.moveTowards(camera: cameraTransform)
        } else {
            node.moveAwayFrom(camera: cameraTransform)
        }
        
    }
    
    // MARK: Shake for Debug Options
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
    
    // MARK: Directional Arrow
    func getArrowSceneNode() -> SCNNode? {
        let name = "arrow.scn"
        guard let arrowScene = SCNScene(named: name) else { print("could not get arrow scene"); return nil}
        let arrowSceneChildNodes = arrowScene.rootNode.childNodes
        let arrowNode = SCNNode()
        for childNode in arrowSceneChildNodes {
            arrowNode.addChildNode(childNode)
        }
        arrowNode.rotation = SCNVector4(0.0, 1.0, 0.0, .pi / 2)
        arrowNode.scale = SCNVector3(0.6, 0.6, 0.6)
        arrowNode.name = "directionalArrow"
        return arrowNode
    }
    
    func calculatePositionInFrontOfARCamera() -> SCNVector3? {
        let distance: Float = 1.75
        guard let currentFrame = self.arSceneView.session.currentFrame else { return nil }
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let cameraDirection = SCNVector3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
        let deltaX = -1 * distance * cameraDirection.z
        let deltaZ = -1 * distance * cameraDirection.x
        return SCNVector3(cameraPosition.x + deltaZ, -1.5, cameraPosition.z + deltaX)
    }
    
    func addDirectionalArrowToARSceneInFrontOfARCamera() {
        guard let positionInFrontOfARCamera = self.calculatePositionInFrontOfARCamera() else { return }
        self.addDirectionalArrowToARScene(atPosition: positionInFrontOfARCamera)
    }

    func addDirectionalArrowToARScene(atPosition position: SCNVector3) {
        guard let arrowNode = self.getArrowSceneNode() else { return }
        arrowNode.position = position
        self.arSceneView.scene.rootNode.addChildNode(arrowNode)
    }

    func getDirectionalArrowNodeInARScene() -> SCNNode? {
        return self.arSceneView.scene.rootNode.childNode(withName: "directionalArrow", recursively: false)
    }
    
    func updateDirectionalArrow(withPosition position: SCNVector3) {
        guard let arrowNode = self.getDirectionalArrowNodeInARScene() else { return }
        arrowNode.position = position
    }
    
    func manageDirectionalArrow() {
        if self.directionalArrowDoesNotExist {
            self.addDirectionalArrowToARSceneInFrontOfARCamera()
        } else {
            guard let positionInFrontOfARCamera = self.calculatePositionInFrontOfARCamera() else { return }
            self.updateDirectionalArrow(withPosition: positionInFrontOfARCamera)
        }
    }
    
    func addPointer() {
        let name = "arrow.scn"
        let position = SCNVector3(0.0, 0.0, -0.5)
        
        guard let objectScene = SCNScene(named: name) else { print("could not get arrow scene"); return }
        let objectSceneChildNodes = objectScene.rootNode.childNodes
        let objectNode = SCNNode()
        for childNode in objectSceneChildNodes {
            objectNode.addChildNode(childNode)
        }
        
        objectNode.position = position
        objectNode.rotation = SCNVector4(0.0, 1.0, 0.0, .pi / 2)
        objectNode.scale = SCNVector3(0.25, 0.25, 0.25)
        self.arSceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    func addDirectionalArrow() {
        let followerShape = SCNSphere(radius: 0.1)
        let followerNode = SCNNode()
        followerNode.geometry = followerShape
        followerNode.geometry = followerNode.geometry!.copy() as? SCNGeometry
        followerNode.geometry?.firstMaterial = followerNode.geometry?.firstMaterial!.copy() as? SCNMaterial
        followerNode.geometry?.firstMaterial!.diffuse.contents = UIColor.red
        followerNode.name = "follower"
        
        guard let positionInFrontOfCamera = self.calculatePositionInFrontOfARCamera() else { return }
        followerNode.position = positionInFrontOfCamera
        arSceneView.scene.rootNode.addChildNode(followerNode)
    }
    
    func addNorthmarker() {
        let northMarkerShape = SCNSphere(radius: 0.01)
        let northMarkerNode = SCNNode()
        northMarkerNode.geometry = northMarkerShape
        northMarkerNode.geometry = northMarkerNode.geometry!.copy() as? SCNGeometry
        northMarkerNode.geometry?.firstMaterial = northMarkerNode.geometry?.firstMaterial!.copy() as? SCNMaterial
        northMarkerNode.geometry?.firstMaterial!.diffuse.contents = UIColor.green
        northMarkerNode.name = "northMarker"
        northMarkerNode.position = SCNVector3(0, 0, -1)
        arSceneView.scene.rootNode.addChildNode(northMarkerNode)
    }
    
}

// MARK: Delegate Methods Extension
extension ARSceneViewController: ARSessionDelegate {
    // handle frame updates
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        if self.directionalArrowDoesNotExist {
//            self.addDirectionalArrowToARSceneInFrontOfARCamera()
//        }
//        guard let followerNode = self.arSceneView.scene.rootNode.childNode(withName: "directionalArrow", recursively: false) else { return }
//        guard let positionInFrontOfCamera = self.calculatePositionInFrontOfARCamera() else { return }
//        followerNode.position = positionInFrontOfCamera
        self.manageDirectionalArrow()
    }
}

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

extension ARSceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print(newHeading.trueHeading)
    }
}
