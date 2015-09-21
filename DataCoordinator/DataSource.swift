//
//  DataSource.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import CoreData

public class DataSource: NSObject {
    
    public static let sharedInstance = DataSource()
    
    // MARK: Saving
    
    /**
    The function to use when needing to save the context.
    
    - returns: If the operation was successful.
    */
    public func save() -> Bool {
        if CoreDataManager.shared.save() {
            return true
        } else {
            return false
        }
    }
    
    /**
    The function to use when needing to save one or more objects into core data.
    
    - parameter objects:           The objects to save.
    - returns: The set of objects that have been inserted into the receiver but not yet saved in a persistent store.
    */
    public func saveObjects(objects: [APIClass]) -> [AnyObject]? {
        for object in objects {
            if var sync = object as? Syncable {
                sync.clientUpdatedAt = NSDate()
            }
        }
        
        CoreDataManager.shared.save()
        
        return CoreDataManager.shared.insertedObjectsNotSaved
    }
    
    // MARK: Deleting
    
    /**
    The function to use when needing to delete an object from core data.
    
    - parameter objects: The objects to delete
    - returns: The set of objects that will be removed from their persistent store during the next save operation.
    */
    public func deleteObjects(objects: [APIClass]) -> [AnyObject]? {
        let nsManagedObjects = objects.map {$0 as! NSManagedObject}
        CoreDataManager.shared.deleteObjects(nsManagedObjects)
        return CoreDataManager.shared.deletedObjectsNotSaved
    }
    
    // MARK: Retrieving
    
    /**
    The function to use when needing all the core data objects of a class.
    
    - parameter cls: The class to retrieve core data objects for.
    
    - returns: An array of core data objects.
    */
    public func allObjectsOfClass(cls: APIClass.Type) -> [AnyObject]? {
        for entity in CoreDataManager.shared.managedObjectModel.entities {
            if entity.name == cls.name {
                let fetchRequest = NSFetchRequest(entityName: cls.name)
                return CoreDataManager.shared.executeFetchRequest(fetchRequest)
            }
        }
        return nil
    }
    
    /**
    This is the function to use when requesting core data objects.
    
    - parameter request: The fetch request to use
    
    - returns: An array of optional core data objects.
    */
    func executeFetchRequest(request: NSFetchRequest) -> [AnyObject]? {
        return CoreDataManager.shared.executeFetchRequest(request)
    }
    
    // MARK: Managing
    
    /**
    This is the function to use when wiping core data objects.  This deletes all objects from core data.
    
    - returns: If the operation was successful.
    */
    public func cleanCoreData() -> Bool {
        if CoreDataManager.shared.cleanCoreData() {
            return true
        } else {
            return false
        }
    }
    
    /**
    This is the function to use when hard killing core data.  This deletes the persistent store files.
    */
    public func resetCoreData() {
        CoreDataManager.shared.resetCoreData()
    }
}
