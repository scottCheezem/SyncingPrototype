//
//  DataSource.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import CoreData

public class DataSource : NSObject, NSFetchedResultsControllerDelegate {

    private var userFetchedResultsController : NSFetchedResultsController?
    
    public static let sharedInstance = DataSource()
    
    override init () {
        let userFetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: false)
        userFetchRequest.sortDescriptors = [sortDescriptor]
        
        if userFetchedResultsController == nil {
            userFetchedResultsController = NSFetchedResultsController(fetchRequest: userFetchRequest, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        super.init()
        
        performFetch()
    }
    
    /**
    The function to use when needing to save the context.
    
    - parameter completionHandler: Passes a success bool.
    */
    public func save(completionHandler:(success: Bool) -> Void) -> () {
        CoreDataManager.shared.save { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    /**
    The function to use when needing to save one or more objects into core data.
    
    - parameter objects:           The objects to save.
    - parameter completionHandler: Passes a success bool.
    */
    public func saveObjects(objects: [AnyObject], completionHandler:(success: Bool) -> Void) -> () {
        for object in objects {
            if object.isKindOfClass(User) {
                let user = object as! User
                user.clientUpdatedAt = NSDate()
            }
        }
        CoreDataManager.shared.save { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    /**
    The function to use when needing to delete an object from core data.
    
    - parameter objects:           The objects to delete
    - parameter completionHandler: Passes a success bool.
    */
    public func deleteObjects(objects: [AnyObject], completionHandler:(finished: Bool) -> Void) -> () {
        for object in objects {
            CoreDataManager.shared.deleteEntity(object as! User, completionHandler: { (finished) -> Void in
                self.performFetch()
            })
        }
        completionHandler(finished: true)
    }
    
    /**
    The function to use when needing all the core data objects of a class.
    
    - parameter cls: The class to retrieve core data objects for.
    
    - returns: An array of core data objects.
    */
    public func allObjectsOfClass(cls: AnyClass) -> [AnyObject]? {
        if cls == User.self {
            return userFetchedResultsController?.fetchedObjects
        }
        return nil
    }
    
    /**
    This is the function to use when wiping core data objects.  This deletes all objects from core data.
    
    - parameter completionHandler: Passes a success bool.
    */
    public func cleanCoreData(completionHandler:(success: Bool) -> Void) -> () {
        CoreDataManager.shared.cleanCoreData { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    /**
    This is the function to use when hard killing core data.  This deletes the persistent store files.
    */
    public func resetCoreData() {
        CoreDataManager.shared.resetCoreData()
    }
    
    // #pragma mark - NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        if delegate != nil && delegate.respondsToSelector("todo") {
//            delegate.todo()
//        }
    }
    
    /**
    The function to update the fetched results controller.
    */
    internal func performFetch() {
        do {
            try userFetchedResultsController?.performFetch()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
}
