//
//  User.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData

public class User: NSManagedObject,APIClass {

// Insert code here to add functionality to your managed object subclass
    
    
    public func populateWithJson(jsonDict: NSDictionary) {
        
    }
    
    public func jsonRepresentation() -> NSDictionary {
        return [:]
    }
    
    public var apiEndPointForClass :String = "user"

}
