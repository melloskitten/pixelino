//
//  CanvasView.swift
//  pixelino
//
//  Created by Sandra Grujovic on 11.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import SpriteKit

class CanvasView: SKView {
    
    // MARK: - Attributes.

    var canvasScene: SKScene
    var canvas: Canvas
    
    // MARK: Initialiser.

    init() {
        // This part cannot be refactored because of its position in init.
        canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        canvas = Canvas(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        setUpCanvas()
    }

    init(colorArray: [UIColor], sceneSize: CGSize, canvasSize: CGSize) {
        canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        canvas = Canvas(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        canvas = Canvas(width: Int(canvasSize.width), height: Int(canvasSize.height), colorArray: colorArray)
        setUpCanvas()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Canvas setup and configuration methods.

    fileprivate func setUpCanvas() {
        setSceneProperties()
        presentCanvasScene()
        adjustCanvasZoom()
    }

    fileprivate func setSceneProperties() {
        canvasScene.backgroundColor = DARK_GREY
        canvasScene.isUserInteractionEnabled = true
    }

    fileprivate func presentCanvasScene() {
        canvasScene.addChild(canvas)
        canvasScene.scaleMode = .aspectFill
        presentScene(canvasScene)
    }
    
    /// Zoom into canvas appropriately (so the width fits into the screen width).
    fileprivate func adjustCanvasZoom() {
        
        // Calculate correct zoom factor.
        let adjustedScaleFactor: CGFloat = SCREEN_WIDTH / canvas.getScaledCanvasWidth()
        canvas.setScale(adjustedScaleFactor)
        
        // Reposition canvas to the middle of the screen.
        if let skView = canvasScene.view {
            canvas.position = skView.center
        }
    }
}
