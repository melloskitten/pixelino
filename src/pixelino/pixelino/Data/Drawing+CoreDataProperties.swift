//
//  Drawing+CoreDataProperties.swift
//  pixelino
//
//  Created by Sandra Grujovic on 29.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

extension Drawing {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Drawing> {
        return NSFetchRequest<Drawing>(entityName: "Drawing")
    }

    @NSManaged public var width: Int64
    @NSManaged public var height: Int64
    @NSManaged public var colorArray: [UIColor]
    @NSManaged public var thumbnail: Thumbnail
    @NSManaged public var id: UUID

}
