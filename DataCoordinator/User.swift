//
//  User.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData

public class User: NSManagedObject, Updateable, APIClass {
    
    /**
    Init method that allows a user to be created though User()
    */
    convenience init() {
        self.init(context: CoreDataManager.shared.managedObjectContext, name: "User")
        clientCreatedAt = NSDate()
    }
 
    @NSManaged public var firstName: String?
    
    @NSManaged public var serverUpdatedAt : NSDate
    @NSManaged public var clientUpdatedAt : NSDate
    @NSManaged public var serverCreatedAt : NSDate
    @NSManaged public var clientCreatedAt : NSDate
    @NSManaged public var isFullySynced: Bool

public func populateWithJson(jsonDict: NSDictionary) {
        
    }
    
    public func jsonRepresentation() -> NSDictionary {
        return [:]
    }
    
    public var apiEndPointForClass :String = "user"

}
