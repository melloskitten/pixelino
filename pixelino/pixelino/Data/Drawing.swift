//
//  Drawing.swift
//  pixelino
//
//  Created by Sandra Grujovic on 27.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

class Drawing {
    let colorArray: [UIColor]
    let width: Int
    let height: Int
    
    init(_ colorArray: [UIColor], _ width: Int, _ height: Int) {
        self.colorArray = colorArray
        self.width = width
        self.height = height
    }
}
