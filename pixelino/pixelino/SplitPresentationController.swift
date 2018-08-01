//
//  SplitController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 01.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

class SplitPresentationController : UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let theView = containerView else {
                return CGRect.zero
            }
            return CGRect(x: 0, y: theView.bounds.height/3.0, width: theView.bounds.width, height: theView.bounds.height/1.0)
        }
    }
}
