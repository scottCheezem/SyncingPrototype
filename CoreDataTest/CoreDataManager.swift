//
//  CoreDataManager.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit
import CoreData

let kStoreName = "CoreDataTest.sqlite"
let kModmName = "CoreDataTest"


var _managedObjectContext: NSManagedObjectContext? = nil
var _managedObjectModel: NSManagedObjectModel? = nil
var _persistentStoreCoordinator: NSPersistentStoreCoordinator? = nil

class CoreDataManager: NSObject {


    class var shared:CoreDataManager{
        get {
            struct Static {
                static var instance : CoreDataManager? = nil
                static var token : dispatch_once_t = 0
            }
            dispatch_once(&Static.token) { Static.instance = CoreDataManager() }
            
            return Static.instance!
        }
    }


    func initialize(){
        self.managedObjectContext
    }

    // #pragma mark - Core Data stack

    var managedObjectContext: NSManagedObjectContext{
        
        if NSThread.isMainThread() {
            
            if _managedObjectContext == nil {
                let coordinator = self.persistentStoreCoordinator
                
                _managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
                _managedObjectContext!.persistentStoreCoordinator = coordinator
                
                return _managedObjectContext!
            }
            
        }else{
            
            var threadContext : NSManagedObjectContext? = NSThread.currentThread().threadDictionary["NSManagedObjectContext"] as? NSManagedObjectContext;
            
            print(NSThread.currentThread().threadDictionary)
            
            if threadContext == nil {
                print("creating new context")
                threadContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
                threadContext!.parentContext = _managedObjectContext
                threadContext!.name = NSThread.currentThread().description
                
                NSThread.currentThread().threadDictionary["NSManagedObjectContext"] = threadContext
                
                NSNotificationCenter.defaultCenter().addObserver(self, selector:"contextWillSave:" , name: NSManagedObjectContextWillSaveNotification, object: threadContext)
                
            }else{
                print("using old context")
            }
            return threadContext!;
        }
        
        return _managedObjectContext!
    }



    // Returns the managed object model for the application.
    // If the model doesn't already exist, it is created from the application's model.
    var managedObjectModel: NSManagedObjectModel {
        if _managedObjectModel == nil {
            let modelURL = NSBundle.mainBundle().URLForResource(kModmName, withExtension: "momd")
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
                print(error.description)
                abort()
            }
        }
        return _persistentStoreCoordinator!
    }



    // #pragma mark - fetches

    func executeFetchRequest(request:NSFetchRequest)-> Array<AnyObject>?{
        
        var results:Array<AnyObject>?
        self.managedObjectContext.performBlockAndWait{
            do {
                results = try self.managedObjectContext.executeFetchRequest(request)
            } catch let error as NSError {
                print("Warning!! \(error.description)")
            }
        }
        return results
        
    }


    func executeFetchRequest(request:NSFetchRequest, completionHandler:(results: Array<AnyObject>?) -> Void)-> (){
        
        self.managedObjectContext.performBlock{
            var results:Array<AnyObject>?
            
            do {
                results = try self.managedObjectContext.executeFetchRequest(request)
            } catch let error as NSError {
                print(error.description)
            }
            
            completionHandler(results: results)
        }
        
    }



    // #pragma mark - save methods

    func save() {
        
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


    func deleteEntity(object:NSManagedObject)-> () {
        object.managedObjectContext!.deleteObject(object)
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