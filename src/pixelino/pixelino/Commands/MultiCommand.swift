//
//  MultiCommand.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
protocol MultiCommand {
    func appendAndExecuteSingle(_ command: Command)
}
