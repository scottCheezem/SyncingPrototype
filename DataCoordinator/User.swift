//
//  User.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData

public class User: NSManagedObject, Syncable {
    
    /**
    Init method that allows a user to be created though User()
    */
    convenience init() {
        print("Creating a User")
        self.init(context: CoreDataManager.shared.managedObjectContext, name: "User")
        clientCreatedAt = NSDate()
    }
 
    @NSManaged public var firstName: String?
    
    @NSManaged public var serverUpdatedAt : NSDate
    @NSManaged public var clientUpdatedAt : NSDate
    @NSManaged public var serverCreatedAt : NSDate
    @NSManaged public var clientCreatedAt : NSDate
    @NSManaged public var updatedOnClientAndServer : Bool

    public func populateWithJson(jsonDict: NSDictionary) {
        firstName = jsonDict["first_name"] as? String
        
        serverCreatedAt = NSDate.parse((jsonDict["created_at"] as? String)!)
        serverUpdatedAt = NSDate.parse((jsonDict["updated_at"] as? String)!)
                
    }
    
    public func jsonRepresentation() -> NSDictionary {
        
        
        return ["first_name":firstName!, "created_at":clientCreatedAt.toString(), "updated_at":clientCreatedAt.toString(), ]
    }
    
    static public var apiEndPointForClass :String = "user"
    
    
}
