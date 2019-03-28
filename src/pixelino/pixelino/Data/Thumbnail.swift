//
//  Thumbnail+CoreDataClass.swift
//  pixelino
//
//  Created by Sandra Grujovic on 29.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Thumbnail)
public class Thumbnail: NSManagedObject {

    convenience init(fileName: String, date: String, imageData: Data) {
        self.init(context: CoreDataManager.getCoreDataContext()!)
        self.fileName = fileName
        self.date = date
        self.imageData = NSData(data: imageData)
        self.id = UUID.init()
    }

    convenience init(fileName: String, date: String, imageData: Data, drawing: Drawing) {
        self.init(fileName: fileName, date: date, imageData: imageData)
        self.drawing = drawing
    }

    convenience init(thumbnail: Thumbnail) {
        self.init(fileName: thumbnail.fileName, date: thumbnail.date, imageData: thumbnail.imageData as Data, drawing: thumbnail.drawing)
    }

}
