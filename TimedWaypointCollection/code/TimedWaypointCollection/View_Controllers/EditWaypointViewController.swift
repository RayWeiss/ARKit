//
//  EditWaypointViewController.swift
//  ObjectEditingAbility
//
//  Created by Raymond Weiss on 4/15/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit
import SceneKit

class EditWaypointViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var waypointTitleLabel: UILabel!
    @IBOutlet weak var objectPicker: UIPickerView!
    @IBOutlet weak var colorPicker: UIPickerView!
    @IBOutlet weak var scaleSlider: UISlider!
    @IBOutlet weak var scaleLabel: UILabel!
    
    var arSceneViewController: ARSceneViewController!
    var waypointToEdit: Waypoint!
    
    let objects: [String] = ["box", "capsule", "cone", "cylinder",
                             "sphere", "torus", "tube", "pyramid", "paperPlane.scn", "car.dae"]
    
    let objectsDict: [String: SCNGeometry] = ["box":SCNBox(), "capsule":SCNCapsule(), "cone":SCNCone(), "cylinder":SCNCylinder(),
                                              "sphere":SCNSphere(), "torus":SCNTorus(), "tube":SCNTube(), "pyramid":SCNPyramid()]

    let colors: [UIColor] = [.black, .blue, .brown, .cyan, .darkGray,
                             .gray, .green, .lightGray, .magenta, .orange,
                             .purple, .red, .white, .yellow]
    
    let objectPickerID = "objectPicker"
    let colorPickerID = "colorPicker"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWaypointTitleLabel()
        setupPickerViews()
        setupSlider()
    }
    
    func setupWaypointTitleLabel() {
        self.waypointTitleLabel.text = waypointToEdit.userName
    }
    
    // MARK: Picker View
    func setupPickerViews() {
        setupObjectPickerView()
        setupColorPickerView()
    }
    
    func setupObjectPickerView() {
        let waypointToEditGeometry = self.waypointToEdit.geometry
        var geometryString = "unkown geometry"
        switch waypointToEditGeometry {
        case is SCNBox:
            geometryString = "box"
        case is SCNCapsule:
            geometryString = "capsule"
        case is SCNCone:
            geometryString = "cone"
        case is SCNCylinder:
            geometryString = "cylinder"
        case is SCNSphere:
            geometryString = "sphere"
        case is SCNTorus:
            geometryString = "torus"
        case is SCNTube:
            geometryString = "tube"
        case is SCNPyramid:
            geometryString = "pyramid"
        default:
            return
        }
        
        guard let selectedObjectIndex = objects.index(of: geometryString) else { return }
        objectPicker.selectRow(selectedObjectIndex, inComponent: 0, animated: false)
        objectPicker.reloadComponent(0)
    }
    
    func setupColorPickerView() {
        guard let waypointToEditColor = self.waypointToEdit.geometry?.firstMaterial!.diffuse.contents as? UIColor else { return }
        guard let selectedColorIndex = colors.index(of: waypointToEditColor) else { return }
        colorPicker.selectRow(selectedColorIndex, inComponent: 0, animated: false)
        colorPicker.reloadComponent(0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.accessibilityIdentifier == self.objectPickerID {
            return objects.count
        } else if pickerView.accessibilityIdentifier == self.colorPickerID {
            return colors.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.accessibilityIdentifier == self.objectPickerID {
            return objects[row]
        } else if pickerView.accessibilityIdentifier == self.colorPickerID {
            return colors[row].name
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.accessibilityIdentifier == self.objectPickerID {
            guard let originalColor = self.waypointToEdit.geometry?.firstMaterial!.diffuse.contents as? UIColor else { return }
            if let newGeometry = self.objectsDict[objects[row]] {
                switch newGeometry {
                case is SCNBox:
                    self.waypointToEdit.geometry = newGeometry as! SCNBox
                case is SCNCapsule:
                    self.waypointToEdit.geometry = newGeometry as! SCNCapsule
                case is SCNCone:
                    self.waypointToEdit.geometry = newGeometry as! SCNCone
                case is SCNCylinder:
                    self.waypointToEdit.geometry = newGeometry as! SCNCylinder
                case is SCNSphere:
                    self.waypointToEdit.geometry = newGeometry as! SCNSphere
                case is SCNTorus:
                    self.waypointToEdit.geometry = newGeometry as! SCNTorus
                case is SCNTube:
                    self.waypointToEdit.geometry = newGeometry as! SCNTube
                case is SCNPyramid:
                    self.waypointToEdit.geometry = newGeometry as! SCNPyramid
                default:
                    return
                }
            } else {
                self.waypointToEdit.geometry = self.arSceneViewController.waypointGeometry
            }
            self.waypointToEdit.geometry = waypointToEdit.geometry!.copy() as? SCNGeometry
            self.waypointToEdit.geometry?.firstMaterial = waypointToEdit.geometry?.firstMaterial!.copy() as? SCNMaterial
            self.waypointToEdit.geometry?.firstMaterial!.diffuse.contents = originalColor
            self.waypointToEdit.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            
        } else if pickerView.accessibilityIdentifier == self.colorPickerID {
            self.waypointToEdit.geometry?.firstMaterial!.diffuse.contents = colors[row]
        }
    }
    
    // MARK: Scale Slider
    func setupSlider() {
        let scale = self.waypointToEdit.scale.x
        self.scaleSlider.setValue(Float(scale), animated: false)
        self.scaleLabel.text = String(format: "%.2f", scale)
    }
    
    @IBAction func adjustScale(_ sender: UISlider) {
        let newScale = SCNVector3(sender.value,sender.value,sender.value)
        self.waypointToEdit.scale = newScale
        self.scaleLabel.text = String(format: "%.2f", sender.value)
    }
    
    // MARK: Done Action
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: false)
    }
}

