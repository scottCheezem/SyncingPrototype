//
//  BrushEvent.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/21/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData
import DataCoordinator

class BrushEvent: NSManagedObject,Syncable {

    static internal var name: String = "BrushEvent"
    
    convenience init(){
        print("creating a brush event")
        self.init(context:CoreDataManager.shared.managedObjectContext, name:BrushEvent.name)
        clientCreatedAt = NSDate()
    }

    // MARK: APIClass
    
    static var apiEndPointForClass: String = "events"
    
    func populateWithJson(jsonDict: NSDictionary) {
        
    }
    
    func jsonRepresentation() -> NSDictionary {
        return [:]
    }
    
    static var primaryKeyTitle: String = "brushEventID"
    
    var primaryKeyValue : String {
        get {
            return brushEventID!
        }
    }
    
    // MARK: Updateable
    @NSManaged var clientCreatedAt: NSDate
    @NSManaged var updatedOnClientAndServer: Bool
    // Mark: Syncable
    @NSManaged var serverUpdatedAt: NSDate
    @NSManaged var serverCreatedAt: NSDate
    @NSManaged var clientUpdatedAt: NSDate
    @NSManaged var deletedAt: NSDate?
    
    // MARK: Class specific properties
    @NSManaged var brushEventID: String?
    @NSManaged var brushEventType: String?
    @NSManaged var customData: String?
    @NSManaged var endTime: NSDate?
    @NSManaged var startTime: NSDate?
    @NSManaged var device: NSManagedObject?

    

}
