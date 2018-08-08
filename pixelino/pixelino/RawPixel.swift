//
//  RawPixel.swift
//  pixelino
//
//  Created by Sandra Grujovic on 08.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

// Helper class for making colors exportable to CGImage.
struct RawPixel {
    var r : UInt8
    var g : UInt8
    var b : UInt8
    var a : UInt8
    
    init(inputColor: UIColor) {
        let (r, g, b, a) = inputColor.rgb()
        self.r = UInt8(r!)
        self.g = UInt8(g!)
        self.b = UInt8(b!)
        self.a = UInt8(a!)
    }
}
