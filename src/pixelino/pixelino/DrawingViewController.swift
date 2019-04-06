//
//  ViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 14.05.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

//swiftlint:disable type_body_length

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
    var tapGestureRecognizer: UITapGestureRecognizer?
    var longPressGestureRecognizer: UILongPressGestureRecognizer?

    // MARK: - UIView-related Attributes.

    var canvasView: CanvasView?
    var lowerToolbar: UIView!
    var pipetteCircle: UIView?
    var colorPickerButton: UIButton?

    // Fan menu attributes.

    /// Invisible dummy button that shows the fan menu when tapped.
    var fanMenuButton: UIButton!

    /// Selects the paintbrush tool.
    var paintBrushButton: UIButton!

    /// Selects the fill bucket tool.
    var fillButton: UIButton!

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
        setupFanMenuButton()
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

    // MARK: Fan menu methods.

    /// Hides the fan menu. Sets the selected tool button to the origin
    /// of the fanMenuButton.
    @objc private func hideFanMenu() {

        // Disable user interaction to prevent changes when the menu is not active.
        paintBrushButton.isUserInteractionEnabled = false
        fillButton.isUserInteractionEnabled = false

        UIView.animate(withDuration: 0.3, animations: {

            // Only show the selected tool, hide other button.
            switch self.currentTool {
            case is Paintbrush:
                self.fillButton.alpha = 0
            case is Bucket:
                self.paintBrushButton.alpha = 0
            default:
                () // No-op to make the compiler happy.
            }

            // Adjust center for both buttons.
            self.fillButton.center = self.fanMenuButton.center
            self.paintBrushButton.center = self.fanMenuButton.center
        })
    }

    /// Shows the fan menu. Sets all buttons to visible and adjusts their position
    /// w.r.t. the origin of the fanMenuButton.
    @objc private func showFanMenu() {

        // Enable user interaction for all buttons.
        paintBrushButton.isUserInteractionEnabled = true
        fillButton.isUserInteractionEnabled = true

        UIView.animate(withDuration: 0.3, animations: {

            // Fade in all buttons.
            self.fillButton.alpha = 1.0
            self.paintBrushButton.alpha = 1.0

            // Adjust button location.
            let origin = self.fanMenuButton.center
            self.fillButton.center = CGPoint(x: origin.x + 50, y: origin.y - 70)
            self.paintBrushButton.center = CGPoint(x: origin.x - 50, y: origin.y - 70)
        })
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

    /// This method provides a convenience button creation method. Please note that this method
    /// does __not__ add any _positioning_ autoconstraints to the buttons.
    ///
    /// - Parameters:
    ///   - width: width of the button
    ///   - height: height of the button
    ///   - action: selector of action that should be performed when button is tapped.
    /// - Returns: the set up button.
    fileprivate func setupColorPickerButton(width: CGFloat,
                                            height: CGFloat,
                                            action: Selector) -> UIButton {
        let button = UIButton()

        // Setup rounded corners.
        button.layer.cornerRadius = width / 2.0
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.white.cgColor

        // Register listener.
        button.addTarget(self, action: action, for: .touchUpInside)

        // Setup constraints.
        button.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: width).isActive = true
        button.heightAnchor.constraint(equalToConstant: height).isActive = true

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
        colorPickerButton = setupColorPickerButton(width: ICON_WIDTH, height: ICON_HEIGHT, action: #selector(colorPickerButtonPressed(sender:)))
        // Initialize starting color on colorpicker.
        colorPickerButton?.backgroundColor = .black

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
        colorPickerButton!.centerXAnchor.constraint(equalTo: exportButton.leftAnchor,
                                                   constant: -relativeSpacing).isActive = true
        colorPickerButton!.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                               constant: topBarSpacing).isActive = true
        exportButton.centerXAnchor.constraint(equalTo: view.rightAnchor,
                                              constant: -edgeSpacing).isActive = true
        exportButton.topAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                          constant: topBarSpacing).isActive = true
    }

    /// Creates the invisible fan menu button.
    fileprivate func setupFanMenuButton() {
        fanMenuButton = UIButton(frame: CGRect.zero)
        fanMenuButton.addTarget(self, action: #selector(showFanMenu), for: .touchUpInside)

        // Setup constraints.
        fanMenuButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fanMenuButton)
        fanMenuButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fanMenuButton.centerYAnchor.constraint(equalTo: lowerToolbar.topAnchor,
                                               constant: 20.0).isActive = true
        fanMenuButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        fanMenuButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    /// Creates the brush and the fill bucket tool selection icon in the toolbar.
    fileprivate func setUpDrawingToolButton() {

        let defaultInsets = UIEdgeInsets(top: 13, left: 13, bottom: 13, right: 13)

        // Setup paint brush button.
        paintBrushButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        paintBrushButton.imageEdgeInsets = defaultInsets
        paintBrushButton.backgroundColor = .white
        paintBrushButton.setImage(UIImage(named: "PaintBrush"), for: .normal)
        paintBrushButton.addTarget(self,
                                   action: #selector(paintBrushButtonPressed(sender:)),
                                   for: .touchUpInside)

        fillButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        fillButton.imageEdgeInsets = defaultInsets
        fillButton.backgroundColor = .white
        fillButton.setImage(UIImage(named: "PaintBucket"), for: .normal)
        fillButton.addTarget(self,
                             action: #selector(fillButtonPressed(sender:)),
                             for: .touchUpInside)

        // Add rounded corners for circular background effect.
        // Note: Using non-hard-coded values did NOT work!
        paintBrushButton.layer.cornerRadius = 25.0
        paintBrushButton.layer.masksToBounds = true
        fillButton.layer.cornerRadius = 25.0
        fillButton.layer.masksToBounds = true

        // Add buttons to the view.
        self.view.addSubview(paintBrushButton)
        self.view.addSubview(fillButton)

        // Sets the fan menu state.
        hideFanMenu()
    }

    override func viewDidLayoutSubviews() {
        // Adjust button center positions after autoconstraints are applied.
        paintBrushButton.center = fanMenuButton.center
        fillButton.center = fanMenuButton.center
    }

    /// MARK: - Button touch methods.

    @objc func colorPickerButtonPressed(sender: UIButton!) {
        let colorPickerVC = ColorPickerViewController(initialColor: currentDrawingColor)
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
            previousDrawing = Drawing(colorArray: canvasColorArray, width: canvasWidth, height: canvasHeight)
            shareVC.drawing = previousDrawing!
        }

        // Present new view controller.
        let navVC = CustomNavigationController(rootViewController: shareVC)
        self.present(navVC, animated: true, completion: nil)
    }

    @objc func redoButtonPressed(sender: UIButton!) {
        commandManager.redo()
    }

    @objc func undoButtonPressed(sender: UIButton!) {
        commandManager.undo()
    }

    @objc func fillButtonPressed(sender: UIButton!) {
        currentTool = Bucket()
        hideFanMenu()
    }

    @objc func paintBrushButtonPressed(sender: UIButton!) {
        currentTool = Paintbrush()
        hideFanMenu()
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

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFrom(_:)))

        // Pipette tool gesture recognizer.
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressNew(_:)))
        longPressGestureRecognizer?.numberOfTouchesRequired = 1
        longPressGestureRecognizer?.minimumPressDuration = 0.4
        longPressGestureRecognizer?.allowableMovement = 20

        // Add to view
        view.addGestureRecognizer(zoomGestureRecognizer)
        view.addGestureRecognizer(navigatorGestureRecognizer)
        view.addGestureRecognizer(drawGestureRecognizer)
        view.addGestureRecognizer(tapGestureRecognizer!)
        canvasView?.addGestureRecognizer(longPressGestureRecognizer!)
    }

    // MARK: - GestureRecognizer methods.

    /// Handles a long press indicating the start of a pipette tool
    /// interaction.
    @objc func handleLongPressNew(_ sender: UILongPressGestureRecognizer) {

        if let canvasScene = self.canvasView?.canvasScene,
            let canvasView = self.canvasView {

            // Calculate correct location in terms of canvas and corresponding pixels.
            let touchLocation = sender.location(in: sender.view)
            let touchLocationInScene = canvasView.convert(touchLocation, to: canvasScene)

            // Get the tapped pixel.
            let potentialPixel = getPixel(canvasScene: canvasScene,
                                          touchLocationInScene: touchLocationInScene)

            // Get location of touch for determining circle's position.
            var pipetteLocation = touchLocation

            switch sender.state {

            case .began:

                // Haptic feedback when the pipette tool starts.
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()

                // Draw circle and position it, change circle
                // color to underlying node color, if the
                // pipette tool was started on the canvas.
                if let pix = potentialPixel {

                    pipetteCircle = UIView(frame: CGRect(x: 0,
                                                         y: 0,
                                                         width: 80,
                                                         height: 80))
                    pipetteCircle?.layer.cornerRadius = 40.0
                    pipetteLocation.y -= PIPETTE_TOOL_OFFSET
                    pipetteCircle?.center = pipetteLocation
                    currentDrawingColor = pix.fillColor
                    pipetteCircle?.backgroundColor = pix.fillColor
                    colorPickerButton?.backgroundColor = pix.fillColor

                    // Setup border.
                    pipetteCircle?.layer.borderColor = UIColor.darkGray.cgColor
                    pipetteCircle?.layer.borderWidth = 0.75

                    // Setup shadow.
                    pipetteCircle?.layer.shadowColor = UIColor.black.cgColor
                    pipetteCircle?.layer.shadowRadius = 5.0
                    pipetteCircle?.layer.shadowOpacity = 0.4
                    pipetteCircle?.layer.shadowOffset = CGSize(width: 0, height: 3)

                    self.view.addSubview(pipetteCircle!)

                } else {
                    // If the pipette tool was started outside the canvas,
                    // remove pipette circle in case it is still there.
                    pipetteCircle?.removeFromSuperview()
                    pipetteCircle = nil
                }

            case .changed:
                // Adjust the pipetteCircle according to the position of the
                // finger in the view. If the user pulls the finger outside of the
                // canvas, apply appropriate transformations so the pipette circle
                // can still be dragged around the corners.
                // The pipetteCircle MUST exist for this part to be executed.
                // This is because otherwise we would update the color for the
                // color picker button in the view and lose performance calculating
                // a color for the pipette circle when it is not even shown on screen.
                if pipetteCircle != nil {
                    let (startX, startY, endX, endY) = canvasView.getConvertedEdgePoints(resultView: self.view)

                    if touchLocation.x - 5.0 < startX {
                        pipetteLocation.x = startX + 5.0
                    }

                    if  touchLocation.x + 5.0 > endX {
                        pipetteLocation.x = endX - 5.0
                    }

                    if touchLocation.y + 5.0 > startY {
                        pipetteLocation.y = startY - 5.0
                    }

                    if touchLocation.y - 5.0 < endY {
                        pipetteLocation.y = endY + 5.0
                    }

                    if let pix = potentialPixel {
                        pipetteLocation.y -= PIPETTE_TOOL_OFFSET
                        pipetteCircle?.center = pipetteLocation
                        currentDrawingColor = pix.fillColor
                        pipetteCircle?.backgroundColor = pix.fillColor
                        colorPickerButton?.backgroundColor = pix.fillColor
                        return
                    }

                    // Second check for pixels that are located on the corner of the canvas.
                    // Translate back to correct view in order to get a reference
                    // pixel to update color, otherwise we will never get a color
                    // because the touch location is directly at the edge of the canvas.
                    var tempLocation = canvasView.convert(pipetteLocation, from: self.view)
                    tempLocation = canvasScene.convertPoint(fromView: tempLocation)

                    if let tempPixel = getPixel(canvasScene: canvasScene,
                                                touchLocationInScene: tempLocation) {
                        pipetteLocation.y -= PIPETTE_TOOL_OFFSET
                        pipetteCircle?.center = pipetteLocation

                        // Update color.
                        currentDrawingColor = tempPixel.fillColor
                        pipetteCircle?.backgroundColor = tempPixel.fillColor
                        colorPickerButton?.backgroundColor = tempPixel.fillColor

                        }
                    }

            default:
                pipetteCircle?.removeFromSuperview()
                pipetteCircle = nil
            }
        }
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

    /// Gets a pixel object at the given CGPoint, return nil if otherwise.
    private func getPixel(canvasScene: SKScene, touchLocationInScene: CGPoint) -> Pixel? {

        let nodes = canvasScene.nodes(at: touchLocationInScene)

        if nodes.isEmpty {
            return nil
        }

        if let pixel = nodes.first as? Pixel {
            return pixel
        }

        return nil
    }

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
        self.colorPickerButton?.backgroundColor = color
    }
}
