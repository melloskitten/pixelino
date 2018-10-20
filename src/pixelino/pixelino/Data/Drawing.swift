//
//  Drawing+CoreDataClass.swift
//  pixelino
//
//  Created by Sandra Grujovic on 29.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Drawing)
public class Drawing: NSManagedObject {

    convenience init(colorArray: [UIColor], width: Int, height: Int) {
        self.init(context: CoreDataManager.getCoreDataContext()!)
        self.height = Int64(height)
        self.width = Int64(width)
        self.colorArray = colorArray
    }

    convenience init(colorArray: [UIColor], width: Int, height: Int, thumbnail: Thumbnail) {
        self.init(colorArray: colorArray, width: width, height: height)
        self.thumbnail = thumbnail
    }
}
