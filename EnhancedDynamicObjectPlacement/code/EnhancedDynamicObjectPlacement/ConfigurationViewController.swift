//
//  ConfigurationViewController.swift
//  EnhancedDynamicObjectPlacement
//
//  Created by Raymond Weiss on 2/3/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class ConfigurationViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var objectPicker: UIPickerView!
    @IBOutlet weak var colorPicker: UIPickerView!
    
    let objects: [String] = ["box", "capsule", "cone", "cylinder",
                             "sphere", "torus", "tube", "pyramid"]
    
    let colors: [UIColor] = [.black, .blue, .brown, .cyan, .darkGray,
                             .gray, .green, .lightGray, .magenta, .orange,
                             .purple, .red, .white, .yellow]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSwipeGesture()
        setupPickerViews()
    }

    // MARK: Picker View
    func setupPickerViews() {
        setupObjectPickerView()
        setupColorPickerView()
    }
    
    func setupObjectPickerView() {
        guard let delegate =  UIApplication.shared.delegate as? AppDelegate else { return }
        let selectedObject = delegate.objectToPlaceType
        guard let selectedObjectIndex = objects.index(of: selectedObject) else { return }
        objectPicker.selectRow(selectedObjectIndex, inComponent: 0, animated: false)
        objectPicker.reloadComponent(0)
    }
    
    func setupColorPickerView() {
        guard let delegate =  UIApplication.shared.delegate as? AppDelegate else { return }
        let selectedColor = delegate.objectToPlaceColor
        guard let selectedColorIndex = colors.index(of: selectedColor) else { return }
        colorPicker.selectRow(selectedColorIndex, inComponent: 0, animated: false)
        colorPicker.reloadComponent(0)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.accessibilityIdentifier == "objectPicker" {
            return objects.count
        } else if pickerView.accessibilityIdentifier == "colorPicker" {
            return colors.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.accessibilityIdentifier == "objectPicker" {
            return objects[row]
        } else if pickerView.accessibilityIdentifier == "colorPicker" {
            return colors[row].name
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let delegate =  UIApplication.shared.delegate as? AppDelegate else { return }
        if pickerView.accessibilityIdentifier == "objectPicker" {
            delegate.objectToPlaceType = objects[row]
        } else if pickerView.accessibilityIdentifier == "colorPicker" {
            delegate.objectToPlaceColor = colors[row]
        }
    }
    
    // MARK: Swipe Gesture
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ARSceneViewController.didSwipe(withGestureRecognizer:)))
        swipeGestureRecognizer.direction = .right
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        navigationController.popViewController(animated: true)
    }
}
