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
