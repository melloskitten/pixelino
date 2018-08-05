//
//  ViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.05.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit
import SpriteKit
import CoreGraphics

// FIXME: Move constants to appropriate file
let darkGrey = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
let lightGrey = UIColor(red:0.19, green:0.19, blue:0.19, alpha:1.0)
let PIXEL_SIZE = 300

// FIXME: Make this dynamic
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let SCREEN_WIDTH = UIScreen.main.bounds.size.width
// Maximum amount of pixels shown on screen when zooming in.
let MAX_AMOUNT_PIXEL_PER_SCREEN : CGFloat = 4.0
let MAX_ZOOM_OUT : CGFloat = 0.75
// Tolerance for checking equality of UIColors.
let COLOR_EQUALITY_TOLERANCE = 0.1

let animationDuration: TimeInterval = 0.4




class Pixel : SKShapeNode {
    
    override init() {
        super.init()

        self.fillColor = .white
        self.strokeColor = UIColor.gray
        
        // FIXME: Adjust line width to scroll rate
        self.lineWidth = 10
        
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

    private var width: Int = 0
    private var height: Int = 0
    
    init(width: Int, height: Int) {
        // TODO: Refactor this method ASAP
        
        self.width = width
        self.height = height
        
        super.init(texture: nil, color: .cyan, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setUpPixelGrid(width: width, height: height)
        
    }
    
    func getWidth() -> Int {
        return width * PIXEL_SIZE
    }
    
    func getHeight() -> Int {
        return height * PIXEL_SIZE
    }
    
    func getPixelWidth() -> Int {
        return PIXEL_SIZE
    }
    
    func getPixelHeight() -> Int {
        return PIXEL_SIZE
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
    var canvas : Canvas
    
    init() {
        
        canvasScene = SKScene(size: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        canvasScene.backgroundColor = UIColor(red:0.10, green:0.10, blue:0.10, alpha:1.0)
        canvasScene.isUserInteractionEnabled = true
        canvas = Canvas(width: 10, height: 10)
        
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


class ViewController: UIViewController {
    
    var canvasView : CanvasView? = nil
    var toolbarView : UIView? = nil
    var observer : AnyObject?
    var currentDrawingColor : UIColor = .black
    
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
            
        case .portraitUpsideDown:
            return
            
        default:
            break
        }
        
        let rotation = SKAction.rotate(toAngle: rotationAngle, duration: animationDuration, shortestUnitArc: true)
        canvasView?.canvas.run(rotation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupOrientationObserver()
        self.canvasView = CanvasView()
        self.view.addSubview(canvasView!)
    
        registerGestureRecognizer()
        registerToolbar()
        setUpColorPickerButton()
    }
    
    private func setUpColorPickerButton() {
        let colorPickerButton = UIButton()
        colorPickerButton.frame = CGRect(x: SCREEN_WIDTH-70, y: SCREEN_HEIGHT-80, width: 50, height: 50)
        colorPickerButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        colorPickerButton.setImage(UIImage(named: "ColorPicker"), for: .normal)
        colorPickerButton.addTarget(self, action: #selector(colorPickerButtonPressed(sender:)), for: .touchUpInside)
        self.view.addSubview(colorPickerButton)
    }
    
    @objc func colorPickerButtonPressed(sender: UIButton!) {
        let colorPickerVC = ColorPickerViewController()
        colorPickerVC.colorChoiceDelegate = self
        colorPickerVC.transitioningDelegate = self
        colorPickerVC.modalPresentationStyle = .custom
        self.present(colorPickerVC, animated: true, completion: nil)
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

        let pinch = SKAction.scale(by: sender.scale, duration: 0.0)
        
        // Save scale attribute for later inspection, reset the original gesture scale.
        let scale = sender.scale
        sender.scale = 1.0
        
        
        let canvasXScale = canvasView?.canvas.xScale
    
        let canvasWidth = CGFloat((canvasView?.canvas.getWidth())!)
        let augmentedCanvasWidth = canvasWidth * canvasXScale!
        let pixelWidth = CGFloat((canvasView?.canvas.getPixelWidth())!)
        let augmentedPixelWidth = pixelWidth * canvasXScale!
        
      
        // Zooming out based on relative size of canvas width.
        // FIXME: If needed, change this to a relative number for different canvas sizes.
        if (augmentedCanvasWidth/SCREEN_WIDTH) < MAX_ZOOM_OUT && scale < 1 {
            return
        }
        
        // Zooming in based on pixels visible on screen independent of actual canvas size.
        if (augmentedPixelWidth > SCREEN_WIDTH/MAX_AMOUNT_PIXEL_PER_SCREEN) && scale > 1 {
            return
        }
        
        canvasView?.canvas.run(pinch)
    }
    
    @objc func handleDrawFrom(_ sender: UIPanGestureRecognizer) {
        let canvasScene = canvasView?.canvasScene
        
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = canvasView?.convert(touchLocation, to: canvasScene!)
        
        let nodes = canvasScene?.nodes(at: touchLocationInScene!)
        
        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                pixel.fillColor = currentDrawingColor
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
                pixel.fillColor = isEqual(firstColor: pixel.fillColor, secondColor: currentDrawingColor) ? UIColor.white : currentDrawingColor
            }
        })
    }
    
    // Custom method to check for equality for UIColors.
    // FIXME: chosen tolerance value more sophisticatedly.
    private func isEqual(firstColor: UIColor, secondColor: UIColor) -> Bool {
        if firstColor == secondColor {
            return true
        }
        else if firstColor.isEqualToColor(color: secondColor, withTolerance: COLOR_EQUALITY_TOLERANCE) {
            return true
        }
        return false
    }
    
    @objc func handlePanFrom(_ sender: UIPanGestureRecognizer) {
        let canvasScene = canvasView?.canvasScene
        
        let translation = sender.translation(in: canvasView)

        let xScale = canvasScene?.xScale
        let yScale = canvasScene?.yScale

        let pan = SKAction.moveBy(x: translation.x * xScale! , y:  -1.0 * translation.y * yScale!, duration: 0)
        
        canvasView?.canvas.run(pan)
        sender.setTranslation(CGPoint.zero, in: canvasView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Extension for handling half-views such as for the color picker tool.
extension ViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SplitPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// Extension for writing back colors from the color picker view.
extension ViewController: ColorChoiceDelegate {
    func colorChoicePicked(_ color: UIColor) {
        self.currentDrawingColor = color
    }
}

