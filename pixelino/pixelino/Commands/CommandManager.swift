//
//  CommandStack.swift
//  pixelino
//
//  Created by Sandra Grujovic on 13.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation

// Manages all commands for the canvas.
class CommandManager {
    var commandStack = [Command]()
    var undoStack = [Command]()
    
    func execute(_ command: Command) {
        commandStack.append(command)
        command.execute()
        undoStack = []
    }
    
    func undo() {
        guard let command = commandStack.popLast() else {
            return
        }
        undoStack.append(command)
        command.undo()
    }
    
    func redo() {
        guard let command = undoStack.popLast() else {
            return
        }
        commandStack.append(command)
        command.redo()
    }
}
