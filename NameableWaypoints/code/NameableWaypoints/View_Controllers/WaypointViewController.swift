//
//  WaypointViewController.swift
//  JourneyOfNodes
//
//  Created by Raymond Weiss on 3/1/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class WaypointViewController: UITableViewController {
    var arSceneViewController: ARSceneViewController!
    let noWaypointsTitle = "No waypoints placed"
    var noWaypoints: Bool {
        get{
            return self.arSceneViewController.waypointContainer.count == 0
        }
    }
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    let startEditingButtonTitle = "Edit"
    let endEditingButtonTitle = "Done"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSwipeGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateWaypointTableView()
        self.rightBarButton.isEnabled = !self.noWaypoints
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setEditing(false, animated: false)
        self.rightBarButton.title = self.startEditingButtonTitle
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noWaypoints {
            return 1
        } else {
            return self.arSceneViewController.waypointContainer.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if self.noWaypoints {
            cell.textLabel?.text = self.noWaypointsTitle
        } else {
            cell.textLabel?.text = "Waypoint \(indexPath.row) \(self.arSceneViewController.waypointContainer.waypoints[indexPath.row].name?.replacingOccurrences(of: "_", with: "\t") ?? "yeah")"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.arSceneViewController.waypointContainer.count else { return }
        self.arSceneViewController.waypointBeingTrackedID = self.arSceneViewController.waypointContainer.waypoints[indexPath.row].name ?? ""
    }
    
    // MARK: Waypoint Table View
    func updateWaypointTableView() {
        self.tableView.reloadData()
        let selectedWaypoint = self.arSceneViewController.waypointBeingTrackedID
        guard let selectedWaypointIndex = self.arSceneViewController.waypointContainer.index(of: selectedWaypoint) else { return }
        let ip = IndexPath(row: selectedWaypointIndex, section: 0)
        self.tableView.selectRow(at: ip, animated: false, scrollPosition: .middle)
    }
    
    // MARK: Waypoint Table View Deleting
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return !self.noWaypoints
    }
    
    @IBAction func toggleTableEditing(_ sender: UIBarButtonItem) {
        if self.isEditing {
            self.setEditing(false, animated: true)
            self.rightBarButton.title = self.startEditingButtonTitle
        } else {
            self.setEditing(true, animated: true)
            self.rightBarButton.title = self.endEditingButtonTitle
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        if let name = self.arSceneViewController.waypointContainer.waypoints[indexPath.row].name {
            if let node = self.arSceneViewController.arSceneView.scene.rootNode.childNode(withName: name, recursively: false) {
                node.removeFromParentNode()
            }
        }
        self.arSceneViewController.waypointContainer.removeWaypoint(atIndex: indexPath.row)
        guard self.noWaypoints else { self.tableView.deleteRows(at: [indexPath], with: .fade); return }
        self.rightBarButton.isEnabled = false
        self.rightBarButton.title = self.startEditingButtonTitle
        self.updateWaypointTableView()
    }

    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // MARK: Swipe Gesture
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(WaypointViewController.didSwipe(withGestureRecognizer:)))
        swipeGestureRecognizer.direction = .left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        TransitionHelper.pop(offNavigationController: navigationController, withTransition: TransitionHelper.fromRight)
    }
}
