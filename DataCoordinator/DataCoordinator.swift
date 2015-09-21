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
    
    private var apiClient : APIClient
    
    /**
    Main Initializer
    
    - parameter clientUpdateableClasses: Classes that will be can be 
      updated on the device and sent to the server.
    
    - parameter serverUpdateableClasses: Classes that can be updated 
      on the server and sent to the device.
    
    - returns: Instance of data coordinator
    */
    init(withConfiguration configuration : Configurations) {
        
        apiClient = APIClient(aBaseUrl: configuration.baseURL)
        super.init()
        serverAndClientSyncingService = ServerAndClientSyncService(withDataSource: self, networkService: self, serverUpdateableClasses: configuration.serverUpdateableClasses, andClientUpdateableClasses: configuration.clientUpdateableClasses)
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
    internal func getObjectsFromServerOfClass(cls: Updateable.Type, withCompletion completion: (objects: [Syncable]?, error: NSError?) -> Void) {
       
    }
    
    internal func postObjects(objects: [Updateable], withCompletion completion: (objects: [Updateable]?, error: NSError?) -> Void) {
        
    }
    
    //MARK: SyncingDataSource
    
    /**
    Saves the passed in objects to the device.
    
    - parameter objects: Objects to save to the device.
    
    - returns: Bool indicating if the objects were successfully saved.
    */
    public func saveObjects(objects: [APIClass]) -> [AnyObject]? {
        
        let seperatedObjects = seperateObjectsIntoNewAndUpdatedArrays(objects)
        
        let allObjectsToSave = seperatedObjects.newObjects + seperatedObjects.updatedObjects
        
        return self.dataSource.saveObjects(allObjectsToSave)
    }
    
    /**
    Seperates the passed in objects into objects that need to be 
    updated and objects that are new for saving to the device.
    
    - parameter objects: Objects that need to configured and seperated for saving to the device.
    
    - returns: Tuple containing objects that will be newly saved to the device and objects that are being updated on the device.
    */
    private func seperateObjectsIntoNewAndUpdatedArrays(objects : [APIClass]) -> (newObjects : [APIClass], updatedObjects : [APIClass]) {
        
        var newObjects = [APIClass]()
        var updatedObjects = [APIClass]()
        
        for object in objects {
            let deviceCounterPartOptional = findCounterpartOnDeviceForObject(object)
            if let deviceCounterPart = deviceCounterPartOptional {
                
                deviceCounterPart.updateWithContentsOfAPIClassObject(object)
                updatedObjects.append(deviceCounterPart)
                
            } else {
                newObjects.append(object)
            }
        }
        
        return (newObjects, updatedObjects)
    }
    
    /**
    Filters out objects in the array that do not have a counterpart in
    the database.
    
    - warning: All passed in objects must be of the same class type.
    
    - parameter objects: objects that need to be filtered
    
    - returns: objects that do not have a counterpart stored on the device.
    */
    private func filterOutObjectsThatAreNew(objects : [APIClass]) -> [APIClass] {
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
    private func filterOutObjectsThatAreBeingUpdated(objects : [APIClass]) -> [APIClass] {
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
    private func objectIsPersistedOnDevice(object : APIClass) -> Bool {
        
        let allObjectsCurrentlyStored = allObjectsOfClass(object.dynamicType)
        let counterpartObjects = allObjectsCurrentlyStored.filter {object.predicateForFindingThisObject().evaluateWithObject($0)}
        
        //We should never have more than one representation of an object on the device.
        guard counterpartObjects.count < 2 else {
            assert(false, "passed in object has more than one instance on the device.")
            return true
        }
        
        return counterpartObjects.count > 0
    }
    
    /**
    Checks to see if the passed in object has a representation stored on the device and if it 
    does returns that object.
    
    - parameter object: Object needed to determine if it has a representation on the device.
    
    - returns: Persisted version of the passed in object if it exists.
    */
    private func findCounterpartOnDeviceForObject(object : APIClass) -> APIClass? {
        
        let allObjectsCurrentlyStored = allObjectsOfClass(object.dynamicType)
        
        let counterpartObjects = allObjectsCurrentlyStored.filter {object.predicateForFindingThisObject().evaluateWithObject($0)}
        
        let objectToReturn = counterpartObjects.first as? APIClass
        
        //We should never have more than one representation of an object on the device.
        guard counterpartObjects.count < 2 else {
            assert(false, "passed in object has more than one instance on the device.")
            return objectToReturn
        }
        
        return objectToReturn
    }

    /**
    Deletes the objects if they were persisted on the device.
    
    - parameter objects: objects that need to be deleted.
    
    - returns: true if the objects were successfully deleted, false otherwise.
    */
    public func deleteObjects(objects: [APIClass]) -> [AnyObject]? {
        return dataSource.deleteObjects(objects)
    }
    
    /**
    Returns all of objects from the passed in class that are stored on the device.
    
    - parameter cls: cls whose objects are needed
    
    - returns: All instances of that class that are stored on the device.
    */
    public func allObjectsOfClass(cls: APIClass.Type) -> [AnyObject] {
        
       let allObjectsOfClass = dataSource.allObjectsOfClass(cls)
       guard let allObjectsInClass = allObjectsOfClass else {
            return [AnyObject]()
       }
        
      return allObjectsInClass
    }
}
