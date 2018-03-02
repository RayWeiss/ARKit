//
//  WaypointViewController.swift
//  JourneyOfNodes
//
//  Created by Raymond Weiss on 3/1/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class WaypointViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var arSceneViewController: ARSceneViewController!
    @IBOutlet weak var waypointPicker: UIPickerView!
    let noWaypointsTitle = "No waypoints placed"
    var noWaypoints: Bool {
        get{
            return self.arSceneViewController.waypoints.count == 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        setupWaypointPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateWaypointPicker()
    }
    
    // MARK: Waypoint Picker
    func setupWaypointPicker() {
        let selectedWaypoint = self.arSceneViewController.waypointBeingTrackedID
        guard let selectedWaypointIndex = self.arSceneViewController.waypoints.index(of: selectedWaypoint) else { return }
        self.waypointPicker.selectRow(selectedWaypointIndex, inComponent: 0, animated: false)
        self.updateWaypointPicker()
    }
    
    func updateWaypointPicker() {
        self.waypointPicker.reloadComponent(0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.noWaypoints {
            return 1
        } else {
            return self.arSceneViewController.waypoints.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.noWaypoints {
            return self.noWaypointsTitle
        } else {
            return self.arSceneViewController.waypoints[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < self.arSceneViewController.waypoints.count else { return }
        self.arSceneViewController.waypointBeingTrackedID = self.arSceneViewController.waypoints[row]
    }
    
    // MARK: Swipe Gesture
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(WaypointViewController.didSwipe(withGestureRecognizer:)))
        swipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        TransitionAnimator.pop(offNavigationController: navigationController, withTransition: TransitionAnimator.fromTop)
    }
}
