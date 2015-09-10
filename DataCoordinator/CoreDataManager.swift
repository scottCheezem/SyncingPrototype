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

    // #pragma mark - Core Data stack

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
            var threadContext : NSManagedObjectContext? = NSThread.currentThread().threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext;
            
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
            return threadContext!;
        }
        return _managedObjectContext!
    }
    
    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle(forClass: self.dynamicType).URLForResource(kModmName, withExtension: "momd")
            _managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        }
        return _managedObjectModel!
    }

    // Returns the persistent store coordinator for the application.
    // If the coordinator doesn't already exist, it is created and the application's store added to it.
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
    
    func cleanCoreData() {
        print("Resetting the core data database");

        let fetchRequest = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try persistentStoreCoordinator.executeRequest(deleteRequest, withContext: managedObjectContext)
            print("Core data database has been successfully cleaned");
        } catch let error as NSError {
            print("An error has occurred while cleaning " + error.description)
        }
    }
    
    func resetCoreData() {
        let storesArray = _persistentStoreCoordinator?.persistentStores
        
        if let stores = storesArray {
            for store in stores {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL((store.URL)!)
                } catch let error as NSError {
                    print(error.description)
                }
            }
        }
        
        // Reset - TODO Check validity
        _managedObjectContext = nil
        _persistentStoreCoordinator = nil
        
        // Recreate
        self.managedObjectContext
    }
    
    // #pragma mark - fetches

//    func executeFetchRequest(request:NSFetchRequest) -> [AnyObject]? {
//        var results:[AnyObject]?
//        self.managedObjectContext.performBlockAndWait{
//            do {
//                results = try self.managedObjectContext.executeFetchRequest(request)
//            } catch let error as NSError {
//                print("Warning!! \(error.description)")
//            }
//        }
//        return results
//    }
//
//    func executeFetchRequest(request:NSFetchRequest, completionHandler:(results: [AnyObject]?) -> Void) -> () {
//        self.managedObjectContext.performBlock{
//            var results:[AnyObject]?
//            do {
//                results = try self.managedObjectContext.executeFetchRequest(request)
//            } catch let error as NSError {
//                print(error.description)
//            }
//            completionHandler(results: results)
//        }
//    }

    // #pragma mark - save methods

    func save(completionHandler:(finished: Bool) -> Void) -> () {
        let context:NSManagedObjectContext = self.managedObjectContext;
        if context.hasChanges {
            context.performBlockAndWait{
                do {
                    try context.save()
                } catch let error as NSError {
                    print(error.description)
                }
                
                if context.parentContext != nil {
                    context.parentContext!.performBlockAndWait{
                        do {
                            try context.parentContext!.save()
                        } catch let error as NSError {
                            print(error.description)
                        }
                    }
                }
                completionHandler(finished: true)
            }
        }
    }

    func contextWillSave(notification:NSNotification){
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

    // #pragma mark - Utilities

    func deleteEntity(object:NSManagedObject, completionHandler:(finished: Bool) -> Void) -> () {
        object.managedObjectContext!.deleteObject(object)
        save { (finished) -> Void in
            completionHandler(finished: finished)
        }
    }

    // #pragma mark - Application's Documents directory

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