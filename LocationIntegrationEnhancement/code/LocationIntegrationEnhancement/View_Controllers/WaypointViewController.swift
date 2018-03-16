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
            return self.arSceneViewController.waypoints.count == 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.addSwipeGesture()
        
//        Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateWaypointTableView()
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noWaypoints {
            return 1
        } else {
            return self.arSceneViewController.waypoints.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        if self.noWaypoints {
            cell.textLabel?.text = self.noWaypointsTitle
        } else {
            cell.textLabel?.text = self.arSceneViewController.waypoints[indexPath.row].replacingOccurrences(of: "_", with: "\t")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.arSceneViewController.waypoints.count else { return }
        self.arSceneViewController.waypointBeingTrackedID = self.arSceneViewController.waypoints[indexPath.row]
    }
    
    // MARK: Waypoint Table View
    func updateWaypointTableView() {
        self.tableView.reloadData()
        let selectedWaypoint = self.arSceneViewController.waypointBeingTrackedID
        guard let selectedWaypointIndex = self.arSceneViewController.waypoints.index(of: selectedWaypoint) else { return }
        let ip = IndexPath(row: selectedWaypointIndex, section: 0)
        self.tableView.selectRow(at: ip, animated: false, scrollPosition: .middle)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
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
