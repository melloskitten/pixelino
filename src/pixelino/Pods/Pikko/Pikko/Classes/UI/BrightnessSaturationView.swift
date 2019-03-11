//
//  BrightnessSaturationView.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import Foundation
import UIKit

/// Square view representing brightness and saturation.
internal class BrightnessSaturationView: UIView {
    
    // MARK: - Private attributes.
    
    /// Sampling rate for the 'steps' between the saturation / brightness values in terms of
    /// interpolation.
    /// - TODO: Make sampling rate parametric depending on size of canvas.
    private var samplingRate: CGFloat = 25.0
    
    /// Wrapper View holding the square UIView.
    private var brightnessSaturationView: UIView!
    
    /// Gradient layer for brightness transition (white to black).
    private var brightnessLayer: CAGradientLayer?
    
    /// Gradient layer for saturation transition (desaturated to saturated color).
    private var saturationLayer: CAGradientLayer?
    
    /// The circular UI control that can be dragged around.
    private var selector: UIView!
    
    /// The scale at which the selector enlargens when the user clicks on it and holds it.
    private var scale: CGFloat
    
    /// The current hue value.
    private var hue: CGFloat = 1.0
    
    // MARK: - Public attributes.
    
    /// Delegate method for writing back changes in the color selection.
    internal var delegate: PikkoDelegate?
    
    // MARK: - Initializer.
    
