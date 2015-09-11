//
//  Syncable.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

protocol Syncable {
    
    var serverUpdatedAt : NSDate {get set}
    var clientUpdatedAt : NSDate {get set}
    
    var serverCreatedAt : NSDate { get set }
    var clientCreatedAt : NSDate { get set }
    
    var isFullySynced : Bool
}