//
//  Bucket.swift
//  pixelino
//
//  Created by Sandra & Johannes.
//

import Foundation
import UIKit.UIGestureRecognizer

/// This class resembles the typical bucket functionality of a drawing tool.
/// Users can tap on a pixel, and the enclosing area of pixels that share the same base
/// color as the pixel you tapped will be colored in a specified target color.
class Bucket: Tool {
    
    /// Handles a tap which results in bucket-filling the area that encloses the pixel.
    /// Look at `colorNeighboredPixels` for more information on the bucket area coloring
    /// functionality.
    func handleTapFrom(_ sender: UITapGestureRecognizer, _ controller: DrawingViewController) {
        
        if let canvasView = controller.canvasView {
            
            // Frequently used variables.
            let canvasScene = canvasView.canvasScene
            let canvas = canvasView.canvas
            
            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)
            
            // Get the tapped pixel.
            let nodes = canvasScene.nodes(at: touchLocationInScene)
            
            // Initialize a new GroupDrawCommand.
            controller.groupDrawCommand = GroupDrawCommand()
            
            nodes.forEach({ (node) in
                if let pixel = node as? Pixel {
                    
                    // Grab the pixel coordinates of the tapped pixel in order to set
                    // a starting point for the bucket-fill coloring.
                    let pixelCoordinates = canvas.getPosition(pixel: pixel)
                    
                    colorNeighboredPixels(canvas,
                                          startCoordinate: pixelCoordinates,
                                          baseColor: pixel.fillColor,
                                          targetColor: controller.currentDrawingColor,
                                          controller)
                    
                    controller.commandManager.execute(controller.groupDrawCommand)
                }
            })
        }
    }
    
    /// Recursive algorithm that traverses the canvas starting from a particular pixel based
    /// on a starting coordinate and then coloring its neighbors (if possible).
    ///
    /// - Parameters:
    ///   - canvas: the canvas where the pixels are located.
    ///   - startCoordinate: starting coordinate following the regular cartesian axis
    ///     more information on this can be found in the method `getPixel`on the `Canvas`
    ///     object.
    ///   - baseColor: the fill color of the first pixel that was clicked by the user.
    ///   - targetColor: the color that the pixels need to be colored to.
    ///   - controller: reference to drawing controller for access to controller variables.
    func colorNeighboredPixels(_ canvas: Canvas,
                               startCoordinate: (Int, Int),
                               baseColor: UIColor,
                               targetColor: UIColor,
                               _ controller: DrawingViewController) {
        
        // Base Case 1:
        // Make sure there is a pixel at the given coordinate.
        if let pixel = canvas.getPixel(x: startCoordinate.0, y: startCoordinate.1) {
            
            // Base Case 2:
            // Stop if the pixel's fill color is not the color you started with
            // and if you reached the end of an area that had the same targetColor
            // you wanted to color.
            if !pixel.fillColor.isEqualToColor(color: baseColor, withTolerance: 0.0001)
                || pixel.fillColor.isEqualToColor(color: targetColor, withTolerance: 0.0001) {
                return
            }
            
            // Create drawCommand and append to the groupDrawCommand to be executed
            // later when the recursion is over.
            let drawCommand = DrawCommand(oldColor: pixel.fillColor,
                                          newColor: targetColor,
                                          pixel: pixel)
            
            controller.groupDrawCommand.appendAndExecuteSingle(drawCommand)
            
            // Recursion steps:
            
            // Look at left pixel.
            colorNeighboredPixels(canvas,
                                  startCoordinate: (startCoordinate.0-1, startCoordinate.1),
                                  baseColor: baseColor,
                                  targetColor: targetColor,
                                  controller)
            
            // Look at right pixel.
            colorNeighboredPixels(canvas,
                                  startCoordinate: (startCoordinate.0+1, startCoordinate.1),
                                  baseColor: baseColor,
                                  targetColor: targetColor,
                                  controller)
            
            // Look at upper pixel.
            colorNeighboredPixels(canvas,
                                  startCoordinate: (startCoordinate.0, startCoordinate.1+1),
                                  baseColor: baseColor,
                                  targetColor: targetColor,
                                  controller)
            
            // Look at upper pixel.
            colorNeighboredPixels(canvas,
                                  startCoordinate: (startCoordinate.0, startCoordinate.1-1),
                                  baseColor: baseColor,
                                  targetColor: targetColor,
                                  controller)
        
        }
    }
    
    /// - NOTE: Purposely left empty. UX-wise, pulling the finger along the screen
    /// when using the bucket tool does not make any sense.
    func handleDrawFrom(_ sender: UIPanGestureRecognizer, _ controller: DrawingViewController) {}
    
}
