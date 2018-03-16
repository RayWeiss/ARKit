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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSwipeGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Buttons
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let nodeToSave = self.arSceneViewController.getWaypointBeingTracked() else {
            AlertHelper.alert(withTitle: "Error", andMessage: "No waypoint selected to save.", onViewController: self)
            return
        }        
        let rwNode = RealWorldNode(node: nodeToSave)
        self.save(rwNode: rwNode)
    }
    
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        self.loadRWNode()
    }
    
    // MARK: Save
    func save(rwNode: RealWorldNode) {
        guard let realWorldConversionMap = self.arSceneViewController.realWorldConversionMap else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Can't save nodes until location is more accurate", onViewController: self)
            return
        }
        rwNode.setRealWorldPosition(fromPair: realWorldConversionMap)
        guard let filepath = self.getPath(ofFile: self.persistedFilename) else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't get filepath.", onViewController: self)
            return
        }
        guard NSKeyedArchiver.archiveRootObject(rwNode, toFile: filepath) else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't save node.", onViewController: self)
            return
        }
        AlertHelper.alert(withTitle: "Success", andMessage: "Saved node.", onViewController: self)
    }
    
    // MARK: Load
    func loadRWNode() {
        guard let realWorldConversionMap = self.arSceneViewController.realWorldConversionMap else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Can't load nodes until location is more accurate", onViewController: self)
            return
        }
        guard let filepath = self.getPath(ofFile: self.persistedFilename) else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't get filepath.", onViewController: self)
            return
        }
        guard FileManager().fileExists(atPath: filepath) else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Save file doesn't exist.", onViewController: self)
            return
        }
        guard let unarchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: filepath) else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't load data from device.", onViewController: self)
            return
        }
        
        guard let unarchivedRWNode = unarchivedData as? RealWorldNode else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't load data at a RealWorldNode.", onViewController: self)
            return
        }
        unarchivedRWNode.name = "rwnodeILoaded"
        unarchivedRWNode.setARPosition(fromPair: realWorldConversionMap)
        self.arSceneViewController.arSceneView.scene.rootNode.addChildNode(unarchivedRWNode)
        AlertHelper.alert(withTitle: "Success", andMessage: "Loaded node.", onViewController: self)
    }
    
    // MARK: Sandbox interaction functions
    func getPath(ofFile filename: String) -> String? {
        guard let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).last else {
            AlertHelper.alert(withTitle: "Error", andMessage: "Couldn't get documents directory to save data to.", onViewController: self)
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
        TransitionAnimator.pop(offNavigationController: navigationController, withTransition: TransitionAnimator.fromTop)
    }
}
