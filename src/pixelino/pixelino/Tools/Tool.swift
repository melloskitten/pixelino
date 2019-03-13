//
//  Tool.swift
//  pixelino
//
//  Created by Sandra & Johannes
//

import Foundation
import UIKit.UIGestureRecognizer

/// A tool represents a drawing tool and its corresponding tap and drawing handling methods.
/// Each tool has a corresponding DrawingViewController in order to interact with the canvas and
/// its many related objects.
protocol Tool {

    func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: DrawingViewController)
    func handleDrawFrom(_ sender: UIPanGestureRecognizer, _ controller: DrawingViewController)

}
