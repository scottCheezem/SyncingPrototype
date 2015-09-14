//
//  NSManagedObject+Extension.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/11/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import CoreData

public extension NSManagedObject {
    
    /**
    Init method that allows NSManagedObjects to be created with the context and the name.
    
    - parameter context: The context for the object
    - parameter name:    The name of the entity
    */
    convenience init(context: NSManagedObjectContext, name: String) {
        let entity = NSEntityDescription.entityForName(name, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
}
