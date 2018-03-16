//
//  DateExtension.swift
//  LocationIntegrationEnhancement
//
//  Created by Raymond Weiss on 3/16/18.
//  Copyright © 2018 ray. All rights reserved.
//

import Foundation

extension Date {
    func getCurrentDatetimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy_HH:ss:mm"
        return formatter.string(from: self)
    }
}
