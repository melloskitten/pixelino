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
let PIXEL_SIZE = 200
// FIXME: make this dynamic
let SCREEN_HEIGHT = 2436
let SCREEN_WIDTH = 1125


class Pixel : SKShapeNode {
    init(x: Int, y: Int) {
        super.init()

        self.position = CGPoint(x: x * PIXEL_SIZE, y: y * PIXEL_SIZE)
        self.fillColor = .white
        self.strokeColor = UIColor.gray
        self.lineWidth = 3
        
        self.path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: PIXEL_SIZE, height: PIXEL_SIZE)).cgPath
        self.isUserInteractionEnabled = true
        self.isAntialiased = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Canvas : SKShapeNode {
    
    let grid = [[Pixel]]()
    
    init(width: Int, height: Int) {
        super.init()
        
        for x in 0..<width {
            for y in 0..<height {
                let pixel = Pixel(x: x, y: y)
                //grid[x][y] = s
                self.addChild(pixel)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CanvasView : SKView {
    
    var canvasScene : SKScene
    var camera : SKCameraNode
    
    init() {
        
        self.canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))

        self.canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        self.canvasScene.isUserInteractionEnabled = true
        self.camera = SKCameraNode()
        self.camera.position = CGPoint(x: 100, y: 100)
        
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))

        
        self.canvasScene.addChild(camera)
        self.canvasScene.camera = camera
        let canvas = Canvas(width: 10, height: 10)
        self.canvasScene.addChild(canvas)
        self.canvasScene.scaleMode = .aspectFill
        
        presentScene(self.canvasScene)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController {
    
    var canvasView : SKView? = nil
    var canvasScene : SKScene? = nil
    var toolbarView : UIView? = nil
    
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Setup scene and view
        self.canvasView = CanvasView()
        self.canvasScene = canvasView?.scene
        self.view = canvasView
        
        // Add handlers
        let zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(_:)))
        zoomGestureRecognizer.delegate = self
        
        let navigatorGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        navigatorGestureRecognizer.minimumNumberOfTouches = 2
        navigatorGestureRecognizer.delegate = self
        
        let drawGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDrawFrom(_:)))
        drawGestureRecognizer.maximumNumberOfTouches = 1
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(_:)))
        
        view.addGestureRecognizer(zoomGestureRecognizer)
        view.addGestureRecognizer(navigatorGestureRecognizer)
        view.addGestureRecognizer(drawGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
        
        // Set up the tool bar
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        toolbarView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: screenHeight-100), size: CGSize(width: screenWidth, height: 100 )))
        toolbarView?.backgroundColor = lightGrey
        
        self.view.addSubview(toolbarView!)
    }
    
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        // Calculate correct zooming
        var scale = sender.scale
        let absolute = abs(1 - scale)
        scale = scale < 1 ? 1 + absolute : 1 - absolute
        
        let pinch = SKAction.scale(by: scale, duration: 0.0)
        
        sender.scale = 1.0
        canvasScene?.camera?.run(pinch)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // FIXME: perform nice animation on draw view and no animaton for the menu.
        
        let MENU_BAR_HEIGHT : CGFloat = 100.0
        var subViews = self.view.subviews
        if subViews.isEmpty {
            return
        }
        
        // Fetch screen size
        let screenWidth = size.width
        let screenHeight = size.height
        
        let subView = subViews[0]
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            subView.frame = CGRect(x: screenWidth - MENU_BAR_HEIGHT, y: 0 , width: MENU_BAR_HEIGHT, height: screenHeight)
        case .landscapeRight:
            subView.frame = CGRect(x: 0, y: 0 , width: MENU_BAR_HEIGHT, height: screenHeight)
        case .portrait:
            subView.frame = CGRect(x: 0, y:screenHeight - MENU_BAR_HEIGHT , width: screenWidth, height: MENU_BAR_HEIGHT)
        default: break
        }
        
        /*coordinator.animate(alongsideTransition: nil, completion:
            {_ in
                UIView.setAnimationsEnabled(true)
        })
        
        UIView.setAnimationsEnabled(false)*/
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    @objc func handleDrawFrom(_ sender: UIPanGestureRecognizer) {
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = canvasView?.convert(touchLocation, to: canvasScene!)
        
        let nodes = canvasScene?.nodes(at: touchLocationInScene!)
        
        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                pixel.fillColor = .blue
            }
        })
        
        
    }
    
    @objc func handleTapFrom(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = canvasView?.convert(touchLocation, to: canvasScene!)
        
        let nodes = canvasScene?.nodes(at: touchLocationInScene!)
        
        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                pixel.fillColor = pixel.fillColor == .yellow ? .black : .yellow
            }
        })
    }
    
    @objc func handlePanFrom(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: canvasView)
        let pan = SKAction.moveBy(x: -1.0 * translation.x, y:  translation.y, duration: 0)
        canvasScene?.camera?.run(pan)
        sender.setTranslation(CGPoint.zero, in: canvasView)
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

