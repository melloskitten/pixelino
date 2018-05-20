//
//  ViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.05.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    var skView : SKView? = nil
    var skScene : SKScene? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        let SCREEN_HEIGHT = 2436
        let SCREEN_WIDTH = 1125
        let cameraNode = SKCameraNode()
       
        self.view = SKView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        skView = self.view as? SKView
        skScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
       
        
        skScene?.backgroundColor = .blue
        let s = SKShapeNode(rectOf: CGSize(width: 200, height: 200))
        s.fillColor = .yellow
        s.isAntialiased = false
        s.position = CGPoint(x: 400, y: 400)
        
        skScene?.scaleMode = .aspectFit
        skScene?.addChild(s)

        cameraNode.position = CGPoint(x: 100, y:100)
        skScene?.addChild(cameraNode)
        skScene?.camera = cameraNode
        
        // Add gesture handler
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(_:)))
        pinchGestureRecognizer.delegate = self
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        panGestureRecognizer.delegate = self

        view.addGestureRecognizer(pinchGestureRecognizer)
        view.addGestureRecognizer(panGestureRecognizer)
        
        
        skView?.presentScene(skScene)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        // Calculate correct zooming
        var scale = sender.scale
        let absolute = abs(1 - scale)
        scale = scale < 1 ? 1 + absolute : 1 - absolute

        let pinch = SKAction.scale(by: scale, duration: 0.0)
        
        sender.scale = 1.0
        skScene?.camera?.run(pinch)
       
    }
    
    @objc func handlePanFrom(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: skView)
        let pan = SKAction.moveBy(x: -1.0 * translation.x, y:  translation.y, duration: 0)
        skScene?.camera?.run(pan)
        sender.setTranslation(CGPoint.zero, in: skView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
}

