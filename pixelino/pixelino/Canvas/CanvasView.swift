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
    
    init(sceneWidth: Int, sceneHeight: Int, canvasWidth: Int, canvasHeight: Int) {
        canvasScene = SKScene(size: CGSize(width: sceneWidth, height: sceneHeight))
        canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        canvasScene.isUserInteractionEnabled = true
        
        canvas = Canvas(width: canvasWidth, height: canvasHeight)
        
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        
        presentCanvasScene()
    }
    
    init(sceneWidth: Int, sceneHeight: Int, canvasWidth: Int, canvasHeight: Int, colorArray: [UIColor]) {
        canvasScene = SKScene(size: CGSize(width: sceneWidth, height: sceneHeight))
        canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        canvasScene.isUserInteractionEnabled = true
        
        canvas = Canvas(colorArray: colorArray, width: canvasWidth, height: canvasHeight)
        
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        
        presentCanvasScene()
    }
    
    // Add canvas properties to view & show.
    fileprivate func presentCanvasScene() {
        canvasScene.addChild(canvas)
        canvasScene.scaleMode = .aspectFill
        presentScene(canvasScene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
