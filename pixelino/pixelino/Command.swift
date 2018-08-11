//
//  Command.swift
//  pixelino
//
//  Created by Sandra Grujovic on 11.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

protocol Command {
    func execute()
    func undo()
    func redo()
}

extension Command {
    func redo() {
        execute()
    }
}

class DrawCommand: Command {
    let oldColor: UIColor
    let newColor: UIColor
    let pixel: Pixel
    
    init(oldColor: UIColor, newColor: UIColor, pixel: Pixel) {
        self.oldColor = oldColor
        self.newColor = newColor
        self.pixel = pixel
    }
    
    func execute() {
        Canvas.draw(pixel: pixel, color: newColor)
    }
    
    func undo() {
        Canvas.draw(pixel: pixel, color: oldColor)
    }
    
    
}

