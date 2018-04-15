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
    let defaultWaypointNamePrefix: String = "Waypoint"
    let noWaypointsTitle: String = "No waypoints placed"
    var noWaypoints: Bool {
        get{
            return self.arSceneViewController.waypointContainer.count == 0
        }
    }
    
    @IBOutlet weak var rightBarButton: UIBarButtonItem!
    let startEditingButtonTitle = "Edit"
    let endEditingButtonTitle = "Done"
    
    let deleteRowActionTitle: String = "Delete"
    let editRowActionTitle: String = "Edit"
    let renameRowActionTitle: String = "Rename"
    let cancelActionTitle: String = "Cancel"
    
    let deleteRowActionColor: UIColor = .red
    let editRowActionColor: UIColor = .purple
    let renameRowActionColor: UIColor = .blue
    
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
            cell.textLabel?.text = self.arSceneViewController.waypointContainer.waypoints[indexPath.row].userName ?? "\(self.defaultWaypointNamePrefix) \(indexPath.row)"
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
    
    // MARK: Waypoint Table View Row Action Handling
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteRowAction = UITableViewRowAction(style: .normal, title: self.deleteRowActionTitle) { (rowAction, indexPath) in
            self.performDelete(forRowAt: indexPath)
        }
        
        let editRowAction = UITableViewRowAction(style: .normal, title: self.editRowActionTitle) { (rowAction, indexPath) in
            self.performEdit(forRowAt: indexPath)
        }
        
        let renameRowAction = UITableViewRowAction(style: .normal, title: self.renameRowActionTitle) { (rowAction, indexPath) in
            self.performRename(forRowAt: indexPath)
        }
        
        deleteRowAction.backgroundColor = self.deleteRowActionColor
        editRowAction.backgroundColor = self.editRowActionColor
        renameRowAction.backgroundColor = self.renameRowActionColor
        
        return [renameRowAction, editRowAction, deleteRowAction]
    }
    
    // MARK: Delete Row Action
    func performDelete(forRowAt indexPath: IndexPath) {
        if let name = self.arSceneViewController.waypointContainer.waypoints[indexPath.row].name {
            if let node = self.arSceneViewController.arSceneView.scene.rootNode.childNode(withName: name, recursively: false) {
                node.removeFromParentNode()
            }
        }
        self.arSceneViewController.waypointContainer.removeWaypoint(atIndex: indexPath.row)
        guard self.noWaypoints else {
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.updateWaypointTableView()
            return
        }
        self.rightBarButton.isEnabled = false
        self.rightBarButton.title = self.startEditingButtonTitle
        self.updateWaypointTableView()
    }

    // MARK: Edit Row Action
    func performEdit(forRowAt indexPath: IndexPath) {
        print("edit \(indexPath)")
        let wp = self.arSceneViewController.waypointContainer.waypoints[indexPath.row]
        let storyboard = UIStoryboard(name: self.arSceneViewController.mainStoryboardName, bundle: nil)
        let editWaypointViewController = storyboard.instantiateViewController(withIdentifier: self.arSceneViewController.editWaypointViewControllerStoryboardID) as! EditWaypointViewController
        editWaypointViewController.arSceneViewController = self.arSceneViewController
        editWaypointViewController.waypointToEdit = wp
        
        guard let navigationController = navigationController else { return }
        navigationController.pushViewController(editWaypointViewController, animated: false)
    }
    
    // MARK: Rename Row Action
    func performRename(forRowAt indexPath: IndexPath) {
        let currentName = self.arSceneViewController.waypointContainer.waypoints[indexPath.row].userName ?? "\(self.defaultWaypointNamePrefix) \(indexPath.row)"
        let renameAlertBox = UIAlertController(title: "\(self.renameRowActionTitle) \(currentName)", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        renameAlertBox.addTextField()
        renameAlertBox.addAction(UIAlertAction(title: self.renameRowActionTitle, style: UIAlertActionStyle.default, handler: { (action) in
            guard let textField = renameAlertBox.textFields?.first else { return }
            guard let newName = textField.text else { return }
            guard !newName.isEmpty else { return }
            self.arSceneViewController.waypointContainer.waypoints[indexPath.row].userName = newName
            self.updateWaypointTableView()
        }))
        renameAlertBox.addAction(UIAlertAction(title: self.cancelActionTitle, style: UIAlertActionStyle.default, handler: nil))
        
        self.present(renameAlertBox, animated: true, completion: nil)
    }
    
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
