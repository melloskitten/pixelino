//
//  PikkoDelegate.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import Foundation
import UIKit

/// Delegate which propagates color changes of the colorpicker to its delegate.
public protocol PikkoDelegate {
    func writeBackColor(color: UIColor)
}
