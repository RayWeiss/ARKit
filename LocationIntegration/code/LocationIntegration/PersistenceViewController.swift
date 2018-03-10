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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSwipeGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: Save / Load Buttons
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        print("save tapped")
        guard let nodeToSave = self.arSceneViewController.getWaypointBeingTracked() else { return }
        guard let realWorldConversionMap = self.arSceneViewController.realWorldConversionMap else { return }
        
        let rwNode = RealWorldNode(node: nodeToSave, lat: realWorldConversionMap.0.latitude, lon: realWorldConversionMap.0.longitude)
        
//        self.save(node: nodeToSave)
        self.save(node: rwNode)
    }
    
    @IBAction func loadButtonTapped(_ sender: UIButton) {
        print("load tapped")
//        self.load()
        self.loadRWNode()
    }
    
    // MARK: Save
    func getArchiveURL () -> NSURL {
        // Get the default file manager
        let fileManager = FileManager()// NSFileManager.defaultManager()
        // Get an array of URLs
        let urls = fileManager.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        // Get the document directory
        let documentDirectory = urls.last
        let fileWithPath = documentDirectory?.appendingPathComponent("archive.data")
        // Debug output
        print(">>>Document Directory: \(documentDirectory!)")
        return fileWithPath! as NSURL
    }
    
    func save(node: SCNNode) {
        let archiveFile = self.getArchiveURL().path!
        let success = NSKeyedArchiver.archiveRootObject(node, toFile: archiveFile)
        if !success { print(">>> Archive failed.") }
    }
    
    func save(node: RealWorldNode) {
        let archiveFile = self.getArchiveURL().path!
        let success = NSKeyedArchiver.archiveRootObject(node, toFile: archiveFile)
        if !success { print(">>> Archive failed.") }
    }
    
    // MARK: Load
    func load() {
        let archiveFile = self.getArchiveURL().path!
        // The file will not exist the first time the app is run
        if !FileManager().fileExists(atPath: archiveFile) {
            print(">>> Does not exist: \(archiveFile)")
            return
        }
        //Debugging
        print(">>> archiveURL: \(archiveFile)")
        // Get the archived data
        let unArchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: archiveFile)
        let unArchivedNode = unArchivedData as? SCNNode
        guard let loadedNode = unArchivedNode else { print(">>> Unarchive failed."); return }
        self.arSceneViewController.arSceneView.scene.rootNode.addChildNode(loadedNode)
    }
    
    func loadRWNode() {
        let archiveFile = self.getArchiveURL().path!
        // The file will not exist the first time the app is run
        if !FileManager().fileExists(atPath: archiveFile) {
            print(">>> Does not exist: \(archiveFile)")
            return
        }
        //Debugging
        print(">>> archiveURL: \(archiveFile)")
        // Get the archived data
        let unArchivedData = NSKeyedUnarchiver.unarchiveObject(withFile: archiveFile)
        let unArchivedNode = unArchivedData as? RealWorldNode
        guard let loadedNode = unArchivedNode else { print(">>> Unarchive failed."); return }
        loadedNode.name = "rwnodeILoaded"
        self.arSceneViewController.arSceneView.scene.rootNode.addChildNode(loadedNode)
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
