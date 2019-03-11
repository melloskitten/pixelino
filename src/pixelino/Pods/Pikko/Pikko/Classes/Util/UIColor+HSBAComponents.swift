//
//  UIColor+HSBAComponents.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import Foundation

/// Convenience method for easy access of hue, saturation, brightness and alpha components
/// of a UIColor.
extension UIColor {
    
    fileprivate func getHSBAComponents(_ color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue, saturation, brightness, alpha : CGFloat
        (hue, saturation, brightness, alpha) = (0.0, 0.0, 0.0, 0.0)
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue, saturation, brightness, alpha)
    }
    
    internal var hue: CGFloat {
        return getHSBAComponents(self).0
    }
    
    internal var saturation: CGFloat {
        return getHSBAComponents(self).1
    }
    
    internal var brightness: CGFloat {
        return getHSBAComponents(self).2
    }
    
    internal var alpha: CGFloat {
        return getHSBAComponents(self).3
    }
}
