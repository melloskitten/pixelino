//
//  CommandStack.swift
//  pixelino
//
//  Created by Sandra Grujovic on 13.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation

// Manages all commands for the canvas.
class CommandStack {
    var commandStack = [Command]()
    var undoStack = [Command]()
    
    func append(_ command: Command) {
        commandStack.append(command)
        undoStack = []
        }
    
    func undo() -> Command? {
        guard let command = commandStack.popLast() else {
            return nil
        }
        undoStack.append(command)
        return command
    }
    
    func redo() -> Command? {
        guard let command = undoStack.popLast() else {
            return nil
        }
        commandStack.append(command)
        return command
    }
}
