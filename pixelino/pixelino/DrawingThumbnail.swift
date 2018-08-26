//
//  DrawingThumbNail.swift
//  pixelino
//
//  Created by Sandra Grujovic on 26.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation

// Data class for handling all saved canvas items in the main menu.
// FIXME: Is the capitalisation ok?
class DrawingThumbnail {
    let imageReference: String
    let fileName: String
    let dateLastChanged: Date
    
    // Dummy initialiser
    init() {
        self.imageReference = "dummyThumbnail"
        self.fileName = "Dummy Name"
        self.dateLastChanged = Date.init()
    }
}
