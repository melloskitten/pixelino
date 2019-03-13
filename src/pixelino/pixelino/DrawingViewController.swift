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

    // MARK: - General Attributes.

    var commandManager = CommandManager()
    var observer: AnyObject?
    var currentDrawingColor: UIColor = .black
    var currentTool: Tool = Paintbrush()
    var groupDrawCommand: GroupDrawCommand = GroupDrawCommand()
    var previousDrawing: Drawing?

    // MARK: - UIView-related Attributes.

    var canvasView: CanvasView?
    var lowerToolbar: UIView!

    /// Attribute making sure that you cannot draw while you're pinching or panning
    /// around the screen.
    var canDraw = true

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
        setUpButtons()
        setUpDrawingToolButton()

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

    /// This method provides a convenience button creation method. Please note that this method
    /// does __not__ add any _positioning_ autoconstraints to the buttons.
    ///
    /// - Parameters:
    ///   - width: width of the button
    ///   - height: height of the button
    ///   - imageEdgeInsets: inset of icon image
    ///   - imageName: name of icon image (from Assets.xcassets)
    ///   - action: selector of action that should be performed when button is tapped.
    /// - Returns: the set up button.
    fileprivate func setUpTabBarButton(width: CGFloat,
                                       height: CGFloat,
                                       imageEdgeInsets: UIEdgeInsets = UIEdgeInsets(top: 10,
                                                                                    left: 10,
                                                                                    bottom: 10,
                                                                                    right: 10),
                                       imageName: String,
                                       action: Selector,
                                       backgroundColor: UIColor? = nil ) -> UIButton {
        let button = UIButton()
        button.imageEdgeInsets = imageEdgeInsets
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: height).isActive = true

        if let backgroundColor = backgroundColor {
            button.backgroundColor = backgroundColor
        }

        return button
    }

    /// Sets up all regular toolbar icons (excluding the paint tool selection button, please look
    /// at the `setUpDrawingToolButton()` method for further details) as well as their
    /// constraints according to relative constants.
    fileprivate func setUpButtons() {
        // Export button.
        let exportButton = setUpTabBarButton(width: ICON_WIDTH, height: ICON_HEIGHT,
                              imageName: "Export",
                              action: #selector(exportButtonPressed(sender:)))

        // Color Picker button.
        let colorPickerButton = setUpTabBarButton(width: ICON_WIDTH, height: ICON_HEIGHT,
                              imageName: "ColorPicker",
                              action: #selector(colorPickerButtonPressed(sender:)))

        // Undo button.
        let undoButton = setUpTabBarButton(width: ICON_WIDTH, height: ICON_HEIGHT,
                              imageName: "Undo",
                              action: #selector(undoButtonPressed(sender:)))

        // Redo button.
        let redoButton = setUpTabBarButton(width: ICON_WIDTH, height: ICON_HEIGHT,
                              imageName: "Redo",
                              action: #selector(redoButtonPressed(sender:)))

        // Calculate constraint constants.
        let screenWidth = UIScreen.main.bounds.width
        let relativeSpacing = screenWidth / 6
        let edgeSpacing = relativeSpacing / 2
        let topBarSpacing: CGFloat = 10.0

        // Add constraints (from the left side).
        undoButton.centerXAnchor.constraint(equalTo: view.leftAnchor,
                                            constant: edgeSpacing).isActive = true
        undoButton.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                        constant: topBarSpacing).isActive = true
        redoButton.centerXAnchor.constraint(equalTo: undoButton.rightAnchor,
                                            constant: relativeSpacing).isActive = true
        redoButton.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                        constant: topBarSpacing).isActive = true

        // Add constraints (from the right side).
        colorPickerButton.centerXAnchor.constraint(equalTo: exportButton.leftAnchor,
                                                   constant: -relativeSpacing).isActive = true
        colorPickerButton.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                               constant: topBarSpacing).isActive = true
        exportButton.centerXAnchor.constraint(equalTo: view.rightAnchor,
                                              constant: -edgeSpacing).isActive = true
        exportButton.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                          constant: topBarSpacing).isActive = true
    }

    /// Creates the brush and the fill bucket tool selection icon in the toolbar.
    ///
    /// - TODO: Circular fan menu that builds out and shows the tools that the user can select.
    fileprivate func setUpDrawingToolButton() {
        let paintBrushButton = setUpTabBarButton(width: 50.0, height: 50.0,
                                           imageEdgeInsets: UIEdgeInsets(top: 13,
                                                                         left: 13,
                                                                         bottom: 13,
                                                                         right: 13),
                                           imageName: "PaintBrush",
                                           action: #selector(paintBrushButtonPressed(sender:)),
                                           backgroundColor: .white)

        let fillButton = setUpTabBarButton(width: 50.0, height: 50.0,
                                           imageEdgeInsets: UIEdgeInsets(top: 13,
                                                                         left: 13,
                                                                         bottom: 13,
                                                                         right: 13),
                                           imageName: "PaintBucket",
                                           action: #selector(fillButtonPressed(sender:)),
                                           backgroundColor: .white)

        // Add rounded corners for circular background effect.
        // Note: Using non-hard-coded values did NOT work!
        paintBrushButton.layer.cornerRadius = 25.0
        paintBrushButton.layer.masksToBounds = true
        fillButton.layer.cornerRadius = 25.0
        fillButton.layer.masksToBounds = true

        // Add buttons to the view.
        self.view.addSubview(paintBrushButton)
        self.view.addSubview(fillButton)

        // Add constraints.
        paintBrushButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        paintBrushButton.centerYAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                            constant: 20.0).isActive = true
        fillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fillButton.centerYAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                            constant: 40.0).isActive = true

    }

    /// MARK: - Button touch methods.

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

    @objc func fillButtonPressed(sender: UIButton!) {
        currentTool = Bucket()
    }

    @objc func paintBrushButtonPressed(sender: UIButton!) {
        currentTool = Paintbrush()
    }

    private func setupOrientationObserver() {
        observer = NotificationCenter.default.addObserver(forName: .UIDeviceOrientationDidChange, object: nil, queue: nil, using: orientationChanged)
    }

    /// Initialises toolbars, adds them to the view and applies position and width/height
    /// constraints.
    private func registerToolbar() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height

        // Create upper and lower toolbar section.
        lowerToolbar = UIView()
        lowerToolbar.backgroundColor = LIGHT_GREY

        // Add to drawing view.
        self.view.addSubview(lowerToolbar)

        // Calculate correct height of bars according to screen ratio.
        let toolBarHeight = screenHeight / 9

        // Set autoconstraints.
        lowerToolbar.translatesAutoresizingMaskIntoConstraints = false
        lowerToolbar.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lowerToolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        lowerToolbar.heightAnchor.constraint(equalToConstant: toolBarHeight).isActive = true
        lowerToolbar.widthAnchor.constraint(equalToConstant: screenWidth).isActive = true
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

    // MARK: - GestureRecognizer methods.

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
        if canDraw {
            currentTool.handleDrawFrom(sender, self)
        }
    }

    @objc func handleTapFrom(_ sender: UITapGestureRecognizer) {
        currentTool.handleTapFrom(sender, self)
    }

    @objc func handlePanFrom(_ sender: UIPanGestureRecognizer) {
        if sender.state != .ended {
            canDraw = false
            let canvasScene = canvasView?.canvasScene
            let translation = sender.translation(in: canvasView)
            moveCanvas(canvasScene, translation, sender)
            return
        }
        canDraw = true
    }

    // MARK: - Canvas move / Pan gesture helper methods.

    /// Moves the canvas based on the changes observed from the PanGestureRecognizer.
    fileprivate func moveCanvas(_ canvasScene: SKScene?,
                                _ translation: CGPoint,
                                _ sender: UIPanGestureRecognizer) {
        let xScale = canvasScene?.xScale
        let yScale = canvasScene?.yScale

        let relativeXChange = translation.x * xScale!
        let relativeYChange = -1.0 * translation.y * yScale!

        // Calculate possible directions for the pan gesture and whether they are allowed.
        let relativeChange = CGPoint(x: relativeXChange, y: relativeYChange)
        let allowedPanGestures = getAllowedMoveDirections(relativeChange)

        let pan: SKAction

        // Both actions are allowed, move the canvas.
        if allowedPanGestures.0 && allowedPanGestures.1 {
            pan = SKAction.moveBy(x: relativeXChange, y: relativeYChange, duration: 0)
        } else if allowedPanGestures.0 && !allowedPanGestures.1 {
            // Only the X change is valid, do not move in the Y direction.
            pan = SKAction.moveBy(x: relativeXChange, y: 0.0, duration: 0)
        } else if !allowedPanGestures.0 && allowedPanGestures.1 {
            // Only the Y change is valid, do not move in the X direction.
            pan = SKAction.moveBy(x: 0.0, y: relativeYChange, duration: 0)
        } else {
            // No action is possible.
            pan = SKAction.moveBy(x: 0.0, y: 0.0, duration: 0)
        }

        canvasView?.canvas.run(pan)
        sender.setTranslation(CGPoint.zero, in: canvasView)
    }

    /// Returns true if the relative change of a pan gesture is allowed, false if isn't.
    /// This assumes that a relative change to our canvas is only possible if the resulting
    /// position of the canvas is still in our screen boundary.
    /// This stops the user from "scrolling away the canvas into infinity"
    /// Important: it returns whether the relative change
    /// was allowed in the (xDirection, yDirection.) This is needed in order to provide a more
    /// user-friendly scrolling experience.
    func getAllowedMoveDirections(_ relativeChange: CGPoint) -> (Bool, Bool) {

        var allowedPanGestureDirection = (true, true)

        if let canvasCenter = canvasView?.canvas.position,
            let canvas = canvasView?.canvas,
            let canvasView = canvasView {

            // Calculate the barriers for each of the sides.
            let maxLeft = canvasView.center.x - canvas.getScaledCanvasWidth() / 2
            let maxRight = canvasView.center.x + canvas.getScaledCanvasWidth() / 2
            let maxUp = canvasView.center.y - canvas.getScaledCanvasHeight() / 2
            let maxDown = canvasView.center.y + canvas.getScaledCanvasHeight() / 2

            // Check whether the change is valid.
            // Always check from the center point of the canvas.
            if canvasCenter.x + relativeChange.x < maxLeft ||
                canvasCenter.x + relativeChange.x > maxRight {
                allowedPanGestureDirection.0 = false
            }

            if canvasCenter.y + relativeChange.y < maxUp ||
                canvasCenter.y + relativeChange.y > maxDown {
                allowedPanGestureDirection.1 = false
            }

        }

        return allowedPanGestureDirection
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
