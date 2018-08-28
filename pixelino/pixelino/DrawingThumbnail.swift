//
//  DrawingThumbNail.swift
//  pixelino
//
//  Created by Sandra Grujovic on 26.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

// Data class for handling all saved canvas items in the main menu.
// FIXME: Is the capitalisation ok?
class DrawingThumbnail {
    let imageReference: String
    let fileName: String
    let dateLastChanged: Date
    let image: UIImage
    
    // Dummy initialiser
    init() {
        self.imageReference = "dummyThumbnail"
        self.fileName = "Dummy Name"
        self.dateLastChanged = Date.init()
        self.image = UIImage()
    }
    
    init(fileName: String, image: UIImage) {
        // FIXME: This property is NOT needed
        self.imageReference = "dummy"
        self.fileName = fileName
        self.dateLastChanged = Date.init()
        self.image = image
    }
}
