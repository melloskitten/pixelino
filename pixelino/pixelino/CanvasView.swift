//
//  CanvasView.swift
//  pixelino
//
//  Created by Sandra Grujovic on 11.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import SpriteKit

class CanvasView : SKView {
    
    var canvasScene : SKScene
    var canvas : Canvas
    
    init() {
        
        canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        canvasScene.isUserInteractionEnabled = true
        canvas = Canvas(width: CANVAS_WIDTH, height: CANVAS_HEIGHT)
        
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        
        // Add canvas properties to view & show.
        canvasScene.addChild(canvas)
        canvasScene.scaleMode = .aspectFill
        presentScene(canvasScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