    /// Initializer for BrightnessSaturationView.
    ///
    /// - Parameters:
    ///   - frame: the frame of the BrightnessSaturationView.
    ///   - selectorDiameter: the selector diameter.
    ///   - scale: the scale at which the selector should zoom in/zoom out when the user holds it.
    internal init(frame: CGRect, selectorDiameter: CGFloat, scale: CGFloat) {
        self.scale = scale
        super.init(frame: frame)
        createView(frame)
        createSelector(selectorDiameter, scale)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Creates all view based components including the saturation and brightness gradient layers.
    ///
    /// - Parameter
    ///     - frame: the frame of the BrightnessSaturationView.
    private func createView(_ frame: CGRect) {
        brightnessSaturationView = UIView(frame: frame)
        
        // Create the layers.
        saturationLayer = createSaturationLayer(hue: 0.0)
        brightnessLayer = createBrightnessLayer()
        
        // Add to the wrapper view and then append to the UIView of the BrightnessSaturationView.
        brightnessSaturationView.layer.addSublayer(saturationLayer!)
        brightnessSaturationView.layer.addSublayer(brightnessLayer!)
        
        addSubview(brightnessSaturationView)
    }
    
    
    /// Creates the selector which can be dragged around by the user.
    ///
    /// - Parameters:
    ///   - selectorDiameter: the selector diameter.
    ///   - scale: the scale at which the selector should zoom in/zoom out when the user holds it.
    private func createSelector(_ selectorDiameter: CGFloat, _ scale: CGFloat) {
        
        selector = UIView(frame: CGRect(x: 0-selectorDiameter/2,
                                        y: 0-selectorDiameter/2,
                                        width: selectorDiameter,
                                        height: selectorDiameter))
        
        selector.backgroundColor = .white
        selector.layer.cornerRadius = selectorDiameter/2
        selector.layer.borderColor = UIColor.white.cgColor
        selector.layer.borderWidth = 1
        selector.isUserInteractionEnabled = true
        
        setUpSelectorGestureRecognizer()
        addSubview(selector)
    }
    
    /// Creates and adds a longpress gesture recognizer to the selector.
    private func setUpSelectorGestureRecognizer() {
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(selectorPanned(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0.0
        selector?.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    /// Handles the panning of the selector and prohibits it to leave the frame of the
    /// BrightnessSaturationView.
    @objc func selectorPanned(_ gestureRecognizer: UILongPressGestureRecognizer) {
        
        var location = gestureRecognizer.location(in: self)
        
        // Check whether the user is about to scroll outside of the frame, if the frame is left
        // stop the movement in that particular direction.
        if location.x <= 0 {
            location.x = 0
        }
        
        if location.x >= frame.width - 1 {
            location.x = frame.width - 1
        }
        
        if location.y <= 0 {
            location.y = 0
        }
        
        if location.y >= frame.height - 1 {
            location.y = frame.height - 1
        }
        updateSelectorColor(point: location)
        selector.center = location
        animate(gestureRecognizer)
    }
    
    /// Animates the selector based on the current state of the gesture. Enlargens the
    /// selector when held and shrinks it after it has been released.
    private func animate(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            Animations.animateScale(view: selector!, byScale: scale)
        case .ended:
            Animations.animateScaleReset(view: selector!)
        default:
            break
        }
    }
    
    /// Update the current color of the Selector according to a specific point.
    ///
    /// - Parameters:
    ///     - point: the CGPoint at which the color should be taken from.
    private func updateSelectorColor(point: CGPoint) {
        var saturation = Double(point.x) / Double(frame.width)
        var brightness = (Double(frame.height) - Double(point.y)) / Double(frame.height)
        
        // HACK: Reduce floating point errors in the edge cases of the brightness / saturation view.
        saturation = saturation > 0.99 ? 1.0 : saturation
        saturation = saturation < 0.01 ? 0.0 : saturation
        
        brightness = brightness > 0.99 ? 1.0 : brightness
        brightness = brightness < 0.01 ? 0.0 : brightness

        selector.backgroundColor = UIColor.init(hue: self.hue,
                                                saturation: CGFloat(saturation),
                                                brightness: CGFloat(brightness),
                                                alpha: 1.0)
        
        if let color = selector.backgroundColor, let delegate = delegate {
            delegate.writeBackColor(color: color)
        }
    }
    
    // MARK: View setup methods.
    
    /// Creates the Saturation gradient color array for the given hue.
    ///
    /// - Parameters:
    ///     - hue: the hue that should be used to generate the saturation gradient from.
    /// - Returns: array of interpolated color of the saturation gradient.
    private func generateSaturationInterpolationArray(hue: CGFloat) -> [CGColor] {
        var colorArray = [CGColor]()
        
        for i in 0..<Int(samplingRate) {
            let interpolationValue = CGFloat(CGFloat(i) / samplingRate)
            let color = UIColor(hue: hue,
                                saturation: interpolationValue,
                                brightness: 1.0,
                                alpha: 1.0)
            
            colorArray.append(color.cgColor)
        }
        
        return colorArray
    }
    
    /// Creates the Saturation gradient for the given hue.
    ///
    /// - Parameters:
    ///     - hue: the hue that should be used to generate the saturation gradient from.
    /// - Returns: the saturation gradient layer.
    private func createSaturationLayer(hue: CGFloat) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.colors = generateSaturationInterpolationArray(hue: hue)
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = frame
        
        return gradientLayer
    }
    
    /// Creates the Brightness gradient.
    ///
    /// - Returns: the brightness gradient layer.
    private func createBrightnessLayer() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        var colorArray = [CGColor]()

        for i in 0..<Int(samplingRate) {
            let interpolationValue = CGFloat(CGFloat(i) / samplingRate)
            let color = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: interpolationValue)
            colorArray.append(color.cgColor)
        }
        
        gradientLayer.colors = colorArray
        gradientLayer.frame = frame
        
        return gradientLayer
    }
    
    /// This method ensures that we can grab the color lying under the selector properly.
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let pointForTargetView = selector.convert(point, from: self)

        if self.selector.bounds.contains(pointForTargetView) {
            return selector.hitTest(pointForTargetView, with: event)
        }
        
        return super.hitTest(point, with: event)
    }
    
    /// Sets the brightness and saturation selector to a certain color.
    ///
    /// - Parameters:
    ///     - color: UIColor for the selector position.
    func setColor(_ color: UIColor) {
        let saturation = color.saturation
        let brightness = color.brightness
        
        let width = self.frame.width
        let height = self.frame.height
        
        let position_x = width * saturation
        let position_y = height - (height * brightness)
        let newCenter = CGPoint(x: position_x, y: position_y)

        selector.center = newCenter
        updateSelectorColor(point: newCenter)
    }
}

// MARK: HueDelegate methods.

extension BrightnessSaturationView: HueDelegate {
    internal func didUpdateHue(hue: CGFloat) {
        DispatchQueue.main.async {
            self.hue = hue
            self.updateSelectorColor(point: self.selector.center)
        }
        
        DispatchQueue.main.async {
            self.saturationLayer?.colors = self.generateSaturationInterpolationArray(hue: hue)
        }
    }
}
