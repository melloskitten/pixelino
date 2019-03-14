//
//  Canvas.swift
//  pixelino
//
//  Created by Sandra Grujovic on 11.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import SpriteKit

class Canvas: SKSpriteNode {

    /// Amount of pixels on a horizontal scale.
    private var width: Int = 0

    /// Amount of pixels on a vertical scale.
    private var height: Int = 0
    private var pixelArray = [Pixel]()

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        super.init(texture: nil, color: .cyan, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        setUpPixelGrid(colorArray: nil)
    }

    init(width: Int, height: Int, colorArray: [UIColor]) {
        self.width = width
        self.height = height
        self.height = height
        super.init(texture: nil, color: .cyan, size: CGSize(width: width * PIXEL_SIZE, height: height * PIXEL_SIZE))
        setUpPixelGrid(colorArray: colorArray)
    }

    func getPixelArray() -> [Pixel] {
        return pixelArray
    }

    func getCanvasWidth() -> Int {
        return width * PIXEL_SIZE
    }

    func getCanvasHeight() -> Int {
        return height * PIXEL_SIZE
    }

    func getAmountOfPixelsForWidth() -> Int {
        return width
    }

    func getAmountOfPixelsForHeight() -> Int {
        return height
    }

    func getPixelWidth() -> Int {
        return PIXEL_SIZE
    }

    func getScaledPixelWidth() -> CGFloat {
        return getScaledCanvasWidth() / CGFloat(getAmountOfPixelsForWidth())
    }

    func getScaledPixelHeight() -> CGFloat {
        return getScaledCanvasHeight() / CGFloat(getAmountOfPixelsForHeight())
    }

    /// Helper method that returns a pixel based on the x/y. The x and y position are
    /// ordinated along the standard cartesian axis by the following system: x increasing
    /// in the right direction and y increasing in the up direction.
    func getPixel(x: Int, y: Int) -> Pixel? {
        let translatedXPosition = x * height
        let translatedYPosition = y

        if translatedXPosition + translatedYPosition >= pixelArray.count
            || translatedXPosition < 0 || translatedXPosition >= pixelArray.count
            || translatedYPosition < 0 || translatedYPosition >= pixelArray.count {
            return nil
        }

        return pixelArray[translatedXPosition + translatedYPosition]
    }

    /// Gets the correct indices for a given pixel node according to the cartesian
    /// coordinate system. Note `getPixel()` for more information.
    func getPosition(pixel forPixel: Pixel) -> (Int, Int) {
            let currentIndex = pixelArray.index(where: {$0 == forPixel})
            let translatedXPosition = currentIndex! / height
            let translatedYPosition = currentIndex! % height
            return (translatedXPosition, translatedYPosition)
    }

    /// Returns actual size of canvas width in screen (scale factor included).
    func getScaledCanvasWidth() -> CGFloat {
        return CGFloat(getCanvasWidth()) * xScale
    }

    /// Returns actual size of canvas height in screen (scale factor included).
    func getScaledCanvasHeight() -> CGFloat {
        return CGFloat(getCanvasHeight()) * yScale
    }

    func getPixelHeight() -> Int {
        return PIXEL_SIZE
    }

    func getPixelColorArray() -> [UIColor] {
        return pixelArray.map({ (currentPixel) -> UIColor in
            return currentPixel.fillColor
        })
    }

    private func setUpPixelGrid(colorArray: [UIColor]?) {
        for x in 0..<self.width {
            for y in 0..<self.height {
                let pixel = Pixel()

                // This is nasty, but SpriteKit has a stupid bug...
                let xPos = Int(-self.size.width / 2) + x * Int(PIXEL_SIZE)
                let yPos = Int(-self.size.height / 2) + y * Int(PIXEL_SIZE)
                pixel.position.x = CGFloat(xPos)
                pixel.position.y = CGFloat(yPos)
                if let colorArray = colorArray {
                    pixel.fillColor = colorArray[y + width * x]
                }

                pixelArray.append(pixel)
                self.addChild(pixel)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func draw(pixel: Pixel, color: UIColor) {
        pixel.fillColor = color
    }

}
