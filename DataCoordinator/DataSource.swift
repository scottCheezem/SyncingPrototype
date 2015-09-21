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
    - returns: If the operation was successful.
    */
    public func saveObjects(objects: [AnyObject]) -> Bool {
        for object in objects {
            if object.isKindOfClass(User) {
                let user = object as! User
                user.clientUpdatedAt = NSDate()
            }
        }
        if CoreDataManager.shared.save() {
            return true
        } else {
            return false
        }
    }
    
    /**
    The function to use when needing to delete an object from core data.
    
    - parameter objects: The objects to delete
    - returns: If the operation was successful.
    */
    public func deleteObjects(objects: [APIClass]) -> Bool {
        let nsManagedObjects = objects.map {$0 as! NSManagedObject}
        if CoreDataManager.shared.deleteObjects(nsManagedObjects) {
            return true
        } else {
            return false
        }
    }
    
    /**
    The function to use when needing all the core data objects of a class.
    
    - parameter cls: The class to retrieve core data objects for.
    
    - returns: An array of core data objects.
    */
    public func allObjectsOfClass(cls: AnyClass) -> [AnyObject]? {
        if cls == User.self {
            let userFetchRequest = NSFetchRequest(entityName: "User")
            return CoreDataManager.shared.executeFetchRequest(userFetchRequest)
        }
        return nil
    }
    
    /**
    This is the function to use when requesting core data objects.
    
    - parameter request: The fetch request to use
    
    - returns: An array of optional core data objects.
    */
    func executeFetchRequest(request:NSFetchRequest) -> [AnyObject]? {
        return CoreDataManager.shared.executeFetchRequest(request)
    }
    
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
