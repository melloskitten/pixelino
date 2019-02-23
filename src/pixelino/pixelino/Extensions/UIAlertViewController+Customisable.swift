//
//  UIAlertViewController+Customisable.swift
//  pixelino
//
//  Created by Sandra Grujovic on 22.02.19.
//  Copyright © 2019 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

// MARK: - AlertViewController extension holding UI related convenience methods.

extension UIAlertController {

    /// Set custom background color. Note: Removes "opaque look" from the standard
    /// UIAlertController background view.
    public func setBackgroundColor(color: UIColor, radius: CGFloat = 10.0) {
        let backgroundView = (self.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        backgroundView.backgroundColor = color
        backgroundView.layer.cornerRadius = 10.0
    }

    /// Sets custom title, its text, color and font.
    public func setTitle(_ title: String, color: UIColor, customFont: String) {
        var mutableTitle = NSMutableAttributedString()
        mutableTitle = NSMutableAttributedString(string: title as String, attributes:
            [NSAttributedStringKey.font: UIFont(name: customFont, size: 18.0)!])
        mutableTitle.addAttribute(NSAttributedStringKey.foregroundColor,
                                  value: color,
                                  range: NSRange(location: 0, length: title.count))
        self.setValue(mutableTitle, forKey: "attributedTitle")
    }

    /// Sets custom message, its text, color and font.
    public func setMessage(_ message: String, color: UIColor, font: String) {
        var mutableMessage = NSMutableAttributedString()
        mutableMessage = NSMutableAttributedString(string: message as String, attributes: [NSAttributedStringKey.font: UIFont(name: font, size: 16.0)!])
        mutableMessage.addAttribute(NSAttributedStringKey.foregroundColor,
                                    value: color,
                                    range: NSRange(location: 0, length: message.count))
        self.setValue(mutableMessage, forKey: "attributedMessage")
    }
}
