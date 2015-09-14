//
//  Syncable.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

protocol Updateable: APIClass {
    
    var clientCreatedAt : NSDate { get set }
    var updatedOnClientAndServer : Bool { get set }
}

protocol Syncable: Updateable {
    
    var serverUpdatedAt : NSDate { get set }
    var clientUpdatedAt : NSDate { get set }
    var serverCreatedAt : NSDate { get set }
}