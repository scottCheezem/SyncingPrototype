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
    
    public func save(completionHandler:(success: Bool) -> Void) -> () {
        CoreDataManager.shared.save { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    public func saveObjects(objects: [AnyObject], completionHandler:(success: Bool) -> Void) -> () {
        CoreDataManager.shared.save { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    public func deleteObjects(objects: [AnyObject], completionHandler:(finished: Bool) -> Void) -> () {
        for object in objects {
            CoreDataManager.shared.deleteEntity(object as! User, completionHandler: { (finished) -> Void in
                self.performFetch()
            })
        }
        completionHandler(finished: true)
    }
    
    public func allObjectsOfClass(cls: AnyClass) -> [AnyObject]? {
        if cls == User.self {
            return userFetchedResultsController?.fetchedObjects
        }
        return nil
    }
    
    public func cleanCoreData(completionHandler:(success: Bool) -> Void) -> () {
        CoreDataManager.shared.cleanCoreData { (success) -> Void in
            self.performFetch()
            completionHandler(success: success)
        }
    }
    
    public func resetCoreData() {
        CoreDataManager.shared.resetCoreData()
    }
    
    // #pragma mark - NSFetchedResultsControllerDelegate
    
    public func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        if delegate != nil && delegate.respondsToSelector("todo") {
//            delegate.todo()
//        }
    }
    
    internal func performFetch() {
        do {
            try userFetchedResultsController?.performFetch()
        } catch let error as NSError {
            print(error.description)
        }
    }
}
