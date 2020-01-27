//
//  DrawCommand.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

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

extension DrawCommand: Hashable {
    
    // WARNING: Might become a problem.
    func hash(into hasher: inout Hasher) {
        hasher.combine(pixel.hashValue)
    }
    
    static func == (lhs: DrawCommand, rhs: DrawCommand) -> Bool {
        return lhs.pixel == rhs.pixel
    }
}
