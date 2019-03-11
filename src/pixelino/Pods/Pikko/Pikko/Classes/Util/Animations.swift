//
//  Animations.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import Foundation
import UIKit

/// Convenience class for animating our selectors.
class Animations {
    
    internal static func animateScale(view: UIView, byScale: CGFloat) {
        UIView.animate(withDuration: 0.25) {
            view.transform = CGAffineTransform(scaleX: byScale,y: byScale)
        }
    }
    
    internal static func animateScaleReset(view: UIView) {
        UIView.animate(withDuration: 0.25) {
            view.transform = CGAffineTransform(scaleX: 1,y: 1)
        }
    }
}
