//
//  User.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData

@objc
public class User: NSManagedObject, Updateable {
    
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
}
