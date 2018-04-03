//
//  PersistenceViewController.swift
//  LocationIntegration
//
//  Created by Raymond Weiss on 3/9/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit
import SceneKit
class PersistenceViewController: UIViewController {
    
    var arSceneViewController: ARSceneViewController!
    let persistedFilename: String = "archive.data"
    
    let errorTitle: String = "Error"
    let successTitle: String = "Success"
    
    let locationAccuracySaveErrorMessage: String = "Can't save nodes until location is more accurate"
    let locationAccuracyLoadErrorMessage: String = "Can't load nodes until location is more accurate"
    
    let savedWaypointsMessage: String = "Saved waypoints."
    let loadedWaypointsMessage: String = "Loaded waypoints."
    
    let savedWaypointsErrorMessage: String = "Couldn't save waypoints."
    
    let filePathErrorMessage: String = "Couldn't get filepath."
    let documentsDirectoryErrorMessage: String = "Couldn't get documents directory to save data to."
    
    @IBOutlet weak var locationAccuracyLabel: UILabel!
    @IBOutlet weak var locationAccuracyThresholdLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSwipeGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupLabels()
    }
    
    // MARK: Labels
    func setupLabels() {
        self.locationAccuracyThresholdLabel.text = "< \(self.arSceneViewController.horizontalLocationAccuracyThreshold)"
        guard let accuracy = self.arSceneViewController.bestHorizontalLocationAccuracy else { return }
        self.locationAccuracyLabel.text = String(accuracy)
    }
    
    func updateLocationAccuracyLabel() {
        guard self.isViewLoaded else { return }
        guard let accuracy = self.arSceneViewController.bestHorizontalLocationAccuracy else {
            self.locationAccuracyLabel.text = "N/A"
            return
        }
        self.locationAccuracyLabel.text = String(accuracy)
    }
    
    // MARK: Buttons
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        self.save(waypointContainer: self.arSceneViewController.waypointContainer)
    }
    
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        self.loadWaypointsContainer()
    }
    
    // MARK: Save
    func save(waypointContainer: WaypointContainer) {
        guard let realWorldConversionMap = self.arSceneViewController.realWorldConversionMap else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.locationAccuracySaveErrorMessage, onViewController: self)
            return
        }
        waypointContainer.setGeographicCoordinates(fromPair: realWorldConversionMap)
        guard let filepath = self.getPath(ofFile: self.persistedFilename) else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.filePathErrorMessage, onViewController: self)
            return
        }
        guard NSKeyedArchiver.archiveRootObject(waypointContainer, toFile: filepath) else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.savedWaypointsErrorMessage, onViewController: self)
            return
        }
        AlertHelper.alert(withTitle: self.successTitle, andMessage: self.savedWaypointsMessage, onViewController: self)
    }
    
    // MARK: Load
    func loadWaypointsContainer() {
        guard let realWorldConversionMap = self.arSceneViewController.realWorldConversionMap else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.locationAccuracyLoadErrorMessage, onViewController: self)
            return
        }
        guard let filepath = self.getPath(ofFile: self.persistedFilename) else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.filePathErrorMessage, onViewController: self)
            return
        }
        guard FileManager().fileExists(atPath: filepath) else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: "Save file doesn't exist.", onViewController: self)
            return
        }
        guard let unarchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: filepath) else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: "Couldn't load data from device.", onViewController: self)
            return
        }
        
        guard let unarchivedWaypointContainer = unarchivedData as? WaypointContainer else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: "Couldn't load data as a WaypointContainer.", onViewController: self)
            return
        }
        unarchivedWaypointContainer.setARPosition(fromPair: realWorldConversionMap)
        unarchivedWaypointContainer.addWaypoints(toNode: self.arSceneViewController.arSceneView.scene.rootNode)
        self.arSceneViewController.waypointContainer = unarchivedWaypointContainer
        self.arSceneViewController.waypointBeingTrackedID = unarchivedWaypointContainer.waypoints.first?.name ?? ""
        AlertHelper.alert(withTitle: self.successTitle, andMessage: self.loadedWaypointsMessage, onViewController: self)
    }
    
    // MARK: Sandbox interaction functions
    func getPath(ofFile filename: String) -> String? {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).last else {
            AlertHelper.alert(withTitle: self.errorTitle, andMessage: self.documentsDirectoryErrorMessage, onViewController: self)
            return nil
        }
        let url = documentsDirectory.appendingPathComponent(filename) as NSURL
        return url.path
    }
    
    // MARK: Swipe Gesture
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PersistenceViewController.didSwipe(withGestureRecognizer:)))
        swipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        TransitionHelper.pop(offNavigationController: navigationController, withTransition: TransitionHelper.fromTop)
    }
}
