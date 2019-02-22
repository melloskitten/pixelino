//
//  CustomNavigationController.swift
//  pixelino
//
//  Created by Sandra Grujovic on 25.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomViewParams()
    }

    fileprivate func setCustomViewParams() {
        self.navigationBar.tintColor = .white
        self.navigationBar.barStyle = .black
        self.navigationBar.isTranslucent = false
        self.navigationBar.barTintColor = LIGHT_GREY
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                  NSAttributedStringKey.font: UIFont(
                                                    name: CustomFonts.roboto.rawValue,
                                                    size: UIFont.labelFontSize
                                                    ) ?? CustomFonts.helvetica.rawValue]
    }
}
