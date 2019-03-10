//
//  Pikko.swift
//  Pikko
//
//  Created by Sandra & Johannes.
//

import Foundation
import UIKit


/// The Pikko colorpicker, holding the two subviews, namely the hue ring and brightness/saturation
/// square picker.
public class Pikko: UIView {
    
    private var hueView: HueView?
    private var brightnessSaturationView: BrightnessSaturationView?
    private var currentColor: UIColor = .white
    
    /// The PikkoDelegate that is called whenever the color is updated.
    public var delegate: PikkoDelegate?
    
    // MARK: - Initializer.

    /// Initializes a new PikkoView.
    ///
    /// - Parameters:
    ///     - dimension: width and heigth of the new color picker.
    ///     - color: the color you want to initialise the picker to. If not set, the color picker
    ///     is initialised to `UIColor.white`.
    public init(dimension: Int, setToColor color: UIColor = .white) {
        let frame = CGRect(x: 0, y: 0, width: dimension, height: dimension)
        super.init(frame: frame)
        setUpColorPickerViews(frame)
        setColor(color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Helper methods.
    
    /// Initialises both hueView and brightnessSaturationView.
    /// - TODO: Many constants are hardcoded. Make them adjustable with customised initialisers
    /// in the future.
    /// - TODO: Make borderwidth an adjustable parameter.
    /// - TODO: Explain magic constant that controls "margin" of the square.
    private func setUpColorPickerViews(_ frame: CGRect) {
        
        let borderWidth: CGFloat = 30.0
        let selectorDiameter: CGFloat = borderWidth * 1.5
        let radius = frame.width/2
        
        let customWidth: CGFloat = sqrt(2) * (radius - borderWidth) * 0.85
        let scale: CGFloat = 1.5
        
        hueView = HueView(frame: frame, borderWidth: borderWidth,
                          selectorDiameter: selectorDiameter,
                          scale: scale)
        
        brightnessSaturationView = BrightnessSaturationView(frame: CGRect(x: 0,
                                                                          y: 0,
                                                                          width: customWidth,
                                                                          height: customWidth),
                                                            selectorDiameter: selectorDiameter,
                                                            scale: 2)
        
        if let hue = hueView, let square = brightnessSaturationView {
            hue.delegate = self
            square.delegate = self
            square.center = hue.center
            self.addSubview(hue)
            self.addSubview(square)
        }
    }
    
    /// Gets the current color that is selected on the color picker.
    ///
    /// - Returns: the current color.
    public func getColor() -> UIColor {
        return currentColor
    }
    
    
    /// Sets the color picker to the specified color.
    ///
    /// - Parameter color: the color to set on the color picker.
    public func setColor(_ color: UIColor) {
        if let hue = hueView, let square = brightnessSaturationView {
            hue.setColor(color)
            square.setColor(color)
        }
    }
}

// MARK: HueDelegate methods.

extension Pikko: HueDelegate {
    func didUpdateHue(hue: CGFloat) {
        if let square = brightnessSaturationView {
            square.didUpdateHue(hue: hue)
        }
    }
}

// MARK: PikkoDelegate methods.

extension Pikko: PikkoDelegate {
    public func writeBackColor(color: UIColor) {
        if let delegate = delegate {
            currentColor = color
            delegate.writeBackColor(color: color)
        }
    }
}

