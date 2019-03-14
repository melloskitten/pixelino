//
//  Paintbrush.swift
//  pixelino
//
//  Created by Sandra & Johannes
//

import Foundation
import UIKit.UIGestureRecognizer

/// This class resembles the typical paintbrush functionality of a drawing tool.
/// Users can tap on a pixel to color it, or they can draw along the screen to
/// create brush strokes.
class Paintbrush: Tool {

    /// Handles painting a single pixel via tap on it.
    func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: DrawingViewController) {

        if let canvasScene = controller.canvasView?.canvasScene, let canvasView = controller.canvasView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            // Get the tapped pixel.
            let nodes = canvasScene.nodes(at: touchLocationInScene)

            nodes.forEach({ (node) in
                if let pixel = node as? Pixel {

                    let drawCommand = DrawCommand(oldColor: pixel.fillColor,
                                                  newColor: controller.currentDrawingColor,
                                                  pixel: pixel)

                    controller.commandManager.execute(drawCommand)
                }
            })
        }
    }

    /// Handles painting a brush stroke via a pan accross the canvas.
    ///
    /// - NOTE: Group draw commands are needed because otherwise we cannot handle the continuous feedback
    /// we get from the handleDrawFrom() method to generate a single paintbrush stroke from the gesture.
    /// That's why we collect all single-pixel draw commands and append it ot the class variable .groupDrawCommand.
    /// Additionally, by using .groupDrawCommand rather than immediately executing a single pixel draw,
    /// We can implement proper "undo" and "redo" behaviour that undos or redos the entire stroke
    /// as opposed to undoing/redoing each pixel of a stroke.
    func handleDrawFrom(_ sender: UIPanGestureRecognizer, _ controller: DrawingViewController) {

        // Initialise group draw command and tear down when needed.
        switch sender.state {
        case .began:
            controller.groupDrawCommand = GroupDrawCommand()
        case .ended:
            controller.commandManager.execute(controller.groupDrawCommand)
        default:
            break
        }

        if let canvasScene = controller.canvasView?.canvasScene, let canvasView = controller.canvasView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            let nodes = canvasScene.nodes(at: touchLocationInScene)

            // Get the touched pixel.
            nodes.forEach({ (node) in
                if let pixel = node as? Pixel {
                    let drawCommand = DrawCommand(oldColor: pixel.fillColor,
                                                  newColor: controller.currentDrawingColor,
                                                  pixel: pixel)

                    // Append the pixel to the current groupDrawCommand so it can be executed later.
                    controller.groupDrawCommand.appendAndExecuteSingle(drawCommand)
                }
            })
        }
    }

}
