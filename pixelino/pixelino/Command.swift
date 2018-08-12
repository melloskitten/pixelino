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

protocol MultiCommand {
    func append(command: Command)
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

extension DrawCommand: Hashable {
    var hashValue: Int {
        return pixel.hashValue
    }
    
    static func == (lhs: DrawCommand, rhs: DrawCommand) -> Bool {
        return lhs.pixel == rhs.pixel
    }
}

class GroupDrawCommand: Command {
    var drawCommands: Set<DrawCommand>
    
    init(drawCommands: Set<DrawCommand>) {
        self.drawCommands = drawCommands
    }
    
    init() {
        self.drawCommands = []
    }

    func execute() {
        _ = drawCommands.map { $0.execute() }
    }
    
    func undo() {
        _ = drawCommands.map { $0.undo() }
    }
}

extension GroupDrawCommand: MultiCommand {
    func append(command: Command) {
        guard let drawCommand = command as? DrawCommand else {
            return
        }
        drawCommands.insert(drawCommand)
    }
}

