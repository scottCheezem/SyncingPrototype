//
//  Configurations.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/17/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

/**
*  Class used to configure the DataCoordinator and its properties upon creation
*/

public struct Configurations {
    
    public init(){
        baseURL = ""
        serverUpdateableClasses = [:]
        clientUpdateableClasses = [:]
    }
    
    /// Represents the base URL for the API endpoint.
    public var baseURL : String
    
    /// Dictionary of classes that the coordinator will update from the server when synchronizing data.
    public var serverUpdateableClasses : [String : Syncable.Type]
    
    /// Dictionary of classes that the coordinator will update from the client when syncronizing data.
    public var clientUpdateableClasses : [String : Updateable.Type]
}