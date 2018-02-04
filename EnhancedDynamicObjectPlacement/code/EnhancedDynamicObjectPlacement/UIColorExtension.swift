//
//  UIColorExtension.swift
//  EnhancedDynamicObjectPlacement
//
//  Created by Raymond Weiss on 2/4/18.
//  Copyright © 2018 ray. All rights reserved.
//
import UIKit

// Source https://stackoverflow.com/questions/44672594/is-it-possible-to-get-color-name-in-swift

extension UIColor {
    var name: String? {
        switch self {
        case UIColor.black: return "black"
        case UIColor.darkGray: return "darkGray"
        case UIColor.lightGray: return "lightGray"
        case UIColor.white: return "white"
        case UIColor.gray: return "gray"
        case UIColor.red: return "red"
        case UIColor.green: return "green"
        case UIColor.blue: return "blue"
        case UIColor.cyan: return "cyan"
        case UIColor.yellow: return "yellow"
        case UIColor.magenta: return "magenta"
        case UIColor.orange: return "orange"
        case UIColor.purple: return "purple"
        case UIColor.brown: return "brown"
        default: return nil
        }
    }
}
