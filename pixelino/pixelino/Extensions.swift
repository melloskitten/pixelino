//
//  Extensions.swift
//  pixelino
//
//  Created by Sandra Grujovic on 05.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

// Taken from https://stackoverflow.com/questions/21622129/how-to-compare-two-uicolor-which-have-almost-same-shade-or-range-in-ios
// Extension to deal with equality problems related to UIColor.
public extension UIColor {
    
    func isEqualToColor(color: UIColor, withTolerance tolerance: CGFloat = 0.0) -> Bool {
        
        var r1 : CGFloat = 0
        var g1 : CGFloat = 0
        var b1 : CGFloat = 0
        var a1 : CGFloat = 0
        var r2 : CGFloat = 0
        var g2 : CGFloat = 0
        var b2 : CGFloat = 0
        var a2 : CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return
            fabs(r1 - r2) <= tolerance &&
            fabs(g1 - g2) <= tolerance &&
            fabs(b1 - b2) <= tolerance &&
            fabs(a1 - a2) <= tolerance
    }
    
    func rgb() -> (Int, Int, Int, Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            return (iRed, iGreen, iBlue, iAlpha)
        } else {
            return nil
        }
    }
}

// Taken from https://stackoverflow.com/questions/40882487/how-to-rotate-image-in-swift
// Rotation extension for UIImage because of rotation bug in CGImage generation.
extension UIImage {
    func rotate(radians: CGFloat) -> UIImage? {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            
            defer { UIGraphicsEndImageContext() }
            
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.x, y: -origin.y,
                            width: size.width, height: size.height))
            if let rotatedImage = UIGraphicsGetImageFromCurrentImageContext() {
                return rotatedImage
            }
            return nil
        }
        return nil
    }
}
