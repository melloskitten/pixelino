//
//  ViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.05.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit
import SpriteKit

// FIXME: Move constants to appropriate file

let darkGrey = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
let lightGrey = UIColor(red:0.19, green:0.19, blue:0.19, alpha:1.0)
let PIXEL_SIZE = 500

// FIXME: Make this dynamic
let SCREEN_HEIGHT = 2436
let SCREEN_WIDTH = 1125

let animationDuration: TimeInterval = 0.4




class Pixel : SKShapeNode {
    
    override init() {
        super.init()

        self.fillColor = .white
        self.strokeColor = UIColor.gray
        
        // FIXME: Adjust line width to scroll rate
        self.lineWidth = 3
        
        let rect = UIBezierPath(rect: CGRect(x: 0, y: 0, width: PIXEL_SIZE, height: PIXEL_SIZE))
        self.path = rect.cgPath
        self.isUserInteractionEnabled = true
        self.isAntialiased = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Canvas : SKSpriteNode {
    
    let grid = [[Pixel]]()

    
    init(width: Int, height: Int) {
        // TODO: Refactor this method ASAP
        
        super.init(texture: nil, color: .cyan, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        self.position = CGPoint(x:500, y:0)
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setUpPixelGrid(width: width, height: height)
        
    }
    
    private func setUpPixelGrid(width: Int, height: Int) {
        for x in 0..<width {
            for y in 0..<height {
                
                let xPos = Int(-self.size.width / 2) + x * Int(PIXEL_SIZE)
                let yPos = Int(-self.size.height / 2) + y * Int(PIXEL_SIZE)
                
                let pixel = Pixel()
                pixel.position.x = CGFloat(xPos)
                pixel.position.y = CGFloat(yPos)
                
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
    private var camera : SKCameraNode
    var canvas : Canvas
    
    init() {
        
        self.canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        self.canvasScene.isUserInteractionEnabled = true
        
        
        self.camera = SKCameraNode()
        self.camera.position = CGPoint(x: 500, y: 500)
        

        
        self.canvasScene.camera = camera
        canvas = Canvas(width: 10, height: 10)
        canvasScene.addChild(camera)
        super.init(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))


        self.canvasScene.addChild(canvas)
        self.canvasScene.scaleMode = .aspectFill
        
        presentScene(self.canvasScene)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class ViewController: UIViewController {
    
    var canvasView : CanvasView? = nil
    var toolbarView : UIView? = nil
    var observer : AnyObject?
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    
    override var prefersStatusBarHidden: Bool {
        get {
            return true
        }
    }
    
    func orientationChanged (_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        var rotationAngle : CGFloat = 0
        
        switch orientation {
        case .landscapeLeft:
            rotationAngle = -CGFloat.pi / 2
            
        case .landscapeRight:
            rotationAngle = CGFloat.pi / 2
            
        case .portrait:
            break
            
        default:
            break
        }
        
        let rotation = SKAction.rotate(toAngle: rotationAngle, duration: animationDuration)
        canvasView?.canvas.run(rotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOrientationObserver()

        self.canvasView = CanvasView()
        self.view.addSubview(canvasView!)
     
        registerGestureRecognizer()
        registerToolbar()
    }
    
    private func setupOrientationObserver() {
        observer = NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil, using: orientationChanged)
    }
    
    private func registerToolbar() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        toolbarView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: screenHeight-100), size: CGSize(width: screenWidth, height: 100 )))
        toolbarView?.backgroundColor = lightGrey
        
        self.view.addSubview(toolbarView!)
    }
    
    private func registerGestureRecognizer() {
        
        // Set up gesture recognizer
        let zoomGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchFrom(_:)))
        zoomGestureRecognizer.delegate = self
        
        let navigatorGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanFrom(_:)))
        navigatorGestureRecognizer.minimumNumberOfTouches = 2
        navigatorGestureRecognizer.delegate = self
        
        let drawGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDrawFrom(_:)))
        drawGestureRecognizer.maximumNumberOfTouches = 1
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(_:)))
        
        // Add to view
        view.addGestureRecognizer(zoomGestureRecognizer)
        view.addGestureRecognizer(navigatorGestureRecognizer)
        view.addGestureRecognizer(drawGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handlePinchFrom(_ sender: UIPinchGestureRecognizer) {
        // Calculate correct zooming
        var scale = sender.scale
        
        // This condition ensures that the user is not overcrossing their fingers while zooming
        if scale < 1 {
        
        let absolute = abs(1 - scale)
        scale = scale < 1 ? 1 + absolute : 1 - absolute
        
        let pinch = SKAction.scale(by: scale, duration: 0.0)
        
        sender.scale = 1.0
            canvasView?.canvasScene.camera?.run(pinch)
        }
        
    }
    
    @objc func handleDrawFrom(_ sender: UIPanGestureRecognizer) {
        let canvasScene = canvasView?.canvasScene
        
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
        let canvasScene = canvasView?.canvasScene
        
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
        let canvasScene = canvasView?.canvasScene
        
        let translation = sender.translation(in: canvasView)

        let xScale = canvasScene?.camera?.xScale
        let yScale = canvasScene?.camera?.yScale
        let pan = SKAction.moveBy(x: -1.0 * translation.x * xScale! , y:  translation.y * yScale!, duration: 0)
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

