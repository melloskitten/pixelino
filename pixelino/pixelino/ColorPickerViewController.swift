//
//  ColorPickerViewController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 31.07.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit
import ChromaColorPicker

class ColorPickerViewController: UIViewController {
    
    var colorChoiceDelegate : ColorChoiceDelegate?
    
    fileprivate func setUpColorPicker() {
        // TODO: Adjust the position of the color picker dynamically.
        let neatColorPicker = ChromaColorPicker(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
        neatColorPicker.delegate = self
        neatColorPicker.padding = 10
        neatColorPicker.stroke = 10
        neatColorPicker.hexLabel.textColor = UIColor.white
        neatColorPicker.center.x = view.center.x
        
        view.addSubview(neatColorPicker)
    }
    
    fileprivate func setUpGestureRecognizer() {
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(dismissView(_:)))
        swipeDownGestureRecognizer.direction = .down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
    }

    override func viewDidLoad() {
        self.view.backgroundColor = lightGrey
        setUpColorPicker()
        setUpGestureRecognizer()
    }
    
    @objc func dismissView(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension ColorPickerViewController: ChromaColorPickerDelegate {
    func colorPickerDidChooseColor(_ colorPicker: ChromaColorPicker, color: UIColor) {
        dismiss(animated: true, completion: nil)
        colorChoiceDelegate?.colorChoicePicked(color)
    }
}
