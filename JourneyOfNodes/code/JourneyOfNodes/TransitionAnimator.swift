//
//  TransitionAnimator.swift
//  JourneyOfNodes
//
//  Created by Raymond Weiss on 3/1/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class TransitionAnimator {
    static fileprivate let animationDuration: CFTimeInterval = 0.5
    static fileprivate let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    
    static func pop(offNavigationController nc: UINavigationController, withTransition transition: CATransition) {
        nc.view.layer.add(transition, forKey: kCATransition)
        nc.popViewController(animated: false)
    }
    
    static func push(viewController vc: UIViewController, onNavigationController nc: UINavigationController, withTransition transition: CATransition) {
        nc.view.layer.add(transition, forKey: kCATransition)
        nc.pushViewController(vc, animated: false)
    }
    
    static var fromTop: CATransition {
        get {
            let transition = CATransition()
            transition.duration = self.animationDuration
            transition.timingFunction = self.timingFunction
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromTop
            return transition
        }
    }
    
    static var fromBottom: CATransition {
        get {
            let transition = CATransition()
            transition.duration = self.animationDuration
            transition.timingFunction = self.timingFunction
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromBottom
            return transition
        }
    }
    
    static var fromLeft: CATransition {
        get {
            let transition = CATransition()
            transition.duration = self.animationDuration
            transition.timingFunction = self.timingFunction
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            return transition
        }
    }
    
    static var fromRight: CATransition {
        get {
            let transition = CATransition()
            transition.duration = self.animationDuration
            transition.timingFunction = self.timingFunction
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            return transition
        }
    }
}
