//
//  PictureExporter.swift
//  pixelino
//
//  Created by Sandra Grujovic on 07.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import UIKit

// Handles the exporting of images to Photos library.
class PictureExporter: NSObject {

    private var rawPixelArray: [RawPixel]
    private var canvasWidth: Int
    private var canvasHeight: Int
    private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    private let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

    init(colorArray: [UIColor], canvasWidth: Int, canvasHeight: Int) {
        self.rawPixelArray = [RawPixel]()
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        super.init()
        // Convert given UIColor array into RawPixel array.
        setUpRawPixelArray(colorArray: colorArray)
    }

    convenience init(drawing: Drawing) {
        self.init(colorArray: drawing.colorArray, canvasWidth: Int(drawing.width), canvasHeight: Int(drawing.height))
    }

    private func setUpRawPixelArray(colorArray: [UIColor]) {
        colorArray.forEach { (color) in
            do {
                let rawPixel = try RawPixel(inputColor: color)
                rawPixelArray.append(rawPixel)
            } catch {
                print("RawPixel conversion failed. \(error.localizedDescription)")
                return
            }
        }
    }

    public func generateUIImagefromDrawing(width: Int, height: Int) -> UIImage? {
        // Build the bitmap input for the CGImage conversion.
        guard let dataProvider = CGDataProvider(data: NSData(bytes: &rawPixelArray, length: rawPixelArray.count * MemoryLayout<RawPixel>.size)
            ) else {
                print("DataProvider could not be built.")
                return nil }

        // Create CGImage version.
        guard let cgImage = CGImage.init(width: canvasWidth, height: canvasHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: canvasWidth * (MemoryLayout<RawPixel>.size), space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
            print("CGImage could not be created.")
            return nil
        }

        // Convert to UIImage for later use in UIImageView.
        let uiImage = UIImage(cgImage: cgImage)

        // Generate Image View for saving image by taking a screenshort.
        let imageView = UIImageView(image: uiImage)
        imageView.layer.magnificationFilter = kCAFilterNearest
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: height)

        // Take actual screenshot from Image View context.
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
        imageView.transform = imageView.transform.rotated(by: CGFloat.pi/2)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }

        UIGraphicsEndImageContext()

        // Transform picture to correct rotation.
        guard let rotatedSnapshotImage = snapshotImage.rotate(radians: -CGFloat.pi/2) else {
            return nil
        }

        return rotatedSnapshotImage
    }

    func generateThumbnailFromDrawing() -> UIImage? {
        guard let image = generateUIImagefromDrawing(width: 300, height: 300) else {
            return nil
        }

        return image
    }
}
