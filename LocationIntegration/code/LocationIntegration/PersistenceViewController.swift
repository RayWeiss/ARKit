//
//  PersistenceViewController.swift
//  LocationIntegration
//
//  Created by Raymond Weiss on 3/9/18.
//  Copyright © 2018 ray. All rights reserved.
//

import UIKit

class PersistenceViewController: UIViewController {
    
    var arSceneViewController: ARSceneViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSwipeGesture()
    }
    
    
    // MARK: Swipe Gesture
    func addSwipeGesture() {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(PersistenceViewController.didSwipe(withGestureRecognizer:)))
        swipeGestureRecognizer.direction = .down
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    @objc func didSwipe(withGestureRecognizer recognizer: UISwipeGestureRecognizer) {
        guard let navigationController = navigationController else { return }
        TransitionAnimator.pop(offNavigationController: navigationController, withTransition: TransitionAnimator.fromTop)
    }
}
