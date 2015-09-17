//
//  DataCoordinator.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit

public class DataCoordinator: NSObject, SyncingDataSource, SyncingNetworkService {
    
    /// service used to handle the logic for syncing data between the device and the server.
    private var serverAndClientSyncingService : ServerAndClientSyncService!
    
    /// Object that is used to interact with objects that are stored on the device.
    private let dataSource = DataSource()
    
    
    init(clientUpdateableClasses : [String : AnyClass], serverUpdateableClasses : [String : AnyClass]) {
        super.init()
        serverAndClientSyncingService = ServerAndClientSyncService(withDataSource: self, networkService: self, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdateableClasses)
    }
    /**
    Syncs all objects that are not updated on either the client or the server.
    
    - parameter completion: block to be performed upon both the server and the client
    being updated.
    */
    public func syncClientAndServerWithCompletion(completion : () -> Void) {
        
    }
    
    //TODO:Decide where to implement these protocols
    //MARK: SyncingNetworkService 
    internal func getObjectsFromServerOfClass(cls: AnyClass, withCompletion completion: (objects: [Syncable]?, error: NSError?) -> Void) {
        
    }
    
    internal func postObjects(objects: [Updateable], withCompletion completion: (objects: [Updateable]?, error: NSError?) -> Void) {
        
    }
    
    //MARK: SyncingDataSource
    public func saveObjects(objects: [DevicePersistedClass]) -> Bool {
        let objectsToCreate = filterOutObjectsThatAreNew(objects)
        let objectsToUpdate = filterOutObjectsThatAreBeingUpdated(objects)
        let updatedObjectsToSave = savedObjectsUpdatedFromCounterparts(objectsToUpdate)
        
        let totalObjectsToSave = objectsToCreate + updatedObjectsToSave
        let objectsToSaveCasted = totalObjectsToSave.map {$0 as! AnyObject}
    
        let savedSuccessfully = dataSource.saveObjects(objectsToSaveCasted)
        
        return savedSuccessfully
    }
    
    /**
    Filters out objects in the array that do not have a counterpart in
    the database.
    
    - warning: All passed in objects must be of the same class type.
    
    - parameter objects: objects that need to be filtered
    
    - returns: objects that do not have a counterpart stored on the device.
    */
    private func filterOutObjectsThatAreNew(objects : [DevicePersistedClass]) -> [DevicePersistedClass] {
        let objectsNotYetPersisted = objects.filter {[weak self] in
            guard let weakself = self else {return false}
            return !weakself.objectIsPersistedOnDevice($0)
        }
        
        return objectsNotYetPersisted
    }

    /**
    Filters out objects that have a counterpart stored on the database.
    
    - parameter objects: Objects that need to filtered
    
    - returns: Objects that have counterparts on the device.
    */
    private func filterOutObjectsThatAreBeingUpdated(objects : [DevicePersistedClass]) -> [DevicePersistedClass] {
        let objectsThatArePersisted = objects.filter {[weak self] in
            guard let weakself = self else {return false}
            return !weakself.objectIsPersistedOnDevice($0)
        }
        
        return objectsThatArePersisted
    }
    
    /**
    Determines if a representation of the passed in object is stored on the device.
    
    - parameter object: Object to determine if it has a represention persisted on the device.
    
    - returns: Bool indiciating if the object is stored on the device.
    */
    private func objectIsPersistedOnDevice(object : DevicePersistedClass) -> Bool {
        
        let classForObject : AnyObject.Type = object.dynamicType as! AnyObject.Type
        let allObjectsCurrentlyStored = allObjectsOfClass(classForObject)
        
        let counterpartObjects = allObjectsCurrentlyStored.filter {object.predicateForFindingThisObject().evaluateWithObject($0)}
        
        //We should never have more than one representation of an object on the device.
        guard counterpartObjects.count < 2 else {
            assert(false, "passed in object has more than one instance on the device.")
            return true
        }
        
        return counterpartObjects.count > 0
    }
    
    /**
    
    Takes objects that have only been created in memory or from the server and uses their information
    to update their counterparts that werre stored on the device.
    
    - parameter counterPartObjects: Objects that will be used to configure their counterparts on the device.
    
    - returns: Objects that are from the device updated with the passed in parameter.
    
    */
    private func savedObjectsUpdatedFromCounterparts(counterPartObjects : [DevicePersistedClass]) -> [DevicePersistedClass] {
        
        return [DevicePersistedClass]()
    }
    
    
    public func deleteObjects(objects: [DevicePersistedClass]) -> Bool {
        return true
    }
    
    public func allObjectsOfClass(cls: AnyClass) -> [AnyObject] {
        return [AnyObject]()
    }
}
