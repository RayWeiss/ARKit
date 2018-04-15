//
//  AlertHelper.swift
//  LocationIntegrationEnhancement
//
//  Created by Raymond Weiss on 3/16/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class AlertHelper {
    static func alert(withTitle title: String, andMessage message: String, onViewController viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
