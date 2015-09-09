//
//  DataSource.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//
import CoreData

class DataSource : NSObject, NSFetchedResultsControllerDelegate {

    private var userFetchedResultsController : NSFetchedResultsController?
    
    static let sharedInstance = DataSource()
    
    override init () {
        CoreDataManager.shared.initialize()
        
        let userFetchRequest = NSFetchRequest(entityName: "User")
        let sortDescriptor = NSSortDescriptor(key: "firstName", ascending: false)
        userFetchRequest.sortDescriptors = [sortDescriptor]
        
        if userFetchedResultsController == nil {
            userFetchedResultsController = NSFetchedResultsController(fetchRequest: userFetchRequest, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        do {
          try userFetchedResultsController?.performFetch()
        } catch let error as NSError {
            print(error.description)
        }
        
        super.init()
    }
    
    func save() {
        CoreDataManager.shared.save()
    }
    
    func saveObjects(objects: [AnyObject]) {
        CoreDataManager.shared.save()
    }
    
    func deleteObjects(objects: [AnyObject]) {
        for object in objects {
            CoreDataManager.shared.deleteEntity(object as! User)
        }
    }
    
    func allObjectsOfClass(cls: AnyClass, completionHandler:(results: [AnyObject]?) -> Void) -> (){
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName("User", inManagedObjectContext: CoreDataManager.shared.managedObjectContext)
        CoreDataManager.shared.executeFetchRequest(fetchRequest) { (results) -> Void in
            completionHandler(results: results)
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        if delegate != nil && delegate.respondsToSelector("todo") {
//            delegate.todo()
//        }
    }
}