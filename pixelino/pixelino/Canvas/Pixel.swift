//
//  Pixel.swift
//  pixelino
//
//  Created by Sandra Grujovic on 11.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import SpriteKit

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
    
    convenience init(color: UIColor) {
        self.init()
        self.fillColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
