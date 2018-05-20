//
//  ViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.05.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit
import SpriteKit

let darkGrey = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
let lightGrey = UIColor(red:0.19, green:0.19, blue:0.19, alpha:1.0)

class Pixel : SKShapeNode {


}


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
        skView?.showsFPS = true
        skScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
       
        
        skScene?.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        
        // Generate pixel grid
        let PIXEL_SIZE = 200
        for x in 0..<10 {
            for y in 0..<10 {
                let s = Pixel(rectOf: CGSize(width: PIXEL_SIZE, height: PIXEL_SIZE))
                s.fillColor = .white
                s.isUserInteractionEnabled = true
                s.strokeColor = UIColor.gray
                s.lineWidth = 3
                s.isAntialiased = false
                s.position = CGPoint(x: x * PIXEL_SIZE, y: y * PIXEL_SIZE)
                skScene?.addChild(s)
            }
        }
        
        
        skScene?.scaleMode = .aspectFit

        cameraNode.position = CGPoint(x: 100, y:100)
        skScene?.addChild(cameraNode)
        skScene?.camera = cameraNode
        
        // Add navigation gesture handler
        let zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(_:)))
        zoomGestureRecognizer.delegate = self
      
        let navigatorGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        navigatorGestureRecognizer.minimumNumberOfTouches = 2
        navigatorGestureRecognizer.delegate = self

        let drawGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDrawFrom(_:)))
        drawGestureRecognizer.maximumNumberOfTouches = 1
        
        //FIXME: Adding for debugging
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(_:)))
    
        // Add handlers
        view.addGestureRecognizer(zoomGestureRecognizer)
        view.addGestureRecognizer(navigatorGestureRecognizer)
        view.addGestureRecognizer(drawGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        
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
    
    @objc func handleDrawFrom(_ sender: UIPanGestureRecognizer) {
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = skView?.convert(touchLocation, to: skScene!)

        let nodes = skScene?.nodes(at: touchLocationInScene!)
        
        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                pixel.fillColor = .blue
                //pixel.fillColor = pixel.fillColor == .yellow ? .black : .yellow
            }
        })
        
        
    }
    
    @objc func handleTapFrom(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = skView?.convert(touchLocation, to: skScene!)
        
        let nodes = skScene?.nodes(at: touchLocationInScene!)
        
        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                pixel.fillColor = pixel.fillColor == .yellow ? .black : .yellow
            }
        })
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

