//
//  Constants.swift
//  pixelino
//
//  Created by Sandra Grujovic on 28.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

let DARK_GREY = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
let LIGHT_GREY = UIColor(red:0.19, green:0.19, blue:0.19, alpha:1.0)
let PIXEL_SIZE = 300

// FIXME: Make this dynamic
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
// Maximum amount of pixels shown on screen when zooming in.
let MAX_AMOUNT_PIXEL_PER_SCREEN: CGFloat = 4.0
let MAX_ZOOM_OUT: CGFloat = 0.75
// Tolerance for checking equality of UIColors.
let COLOR_EQUALITY_TOLERANCE: CGFloat = 0.1

let animationDuration: TimeInterval = 0.4
let CANVAS_WIDTH = 20
let CANVAS_HEIGHT = 20
