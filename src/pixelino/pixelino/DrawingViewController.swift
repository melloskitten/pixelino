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
import CoreData

class DrawingViewController: UIViewController {

    var commandManager = CommandManager()
    var canvasView: CanvasView?
    var toolbarView: UIView?
    var observer: AnyObject?
    var currentDrawingColor: UIColor = .black
    var groupDrawCommand: GroupDrawCommand = GroupDrawCommand()
    var previousDrawing: Drawing?

    override var shouldAutorotate: Bool {
        return false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    func orientationChanged (_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        var rotationAngle: CGFloat = 0

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

        let rotation = SKAction.rotate(toAngle: rotationAngle, duration: ANIMATION_DURATION, shortestUnitArc: true)
        canvasView?.canvas.run(rotation)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupOrientationObserver()
        setUpCanvasView()
        registerGestureRecognizer()
        registerToolbar()
        setUpTabBarItems()
    }

    fileprivate func setUpCanvasView() {
        if let colorArray = previousDrawing?.colorArray {
            self.canvasView = CanvasView(colorArray: colorArray, sceneSize: CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT), canvasSize: CGSize(width: CANVAS_WIDTH, height: CANVAS_HEIGHT))
            self.view.addSubview(canvasView!)
        } else {
            self.canvasView = CanvasView()
            self.view.addSubview(canvasView!)
        }
    }

    fileprivate func setUpTabBarIcon(frame: CGRect, imageEdgeInsets: UIEdgeInsets, imageName: String, action: Selector) {
        let tabBarIcon = UIButton()
        tabBarIcon.frame = frame
        tabBarIcon.imageEdgeInsets = imageEdgeInsets
        tabBarIcon.setImage(UIImage(named: imageName), for: .normal)
        tabBarIcon.addTarget(self, action: action, for: .touchUpInside)
        self.view.addSubview(tabBarIcon)
    }

    fileprivate func setUpTabBarItems() {
        let standardImageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        // Export button.
        setUpTabBarIcon(frame: CGRect(x: SCREEN_WIDTH-70, y: SCREEN_HEIGHT-80, width: 50, height: 50), imageEdgeInsets: standardImageEdgeInsets, imageName: "Export", action: #selector(exportButtonPressed(sender:)))

        // Color Picker button.
        setUpTabBarIcon(frame: CGRect(x: SCREEN_WIDTH-170, y: SCREEN_HEIGHT-80, width: 50, height: 50), imageEdgeInsets: standardImageEdgeInsets, imageName: "ColorPicker", action: #selector(colorPickerButtonPressed(sender:)))

        // Undo button.
        setUpTabBarIcon(frame: CGRect(x: SCREEN_WIDTH-370, y: SCREEN_HEIGHT-80, width: 50, height: 50), imageEdgeInsets: standardImageEdgeInsets, imageName: "Undo", action: #selector(undoButtonPressed(sender:)))

        // Redo button.
        setUpTabBarIcon(frame: CGRect(x: SCREEN_WIDTH-270, y: SCREEN_HEIGHT-80, width: 50, height: 50), imageEdgeInsets: standardImageEdgeInsets, imageName: "Redo", action: #selector(redoButtonPressed(sender:)))
    }

    @objc func colorPickerButtonPressed(sender: UIButton!) {
        let colorPickerVC = ColorPickerViewController()
        colorPickerVC.colorChoiceDelegate = self
        colorPickerVC.transitioningDelegate = self
        colorPickerVC.modalPresentationStyle = .custom
        self.present(colorPickerVC, animated: true, completion: nil)
    }

    @objc func exportButtonPressed(sender: UIButton!) {
        // Fetch all needed parameters from the current canvas.
        guard let canvasColorArray = self.canvasView?.canvas.getPixelColorArray(),
            let canvasWidth = self.canvasView?.canvas.getAmountOfPixelsForWidth(),
            let canvasHeight = self.canvasView?.canvas.getAmountOfPixelsForHeight() else {
                return
        }

        // Pass them to the new view controller.
        let shareVC = ShareViewController()

        // In case a drawing object already existed before, update and pass it, otherwise,
        // create new drawing.
        if let updatedDrawing = previousDrawing {
            updatedDrawing.colorArray = canvasColorArray
            shareVC.drawing = updatedDrawing
        } else {
            shareVC.drawing = Drawing(colorArray: canvasColorArray, width: canvasWidth, height: canvasHeight)
        }

        // Present new view controller.
        self.present(shareVC, animated: true, completion: nil)
    }

    @objc func redoButtonPressed(sender: UIButton!) {
        commandManager.redo()
    }

    @objc func undoButtonPressed(sender: UIButton!) {
        commandManager.undo()
    }

    private func setupOrientationObserver() {
        observer = NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil, using: orientationChanged)
    }

    private func registerToolbar() {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        toolbarView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: screenHeight-100), size: CGSize(width: screenWidth, height: 100 )))
        toolbarView?.backgroundColor = LIGHT_GREY

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

        let canvasWidth = CGFloat((canvasView?.canvas.getCanvasWidth())!)
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
        // Initialise group draw command and tear down when needed.
        switch sender.state {
        case .began:
            groupDrawCommand = GroupDrawCommand()
        case .ended:
            commandManager.execute(groupDrawCommand)
        default:
            break
        }

        let canvasScene = canvasView?.canvasScene
        let touchLocation = sender.location(in: sender.view)
        let touchLocationInScene = canvasView?.convert(touchLocation, to: canvasScene!)

        let nodes = canvasScene?.nodes(at: touchLocationInScene!)

        nodes?.forEach({ (node) in
            if let pixel = node as? Pixel {
                let drawCommand = DrawCommand(oldColor: pixel.fillColor, newColor: currentDrawingColor, pixel: pixel)
                // FIXME: Figure out a better name.
                groupDrawCommand.appendAndExecuteSingle(drawCommand)
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
                let drawCommand = DrawCommand(oldColor: pixel.fillColor, newColor: currentDrawingColor, pixel: pixel)
                commandManager.execute(drawCommand)
            }
        })
    }

    @objc func handlePanFrom(_ sender: UIPanGestureRecognizer) {
        let canvasScene = canvasView?.canvasScene

        let translation = sender.translation(in: canvasView)

        let xScale = canvasScene?.xScale
        let yScale = canvasScene?.yScale

        let pan = SKAction.moveBy(x: translation.x * xScale!, y: -1.0 * translation.y * yScale!, duration: 0)

        canvasView?.canvas.run(pan)
        sender.setTranslation(CGPoint.zero, in: canvasView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// Extension for handling half-views such as for the color picker tool.
extension DrawingViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SplitPresentationController(presentedViewController: presented, presenting: presenting)
    }

}

extension DrawingViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// Extension for writing back colors from the color picker view.
extension DrawingViewController: ColorChoiceDelegate {
    func colorChoicePicked(_ color: UIColor) {
        self.currentDrawingColor = color
    }
}
