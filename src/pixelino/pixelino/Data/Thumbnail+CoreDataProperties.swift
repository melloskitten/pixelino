//
//  Thumbnail+CoreDataProperties.swift
//  pixelino
//
//  Created by Sandra Grujovic on 29.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//
//

import Foundation
import CoreData

extension Thumbnail {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thumbnail> {
        return NSFetchRequest<Thumbnail>(entityName: "Thumbnail")
    }

    @NSManaged public var date: String
    @NSManaged public var fileName: String
    @NSManaged public var imageData: NSData
    @NSManaged public var drawing: Drawing

}
