//
//  CoreDataManager.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData

let kStoreName = "CoreDataTest.sqlite"
let kModmName = "CoreDataTest"

var _managedObjectContext: NSManagedObjectContext? = nil
var _managedObjectModel: NSManagedObjectModel? = nil
var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

public class CoreDataManager: NSObject {

    public static let shared = CoreDataManager()

    override init() {
        super.init()
        self.managedObjectContext
    }
    
    // MARK: Properties
    
    /// The managedObjectContext.insertedObjects
    var insertedObjectsNotSaved: [AnyObject]? {
        return Array(managedObjectContext.insertedObjects)
    }
    
    /// The managedObjectContext.deletedObjects
    var deletedObjectsNotSaved: [AnyObject]? {
        return Array(managedObjectContext.deletedObjects)
    }

    // MARK: Core Data stack

    /// Returns the managed object context.  If the context isn't on the main thread, it tries to get the current threads context.  If there isn't one, it creates one.
    public var managedObjectContext: NSManagedObjectContext {
        if NSThread.isMainThread() {
            if _managedObjectContext == nil {
                if let coordinator: NSPersistentStoreCoordinator? = self.persistentStoreCoordinator {
                    _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
                    _managedObjectContext!.persistentStoreCoordinator = coordinator
                }
                return _managedObjectContext!
            }
        } else {
            var threadContext : NSManagedObjectContext? = NSThread.currentThread().threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext
            
            print(NSThread.currentThread().threadDictionary)
            
            if threadContext == nil {
                print("creating new context")
                threadContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                threadContext!.parentContext = _managedObjectContext
                threadContext!.name = NSThread.currentThread().description
                
                NSThread.currentThread().threadDictionary["NSManagedObjectContext"] = threadContext
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"contextWillSave:" , name: NSManagedObjectContextWillSaveNotification, object: threadContext)
            } else {
                print("Using old context")
            }
            return threadContext!
        }
        return _managedObjectContext!
    }
    
    /// Returns the managed object model for the application.  If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle(forClass: self.dynamicType).URLForResource(kModmName, withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }


    /// Returns the persistent store coordinator for the application.  If the coordinator doesn't already exist, it is created and the application's store added to it.
    var persistentStoreCoordinator: NSPersistentStoreCoordinator {
        if _persistentStoreCoordinator == nil {
            let storeURL = self.applicationDocumentsDirectory.URLByAppendingPathComponent(kStoreName)
            _persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            do {
                try _persistentStoreCoordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: self.databaseOptions())
            } catch let error as NSError {
                if error.code >= NSPersistentStoreIncompatibleVersionHashError && error.code <= NSEntityMigrationPolicyError {
                    resetCoreData()
                }
                print(error.description)
            }
        }
        return _persistentStoreCoordinator!
    }
    
    // MARK: Utilities
    
    /**
    This is the function to use when wiping core data objects.  This deletes all objects from core data.
    
    - returns: If the operation was successful.
    */
    func cleanCoreData() -> Bool {
        print("Cleaning the core data database")
        
        var success: Bool = true
        
        for entity in managedObjectModel.entities {
            let fetchRequest = NSFetchRequest.init(entityName: entity.name!)
            fetchRequest.includesPropertyValues = false // only managedObjectID
            
            var objects = [AnyObject]()

            managedObjectContext.performBlockAndWait { () -> Void in
                do {
                    objects = try self.managedObjectContext.executeFetchRequest(fetchRequest)
                } catch let error as NSError {
                    success = false
                    print("An error has occurred while fetching " + error.description)
                }
            }
            
            managedObjectContext.performBlockAndWait { () -> Void in
                for object in objects {
                    self.managedObjectContext.deleteObject(object as! NSManagedObject)
                }
            }
        }
        
        if save() && success {
            print("Core data database has been successfully cleaned")
            return true
        } else {
            print("ERROR: Core data database has not been successfully cleaned")
            return false
        }
        
//        iOS 9
//        let fetchRequest = NSFetchRequest(entityName: entity.name!)
//        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
//        
//        do {
//            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: managedObjectContext)
//            print("Core data database has been successfully cleaned")
//        } catch let error as NSError {
//            print("An error has occurred while cleaning " + error.description)
//        }
    }

    /**
    This is the function to use when hard killing core data.  This deletes the persistent store files.
    */
    func resetCoreData() {
        print("Resetting the core data database")
        var success: Bool = true
        let storesArray = _persistentStoreCoordinator?.persistentStores
        
        if let stores = storesArray {
            for store in stores {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL((store.URL)!)
                    success = success && true
                } catch let error as NSError {
                    print(error.description)
                    success = false
                }
            }
        }
        
        // Reset - TODO Check validity
        _managedObjectContext = nil
        _persistentStoreCoordinator = nil
        
        // Recreate - TODO check validity
        self.managedObjectContext
        
        if success {
            print("Core data database has been successfully reset")
        } else {
            print("ERROR: Core data database has not been successfully reset")
        }
        
    }

    // MARK: Saving

    /**
    This is the function to use when saving core data objects.  This saves the context if it has changes and then saves the parent context if it exists.
    
    - returns: If the operation was successful.
    */
    func save() -> Bool {
        var success: Bool = false
        let context:NSManagedObjectContext = self.managedObjectContext
        if context.hasChanges {
            context.performBlockAndWait{
                do {
                    try context.save()
                    success = true
                } catch let error as NSError {
                    success = false
                    print(error.description)
                }
                
                if context.parentContext != nil {
                    context.parentContext!.performBlockAndWait{
                        do {
                            try context.parentContext!.save()
                        } catch let error as NSError {
                            success = false
                            print(error.description)
                        }
                    }
                }
            }
        }
        
        return success
    }

    func contextWillSave(notification: NSNotification) {
        let context : NSManagedObjectContext! = notification.object as! NSManagedObjectContext
        let insertedObjects : NSSet = context.insertedObjects
        if insertedObjects.count != 0 {
            do {
                try context.obtainPermanentIDsForObjects(insertedObjects.allObjects as! [NSManagedObject])
            } catch let error as NSError {
                print(error.description)
            }
        }
    }

    // MARK: Deletion

    /**
    This is the function to use when deleting core data objects.
    
    - parameter objects:  The objects to delete.
    - returns: If the operation was successful.
    */
    func deleteObjects(objects: [NSManagedObject]) -> Bool {
        for object in objects {
            object.managedObjectContext!.performBlockAndWait { () -> Void in
                object.managedObjectContext!.deleteObject(object)
            }
        }
        if save() {
            return true
        } else {
            return false
        }
    }
    
    // MARK: Fetch
    
    /**
    This is the function to use when requesting core data objects.
    
    - parameter request: The fetch request to use
    
    - returns: An array of optional core data objects.
    */
    func executeFetchRequest(request:NSFetchRequest) -> [AnyObject]? {
        var results: [AnyObject]?
        self.managedObjectContext.performBlockAndWait {
            do {
                results = try self.managedObjectContext.executeFetchRequest(request)
            } catch let error as NSError {
                print(error.description)
            }
        }
        return results
    }

    // MARK: Application's Documents directory

    // Returns the URL to the application's Documents directory.
    var applicationDocumentsDirectory: NSURL {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.endIndex-1] as NSURL
    }

    func databaseOptions() -> Dictionary <String,Bool> {
        var options =  Dictionary<String,Bool>()
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        return options
    }
}