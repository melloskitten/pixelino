//
//  GroupDrawCommand.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation

class GroupDrawCommand: Command {
    var drawCommands: Set<DrawCommand>

    init(drawCommands: Set<DrawCommand>) {
        self.drawCommands = drawCommands
    }

    init() {
        self.drawCommands = []
    }

    func execute() {
        drawCommands.forEach { $0.execute() }
    }

    func undo() {
        drawCommands.forEach { $0.undo() }
    }
}

extension GroupDrawCommand: MultiCommand {
    func appendAndExecuteSingle(_ command: Command) {
        guard let drawCommand = command as? DrawCommand else {
            return
        }
        drawCommands.insert(drawCommand)
        drawCommand.execute()
    }
}
