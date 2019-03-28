//
//  CoreDataManager.swift
//  pixelino
//
//  Created by Sandra Grujovic on 27.08.18.
//  Copyright © 2018 Sandra Grujovic. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {

    // Fetches core data context needed for all loading/storing requests.
    public class func getCoreDataContext() -> NSManagedObjectContext? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: Color History Save/Load functions.

    // (Potential) FIXME: Reduce max. amount of saved units in ColorHistory entity to 20.
    // Removes entire color history.
    public static func deleteColorHistory() {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ColorHistory")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    // Removes one particular color from color history.
    public static func deleteColorInColorHistory(color: UIColor) {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ColorHistory")
        deleteFetch.predicate = NSPredicate(format: "color == %@", color)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    // Saves current color history to CoreData.
    public static func saveColorInColorHistory(color: UIColor) {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        let colorHistoryEntity = NSEntityDescription.entity(forEntityName: "ColorHistory", in: managedContext)!
        let colorHistoryObject = NSManagedObject(entity: colorHistoryEntity, insertInto: managedContext)

        // Perform actual saving request.
        colorHistoryObject.setValue(color, forKey: "color")

        do {
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // Loads the currently available color history.
    public static func loadColorHistory() -> [UIColor]? {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return nil
        }

        // Perform actual fetch request & save to local colorHistory array.
        // Note: The color history is sorted by most recently used color first.
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ColorHistory")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            var fetchedColorHistory = [UIColor]()
            //swiftlint:disable:next force_cast
            for data in result as! [NSManagedObject] {
                //swiftlint:disable:next force_cast
                fetchedColorHistory.insert(data.value(forKey: "color") as! UIColor, at: 0)
            }
            return fetchedColorHistory

        } catch let error as NSError {
            print("Could not load any color history. \(error), \(error.userInfo)")
            return nil
        }
    }

    // MARK: Drawing Load/Save - this is used when user saves image to app.

    /// Save the current state of the canvas to Core Data, as well as its width and height (both
    /// in 'amount of pixels'). This saving function incorporates both the creation of a completely
    /// new drawing, as well as updating a drawing that is already existing.
    /// If a drawing is already existing, the a reference oldThumbnail has to be provided,
    /// as it needs to be deleted from the database as well.
    /// - WARNING: There seems to be a problem with the current method. No matter
    /// whether it tries to save a new or update an existing drawing, it never
    /// enters the second part of the if statement. This implies that somehow,
    /// it manages to find a drawing with the same id that is already saved, which should not
    /// be the case.
    public static func saveDrawing(drawing: Drawing, oldThumbnail: Thumbnail? = nil) {
            if updateDrawing(updatedDrawing: drawing) {
                if let oldThumbnail = oldThumbnail {
                    deleteThumbnail(thumbnail: oldThumbnail)
                }
                return
            } else {
            // Grab Core Data context.
            guard let managedContext = drawing.managedObjectContext else {
                return
            }

            do {
                try managedContext.save()
            } catch let error as NSError {
                // FIXME: Implement proper error handling.
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    /// Creates a duplicate version of a drawing and saves it to core data.
    /// This method assumes that the thumbnail connection has already
    /// been set up manually.
    /// - Note: This expects a deep copy of the original drawing
    /// as an input.
    /// - Parameter drawing: The drawing that should be saved.
    public static func duplicateDrawing(duplicatedDrawing drawing: Drawing) {
        // Grab Core Data context.
        guard let managedContext = drawing.managedObjectContext else {
            return
        }

        do {
            try managedContext.save()

        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not duplicate drawing. \(error), \(error.userInfo)")
        }
    }

    /// Updates an already existing drawing and returns true or false depending on whether
    /// the update was successful or not. (It is also unsuccessful when the drawing is not
    /// yet in the database, thus cannot be updated.)
    public static func updateDrawing(updatedDrawing: Drawing) -> Bool {
        // Grab Core Data context.
        guard let managedContext = updatedDrawing.managedObjectContext else {
            return false
        }

        let updateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Drawing")
        updateRequest.predicate = NSPredicate(format: "id = %@", updatedDrawing.id as CVarArg)

        do {
            let result = try managedContext.fetch(updateRequest)

            if result.count > 0 {
                if let fetchResults = result as? [NSManagedObject] {
                    for fetchResult in fetchResults {
                        fetchResult.setValue(updatedDrawing.colorArray, forKey: "colorArray")
                        fetchResult.setValue(updatedDrawing.thumbnail, forKey: "thumbnail")
                    }

                    try managedContext.save()

                    return true
                }

            }

        } catch let error as NSError {
            print("Could not update any drawings. \(error), \(error.userInfo)")
        }

        return false
    }

    public static func loadAllDrawings() -> [Drawing]? {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return nil
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Drawing")
        request.returnsObjectsAsFaults = false
        do {
            let result = try managedContext.fetch(request)
            var drawings = [Drawing]()

            //swiftlint:disable:next force_cast
            for data in result as! [Drawing] {
                drawings.append(data)
            }
            return drawings

        } catch let error as NSError {
            print("Could not load any drawings. \(error), \(error.userInfo)")
            return nil
        }
    }

    public static func updateThumbnail(oldThumbnail: Thumbnail) -> Bool {
        // Grab Core Data context.
        guard let managedContext = oldThumbnail.managedObjectContext else {
            return false
        }

        let updateRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
        updateRequest.predicate = NSPredicate(format: "id == %@", oldThumbnail.id as CVarArg)

        do {
            let result = try managedContext.fetch(updateRequest)

            if result.count > 0 {
                if let fetchResults = result as? [NSManagedObject] {
                    for fetchResult in fetchResults {
                        fetchResult.setValue(oldThumbnail.date, forKey: "date")
                        fetchResult.setValue(oldThumbnail.fileName, forKey: "fileName")
                        fetchResult.setValue(oldThumbnail.imageData, forKey: "imageData")
                        fetchResult.setValue(oldThumbnail.drawing, forKey: "drawing")
                    }

                    try managedContext.save()

                    return true
                }

            }

        } catch let error as NSError {
            print("Could not update any drawings. \(error), \(error.userInfo)")
        }

        return false
    }

    public static func deleteThumbnail(thumbnail: Thumbnail) {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
        deleteFetch.predicate = NSPredicate(format: "id == %@", thumbnail.id as CVarArg)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete thumbnail. \(error), \(error.userInfo)")
        }
    }

    public static func loadAllThumbnails() -> [Thumbnail]? {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return nil
        }

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
        request.returnsObjectsAsFaults = false

        do {
            let result = try managedContext.fetch(request)
            var thumbnails = [Thumbnail]()

            //swiftlint:disable:next force_cast
            for data in result as! [Thumbnail] {
                thumbnails.append(data)
            }
            return thumbnails

        } catch let error as NSError {
            print("Could not load any thumbnails. \(error), \(error.userInfo)")
            return nil
        }
    }

    /// Removes all existing thumbnails.
    public static func deleteThumbnails() {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    /// Removes one particular drawing (based on the corresponding thumbnail).
    public static func deleteDrawing(correspondingThumbnail: Thumbnail) {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Thumbnail")
        deleteFetch.predicate = NSPredicate(format: "id == %@", correspondingThumbnail.id as CVarArg)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    /// Removes all existing drawings.
    public static func deleteDrawings() {
        // Grab Core Data context.
        guard let managedContext = getCoreDataContext() else {
            return
        }

        // Perform actual deletion request.
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Drawing")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
        } catch let error as NSError {
            // FIXME: Implement proper error handling.
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
}
