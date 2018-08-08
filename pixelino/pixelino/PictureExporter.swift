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
    private let sender: UIViewController
    
    init(colorArray: [UIColor], canvasWidth: Int, canvasHeight: Int, _ sender: UIViewController) {
        self.rawPixelArray = [RawPixel]()
        self.canvasWidth = canvasWidth
        self.canvasHeight = canvasHeight
        self.sender = sender
        super.init()
        // Convert given UIColor array into RawPixel array.
        setUpRawPixelArray(colorArray: colorArray)
    }
    
    private func setUpRawPixelArray(colorArray: [UIColor]) {
        colorArray.forEach { (color) in
            let rawPixel = RawPixel(inputColor: color)
            rawPixelArray.append(rawPixel)
        }
    }
    
    private func generateUIImage() -> UIImage? {
        // Build the bitmap input for the CGImage conversion.
        guard let dataProvider = CGDataProvider(data: NSData(bytes: &rawPixelArray, length: rawPixelArray.count * MemoryLayout<RawPixel>.size)
            ) else {
                print("DataProvider could not be built.")
                return nil }
        
        // Create CGImage version.
        guard let exportedCGImage = CGImage.init(width: canvasWidth, height: canvasHeight, bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: canvasWidth * (MemoryLayout<RawPixel>.size), space: rgbColorSpace, bitmapInfo: bitmapInfo, provider: dataProvider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
            print("CGImage could not be created.")
            return nil
        }
        
        // Convert to UIImage for later use in UIImageView.
        let exportedUIImage = UIImage(cgImage: exportedCGImage)
        return exportedUIImage
    }
    
    public func exportImage(exportedWidth: Int, exportedHeight: Int) {
        guard let exportedUIImage = generateUIImage() else {
            return
        }
        
        // Generate Image View for saving image by taking a screenshort.
        let imageView = UIImageView(image: exportedUIImage)
        imageView.layer.magnificationFilter = kCAFilterNearest
        imageView.frame = CGRect(x: 0, y: 0, width: exportedWidth, height: exportedHeight)
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Write back to Photos Album and show success/failure message to user from sender.
        UIImageWriteToSavedPhotosAlbum(snapshotImage!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    // https://stackoverflow.com/questions/40854886/swift-take-a-photo-and-save-to-photo-library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            // we got back an error!
            let ac = UIAlertController(title: "Export Error", message: "Your drawing could not be exported to Photos. Please try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            sender.present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your drawing has been successfully saved to Photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            sender.present(ac, animated: true)
        }
    }
}
