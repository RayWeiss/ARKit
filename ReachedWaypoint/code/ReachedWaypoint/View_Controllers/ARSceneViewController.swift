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
    // MARK: AR Properties
    var arSceneView = ARSCNView()
    var arConfiguration = ARWorldTrackingConfiguration()
    var arSessionStarted: Bool = false
    
    // MARK: Auxiliary View Controllers Properties
    var configurationViewController: ConfigurationViewController!
    var persistenceViewController: PersistenceViewController!
    var waypointViewController: WaypointViewController!

    // MARK: Storyboard Properties
    let mainStoryboardName = "Main"
    let configurationViewControllerStoryboardID = "configurationViewController"
    let waypointViewControllerStoryboardID = "waypointViewController"
    let persistenceViewControllerStoryboardID = "persistenceViewController"
    let editWaypointViewControllerStoryboardID = "editWaypointViewController"
    
    // MARK: Location Manager Properties
    let locationManager = CLLocationManager()
    let horizontalLocationAccuracyThreshold: Double = 10.0
    let headingAccuracyThreshold: Double = 20.0
    var bestHorizontalLocationAccuracy: CLLocationAccuracy?
    var realWorldConversionMap: (CLLocationCoordinate2D, SCNVector3)?
    @IBOutlet weak var headingAccuracyLabel: UILabel!
    @IBOutlet weak var headingAlertView: UIView!
    @IBOutlet weak var headingAccuracyThresholdLabel: UILabel!
    
    // MARK: Proximity Display Properties
    var proximityDisplayView = UILabel()
    let proximityDisplayViewTag = 1
    let proximityDisplayViewHeight = CGFloat(50.0)
    let proximityDisplayViewSideMargin = CGFloat(10.0)
    let proximityDisplayViewAlpha = CGFloat(0.5)
    let proximityDisplayViewCornerRadius = CGFloat(10.0)
    let proximityDisplayViewDefaultText = "Waypoint Distance: "
    let proximityDisplayViewDefaultNilText = "N/A"
    let proximityDisplayViewDefaultUnitText = "m"
    
    // MARK: Control Panel Properties
    let controlPanelViewTag = 2
    let controlPanelColor: UIColor = .gray
    let controlPanelAlpha: CGFloat = 0.5
    var arStatusBarHeight: CGFloat {
        get {
            if self.arSceneView.showsStatistics {
                return 20.0
            } else {
                return 0.0
            }
        }
    }
    let controlPanelHeight: CGFloat = 50.0
    var controlPanelWidth: CGFloat {
        get {
            return self.view.bounds.width
        }
    }
    let controlPanelButtonCount: CGFloat = 5.0
    var controlPanelButtonWidth: CGFloat {
        get {
            return self.controlPanelWidth / self.controlPanelButtonCount
        }
    }
    
    // MARK: Object Properties
    let selectableObjectChildName = "selectableChild"
    var defaultObjectToPlaceType: String = "sphere"
    var defaultObjectToPlaceColor: UIColor = .white
    var defaultObejectToPlaceScale: Double = 1.0
    let objectsDict: [String: SCNGeometry] = ["box":SCNBox(), "capsule":SCNCapsule(), "cone":SCNCone(), "cylinder":SCNCylinder(),
                                              "sphere":SCNSphere(), "torus":SCNTorus(), "tube":SCNTube(), "pyramid":SCNPyramid()]
    
    // MARK: Gravity Properties
    var gravityIsOn = false
    let standardGravity = SCNVector3(0, -9.8, 0)
    let noGravity = SCNVector3(0, 0, 0)
    
    // MARK: Waypoint Properties
    var waypointContainer = WaypointContainer()
    let waypointGeometry = SCNBox()
    let waypointColor = UIColor.cyan
    var waypointBeingTrackedID = ""
    var lastWaypointReachedID = ""
    let reachedWaypointMessgae = "Congrats! You reached the waypoint."
    let reachedLastWaypointMessgae = "Congrats! You reached the last waypoint."
    let switchToNextWaypointMessgae = "Switch to next waypoint?"
    let reachedWaypointThresholdDistance:Float = 1.0
    let reachedWaypointColor = UIColor.red
    
    // MARK: Heading Arrow Properties
    let headingArrowSceneFileName = "arrow.scn"
    let headingArrowName = "headingArrow"
    let headingArrowDistanceFromUser: Float = 1.75
    let headingArrowPlacementHeight: Float = -1.5
    var headingArrowDoesNotExist: Bool {
        get {
            return self.arSceneView.scene.rootNode.childNode(withName: self.headingArrowName, recursively: false) == nil
        }
    }
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLocationManager()
        self.setupAuxiliaryViewControllers()
        self.setupAllARConfigurations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //        arSceneView.session.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.arSceneView.frame = self.view.bounds
        self.layoutControlPanelView()
    }
    
    // MARK: AR Configurations
    func runARSession() {
        self.view.addSubview(arSceneView)
        self.arSceneView.session.run(self.arConfiguration)
        self.arSessionStarted = true
    }
    
    func setupAllARConfigurations() {
        self.setupARConfiguration()
        self.setupARSceneView()
        self.setupARSession()
        self.setGravity()
        self.addControlPanelView()
        self.addProximityDisplayView()
    }
    
    func setupARConfiguration() {
        self.arConfiguration.planeDetection = .horizontal
        self.arConfiguration.worldAlignment = .gravityAndHeading
    }
    
    func setupARSceneView() {
        // handle scene configurations
        self.arSceneView.frame = self.view.bounds
        self.configureARLighting()
        self.configureARDebugOptions()
        
        // set delegate to self
        self.arSceneView.delegate = self
        
        // add gesture recognizers
        self.addGestureRecognizersToARSceneView()
    }
    
    func setupARSession() {
        self.arSceneView.session.delegate = self
    }
    
    func configureARLighting() {
        // true by default
        self.arSceneView.autoenablesDefaultLighting = true
        self.arSceneView.automaticallyUpdatesLighting = true
    }
    
    func configureARDebugOptions() {
        // debug options on by default
        self.arSceneView.showsStatistics = true
        self.arSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints,
                                    ARSCNDebugOptions.showWorldOrigin]
    }
    
    // MARK: Location Manager Configuration
    func setupLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    // MARK: Auxiliary View Controllers Configuration
    func setupAuxiliaryViewControllers() {
        self.setupConfigurationViewController()
        self.setupwaypointViewController()
        self.setupPersistenceViewController()
        self.headingAccuracyThresholdLabel.text = " < \(self.headingAccuracyThreshold)"
    }
    
    func setupConfigurationViewController() {
        let sotryboard = UIStoryboard(name: self.mainStoryboardName, bundle: nil)
        self.configurationViewController = sotryboard.instantiateViewController(withIdentifier: self.configurationViewControllerStoryboardID) as! ConfigurationViewController
        self.configurationViewController.arSceneViewController = self
    }
    
    func setupwaypointViewController() {
        let sotryboard = UIStoryboard(name: self.mainStoryboardName, bundle: nil)
        self.waypointViewController = sotryboard.instantiateViewController(withIdentifier: self.waypointViewControllerStoryboardID) as! WaypointViewController
        self.waypointViewController.arSceneViewController = self
    }
    
    func setupPersistenceViewController() {
        let sotryboard = UIStoryboard(name: self.mainStoryboardName, bundle: nil)
        self.persistenceViewController = sotryboard.instantiateViewController(withIdentifier: self.persistenceViewControllerStoryboardID) as! PersistenceViewController
        self.persistenceViewController.arSceneViewController = self
    }
    
    // MARK: Proximity Display Configuration
    func addProximityDisplayView() {
        let statusBarOffset = UIApplication.shared.statusBarFrame.size.height
        self.proximityDisplayView.backgroundColor = UIColor(white: 1, alpha: self.proximityDisplayViewAlpha)
        self.proximityDisplayView.frame = CGRect(x: self.arSceneView.bounds.origin.x + self.proximityDisplayViewSideMargin, y: self.arSceneView.bounds.origin.y + statusBarOffset,
                                                 width: self.arSceneView.bounds.width / 2.5 - self.proximityDisplayViewSideMargin, height: self.proximityDisplayViewHeight)
        self.proximityDisplayView.layer.cornerRadius = self.proximityDisplayViewCornerRadius
        self.proximityDisplayView.clipsToBounds = true
        self.proximityDisplayView.tag = self.proximityDisplayViewTag
        self.proximityDisplayView.numberOfLines = 0
        self.arSceneView.addSubview(self.proximityDisplayView)
    }
    
    func updateProximityDisplayView(withDistance distance: Float?) {
        guard let proximityDisplayView = self.arSceneView.viewWithTag(self.proximityDisplayViewTag) as? UILabel else { return }
        if let d = distance {
            proximityDisplayView.text = self.proximityDisplayViewDefaultText + String(format: "%.2f", d) + " " + proximityDisplayViewDefaultUnitText
        } else {
            proximityDisplayView.text = self.proximityDisplayViewDefaultText + self.proximityDisplayViewDefaultNilText
        }
    }
    
    func manageTrackedWaypointDistance() {
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        guard let waypointBeingTracked = self.getWaypointBeingTracked() else { self.updateProximityDisplayView(withDistance: nil); return }
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let distance = MathHelper.calculateXZdistanceBetween(cameraPosition, waypointBeingTracked.position)
        self.updateProximityDisplayView(withDistance: distance)
    }
    
    // MARK: Control Panel View Configuration
    func addControlPanelView() {
        // Configure control panel
        let controlPanelView = UIView(frame: CGRect(x: 0.0, y: self.view.bounds.height - (self.arStatusBarHeight + self.controlPanelHeight),
                                                    width: self.controlPanelWidth, height: self.controlPanelHeight))
        controlPanelView.backgroundColor = self.controlPanelColor
        controlPanelView.alpha = self.controlPanelAlpha
        controlPanelView.tag = self.controlPanelViewTag
        
        // Configure left button
        let leftButton = UIButton(frame: CGRect(x: self.controlPanelButtonWidth * 0.0, y: 0.0,
                                                width: self.controlPanelButtonWidth, height: self.controlPanelHeight))
        leftButton.setTitle(" V", for: .normal)
        leftButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        leftButton.addTarget(self, action: #selector(moveLeft), for: .touchUpInside)
        controlPanelView.addSubview(leftButton)
        
        // Configure up button
        let upButton = UIButton(frame: CGRect(x: self.controlPanelButtonWidth * 1.0, y: 0.0,
                                              width: self.controlPanelButtonWidth, height: self.controlPanelHeight))
        upButton.setTitle("V", for: .normal)
        upButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: CGFloat.pi)
        upButton.addTarget(self, action: #selector(moveUp), for: .touchUpInside)
        controlPanelView.addSubview(upButton)
        
        // Configure down button
        let downButton = UIButton(frame: CGRect(x: self.controlPanelButtonWidth * 2.0, y: 0.0,
                                                width: self.controlPanelButtonWidth, height: self.controlPanelHeight))
        downButton.setTitle("V", for: .normal)
        downButton.addTarget(self, action: #selector(moveDown), for: .touchUpInside)
        controlPanelView.addSubview(downButton)
        
        // Configure right button
        let rightButton = UIButton(frame: CGRect(x: self.controlPanelButtonWidth * 3.0, y: 0.0,
                                                 width: self.controlPanelButtonWidth, height: self.controlPanelHeight))
        rightButton.setTitle(" V", for: .normal)
        rightButton.titleLabel?.transform  = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        rightButton.addTarget(self, action: #selector(moveRight), for: .touchUpInside)
        controlPanelView.addSubview(rightButton)
        
        // Configure delete button
        let deleteButton = UIButton(frame: CGRect(x: self.controlPanelButtonWidth * 4.0, y: 0.0,
                                                  width: self.controlPanelButtonWidth, height: self.controlPanelHeight))
        deleteButton.setTitle("X", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteSelected), for: .touchUpInside)
        controlPanelView.addSubview(deleteButton)
        
        // Add control panel to arSceneView
        self.arSceneView.addSubview(controlPanelView)
    }
    
    func layoutControlPanelView() {
        guard let controlPanelView = self.arSceneView.viewWithTag(self.controlPanelViewTag) else { return }
        controlPanelView.frame = CGRect(x: 0.0, y: self.arSceneView.bounds.height - (self.arStatusBarHeight + self.controlPanelHeight),
                                        width: self.controlPanelWidth, height: self.controlPanelHeight)
        var buttonIndex = 0
        for button in controlPanelView.subviews {
            button.frame = CGRect(x: self.controlPanelButtonWidth * CGFloat(buttonIndex), y: 0.0, width: self.controlPanelButtonWidth, height: self.controlPanelHeight)
            buttonIndex += 1
        }
    }
    
    // MARK: Location Fucntions
    
    @IBAction func continueAnywaysPressed(_ sender: UIButton) {
        self.headingAlertView.isHidden = true
        self.runARSession()
        self.locationManager.stopUpdatingHeading()
    }
    
    // MARK: Object Interaction
    func addObject(atPosition position: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        guard let anyObject = objectsDict[self.defaultObjectToPlaceType] else {
            addObjectFromFile(fileName: self.defaultObjectToPlaceType, atPosition: position)
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
        
//        objectNode.scale = SCNVector3(0.1,0.1,0.1)
        objectNode.scale = SCNVector3(self.defaultObejectToPlaceScale,self.defaultObejectToPlaceScale,self.defaultObejectToPlaceScale)
        objectNode.position = position
        objectNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        self.arSceneView.scene.rootNode.addChildNode(objectNode)
    }
    
    func addObjectFromFile(fileName name: String, atPosition position: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)) {
        guard let objectScene = SCNScene(named: name) else { return }
        let objectSceneChildNodes = objectScene.rootNode.childNodes
        let objectNode = SelectableNode()
        for childNode in objectSceneChildNodes {
            let childNodeAsSelectable = SelectableNode(geometry: childNode.geometry)
            childNodeAsSelectable.name = self.selectableObjectChildName
            objectNode.addChildNode(childNodeAsSelectable)
        }

        objectNode.position = position
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
    
    // MARK: Waypoint Objects
    func addWaypoint(atPosition position: SCNVector3) {
        let wp = Waypoint()
        
        if let anyObject = objectsDict[self.defaultObjectToPlaceType] {
            switch anyObject {
            case is SCNBox:
                wp.geometry = anyObject as! SCNBox
            case is SCNCapsule:
                wp.geometry = anyObject as! SCNCapsule
            case is SCNCone:
                wp.geometry = anyObject as! SCNCone
            case is SCNCylinder:
                wp.geometry = anyObject as! SCNCylinder
            case is SCNSphere:
                wp.geometry = anyObject as! SCNSphere
            case is SCNTorus:
                wp.geometry = anyObject as! SCNTorus
            case is SCNTube:
                wp.geometry = anyObject as! SCNTube
            case is SCNPyramid:
                wp.geometry = anyObject as! SCNPyramid
            default:
                return
            }
        } else {
            wp.geometry = self.waypointGeometry
        }
        
        wp.geometry = wp.geometry!.copy() as? SCNGeometry
        wp.geometry?.firstMaterial = wp.geometry?.firstMaterial!.copy() as? SCNMaterial
        wp.geometry?.firstMaterial!.diffuse.contents = self.defaultObjectToPlaceColor
        wp.scale = SCNVector3(self.defaultObejectToPlaceScale, self.defaultObejectToPlaceScale, self.defaultObejectToPlaceScale)
        wp.position = position
        wp.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        self.waypointContainer.add(waypoint: wp)
        self.arSceneView.scene.rootNode.addChildNode(wp)
    }
    
    
    func getWaypointBeingTracked() -> SCNNode? {
        return self.arSceneView.scene.rootNode.childNode(withName: self.waypointBeingTrackedID, recursively: false)
    }
    
    // MARK: Reached Wapoints
    func checkForReachingWaypoint() {
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        guard let waypointBeingTracked = self.getWaypointBeingTracked() else { self.updateProximityDisplayView(withDistance: nil); return }
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let distance = MathHelper.calculateXZdistanceBetween(cameraPosition, waypointBeingTracked.position)
        if distance <= self.reachedWaypointThresholdDistance && waypointBeingTracked.name != self.lastWaypointReachedID {
            self.lastWaypointReachedID = waypointBeingTracked.name ?? ""
            self.reachedWaypointAction()
        }
    }
    
    func reachedWaypointAction() {
        self.colorCurrentWaypointReached()
        guard let currentWaypoint = self.getWaypointBeingTracked() else { return }
        if currentWaypoint == self.waypointContainer.waypoints.last {
            self.alertLastWaypoint()
        } else {
            self.alertNextWaypoint()
        }
    }
    
    func alertNextWaypoint() {
        let alert = UIAlertController(title:  reachedWaypointMessgae, message: switchToNextWaypointMessgae, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { alert in
            self.switchToNextWaypoint()
        }))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertLastWaypoint() {
        let alert = UIAlertController(title:  self.reachedLastWaypointMessgae, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func colorCurrentWaypointReached() {
        guard let currentWaypoint = self.getWaypointBeingTracked() else { return }
        currentWaypoint.geometry?.firstMaterial!.diffuse.contents = self.reachedWaypointColor
    }
    
    func switchToNextWaypoint() {
        guard let currentWaypointIndex = self.waypointContainer.index(of: self.waypointBeingTrackedID) else { return }
        let nextWaypointIndex = currentWaypointIndex + 1
        guard nextWaypointIndex < self.waypointContainer.count else { return }
        self.waypointBeingTrackedID = self.waypointContainer.waypoints[nextWaypointIndex].name ?? ""
    }
    
    // MARK: Heading Arrow
    func getArrowSceneNode() -> SCNNode? {
        let name = self.headingArrowSceneFileName
        guard let arrowScene = SCNScene(named: name) else { return nil}
        let arrowSceneChildNodes = arrowScene.rootNode.childNodes
        let arrowNode = SCNNode()
        for childNode in arrowSceneChildNodes {
            arrowNode.addChildNode(childNode)
        }
        arrowNode.rotation = SCNVector4(0.0, 1.0, 0.0, .pi / 2)
        arrowNode.scale = SCNVector3(0.6, 0.6, 0.6)
        arrowNode.name = self.headingArrowName
        return arrowNode
    }
    
    func calculatePositionInFrontOfARCamera() -> SCNVector3? {
        guard let currentFrame = self.arSceneView.session.currentFrame else { return nil }
        let cameraTransform = currentFrame.camera.transform
        let cameraPosition = SCNVector3(cameraTransform.columns.3.x, cameraTransform.columns.3.y, cameraTransform.columns.3.z)
        let cameraDirection = SCNVector3(cameraTransform.columns.2.x, cameraTransform.columns.2.y, cameraTransform.columns.2.z)
        let deltaX = -1 * self.headingArrowDistanceFromUser * cameraDirection.z
        let deltaZ = -1 * self.headingArrowDistanceFromUser * cameraDirection.x
        return SCNVector3(cameraPosition.x + deltaZ, self.headingArrowPlacementHeight, cameraPosition.z + deltaX)
    }
    
    func addHeadingArrowToARScene(atPosition position: SCNVector3) {
        guard let arrowNode = self.getArrowSceneNode() else { return }
        arrowNode.position = position
        self.arSceneView.scene.rootNode.addChildNode(arrowNode)
    }
    
    func addHeadingArrowToARSceneInFrontOfARCamera() {
        guard let positionInFrontOfARCamera = self.calculatePositionInFrontOfARCamera() else { return }
        self.addHeadingArrowToARScene(atPosition: positionInFrontOfARCamera)
    }
    
    func getHeadingArrowNodeInARScene() -> SCNNode? {
        return self.arSceneView.scene.rootNode.childNode(withName: self.headingArrowName, recursively: false)
    }
    
    func updateHeadingArrow(withPosition position: SCNVector3) {
        guard let arrowNode = self.getHeadingArrowNodeInARScene() else { return }
        arrowNode.position = position
    }
    
    func pointHeadingArrow(atNode node: SCNNode) {
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        guard let headingArrowNode = self.getHeadingArrowNodeInARScene() else { return }
        let nodePosition = SCNVector3(node.simdTransform.columns.3.x, node.simdTransform.columns.3.y, node.simdTransform.columns.3.z)
        let cameraPosition = SCNVector3(currentFrame.camera.transform.columns.3.x, currentFrame.camera.transform.columns.3.y, currentFrame.camera.transform.columns.3.z)
        let theta = MathHelper.calculateXZAngleBetweenPositions(nodePosition, cameraPosition, angleMeasure: .radians)
        headingArrowNode.rotation = SCNVector4(0.0, 1.0, 0.0, theta * -1)
    }
    
    func manageHeadingArrow() {
        if self.headingArrowDoesNotExist {
            self.addHeadingArrowToARSceneInFrontOfARCamera()
        } else {
            guard let positionInFrontOfARCamera = self.calculatePositionInFrontOfARCamera() else { return }
            self.updateHeadingArrow(withPosition: positionInFrontOfARCamera)
            guard let waypoint = self.getWaypointBeingTracked() else { return }
            self.pointHeadingArrow(atNode: waypoint)
        }
    }
    
    // MARK: Gravity
    func setGravity() {
        if self.gravityIsOn {
            arSceneView.scene.physicsWorld.gravity = self.standardGravity
        } else {
            arSceneView.scene.physicsWorld.gravity = self.noGravity
        }
    }
    
    // MARK: Gestures
    func addGestureRecognizersToARSceneView() {
        addLeftSwipeGestureRecognizer()
        addRightSwipeGestureRecognizer()
        addUpSwipeGestureRecognizer()
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
        self.configurationViewController.arSceneViewController = self
        TransitionHelper.push(viewController: self.configurationViewController, onNavigationController: navigationController, withTransition: TransitionHelper.fromRight)
    }
    
    // MARK: Right Swipe Gesture
    func addRightSwipeGestureRecognizer() {
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformRightSwipe(withGestureRecognizer:)))
        rightSwipeGestureRecognizer.direction = .right
        self.arSceneView.addGestureRecognizer(rightSwipeGestureRecognizer)
    }
    
    @objc func didPerformRightSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        self.navigateToWaypointViewController()
    }
    
    func navigateToWaypointViewController() {
        guard let navigationController = navigationController else { return }
        self.waypointViewController.arSceneViewController = self
        TransitionHelper.push(viewController: self.waypointViewController, onNavigationController: navigationController, withTransition: TransitionHelper.fromLeft)
    }
    
    // MARK: Up Swipe Gesture
    func addUpSwipeGestureRecognizer() {
        let upSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ARSceneViewController.didPerformUpSwipe(withGestureRecognizer:)))
        upSwipeGestureRecognizer.direction = .up
        self.arSceneView.addGestureRecognizer(upSwipeGestureRecognizer)
    }
    
    @objc func didPerformUpSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        self.navigateToPersistenceViewController()
    }
    
    func navigateToPersistenceViewController() {
        guard let navigationController = navigationController else { return }
        self.persistenceViewController.arSceneViewController = self
        TransitionHelper.push(viewController: self.persistenceViewController, onNavigationController: navigationController, withTransition: TransitionHelper.fromBottom)
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
            if let waypoint = node as? Waypoint {
                self.waypointBeingTrackedID = waypoint.name ?? ""
            } else {
                guard var selectableNode = node as? SelectableNode else { return }
                if selectableNode.name == selectableObjectChildName {
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
        let tapLocation = recognizer.location(in: self.arSceneView)

        let hitTestResults = self.arSceneView.hitTest(tapLocation)

        if hitTestResults.first?.node != nil {
            let featurePointHitTestResult = self.arSceneView.hitTest(tapLocation, types: .featurePoint)
            if let firstResult = featurePointHitTestResult.first {
                let hitLocation = firstResult.worldTransform.columns.3
                let position = SCNVector3(hitLocation.x, hitLocation.y, hitLocation.z)
                self.addWaypoint(atPosition: position)
            }
        }
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
    
}

// MARK: AR Session Delegate Extension
extension ARSceneViewController: ARSessionDelegate {
    // handle frame updates
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        self.manageHeadingArrow()
        self.manageTrackedWaypointDistance()
        self.checkForReachingWaypoint()
    }
}

// MARK: AR Scene View Delegate Extension
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

// MARK: Location Manager Delegate Extention
extension ARSceneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.headingAccuracyLabel.text = String(newHeading.headingAccuracy)
        if newHeading.headingAccuracy < self.headingAccuracyThreshold && newHeading.headingAccuracy > 0.0 {
            self.headingAlertView.isHidden = true
            self.runARSession()
            self.locationManager.stopUpdatingHeading()
        }
//        if newHeading.headingAccuracy > self.headingAccuracyThreshold && newHeading.headingAccuracy > 0.0 {
//            print("waiting on more accurate heading. current: \(newHeading.headingAccuracy)")
//        } else {
//            print("True Heading: \(newHeading.trueHeading)")
//            print("Heading Accuracy: \(newHeading.headingAccuracy)")
//        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard arSessionStarted else { return }
        guard let lastLocation = locations.last else { return }
        self.bestHorizontalLocationAccuracy = lastLocation.horizontalAccuracy
        self.persistenceViewController.updateLocationAccuracyLabel()
        guard lastLocation.horizontalAccuracy < self.horizontalLocationAccuracyThreshold && lastLocation.horizontalAccuracy > 0.0 else { return }
        guard let currentFrame = self.arSceneView.session.currentFrame else { return }
        let cameraPosition = SCNVector3(currentFrame.camera.transform.columns.3.x, currentFrame.camera.transform.columns.3.y, currentFrame.camera.transform.columns.3.z)
        self.realWorldConversionMap = (lastLocation.coordinate, cameraPosition)
        self.locationManager.stopUpdatingLocation()
//        print("RWMAP: \(self.realWorldConversionMap)")
//        if lastLocation.horizontalAccuracy > self.horizontalLocationAccuracyThreshold && lastLocation.horizontalAccuracy > 0.0 {
//            print("waiting on more accurate location. current \(lastLocation.horizontalAccuracy)")
//        } else {
//            print("Current Accuracy: \(lastLocation.horizontalAccuracy)")
//            print("Current Location: \(lastLocation.coordinate)")
//        }
    }
}
