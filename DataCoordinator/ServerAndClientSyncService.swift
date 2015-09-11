//
//  ServerAndClientSyncService.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

//MARK: Protocols

/*
    Protocol a class must conform to in order to be the dataSource property
    of a ServerAndClientSyncService.
*/
protocol SyncingDataSource {
    func saveObjects(objects : [AnyObject], completion : (success : Bool) -> Void)
    func allObjectsOfClass(cls : AnyClass) -> [AnyObject]?
}

/*
    Protocol a class must conform to in order to be the network property
    of a ServerAndClientSyncService.
*/
protocol SyncingNetworkService {
    func postObjects(objects : [Syncable])
}

//MARK: Syncing Class

/*
    Class used to sync objects between a client and it's server.
*/
class ServerAndClientSyncService {
    
    
    //MARK: Constant Properties
    
    ///Object used to interact with data that is on the device.
    private let dataSource : SyncingDataSource
    
    ///Object used to interact with data that is going to or from the server.
    private let networkService : SyncingNetworkService
    
    ///Dictionary containing all the classes that can be updated and passed between the client and the server.
    private let syncableClasses : [String : AnyClass]
    
    ///Dictionary containing all the classes that can only be updated on the client and sent to the server, but not created on the server.
    private let updateableClasses : [String : AnyClass]

    //MARK: Initializers
    
    /**
    Main Initiailizer for the ServerAndClientSyncService Class
    
    - parameter dataSource:        Class that the sync service will use to interact with data stored on the device.
    - parameter networkService:    Class that the sync service will use to interact with the data stored on the server.
    - parameter syncableClasses:   Dictionary of classes that can be updated on either the client or the server and that must be synced between the two.
    - parameter updateableClasses: Dictionary of classes that will only be created on the client but will need to be sent to the server.
    
    - returns: Instance of ServerAndClientSyncService.
    */
    init(withDataSource  dataSource : SyncingDataSource, networkService : SyncingNetworkService, syncableClasses : [ String : AnyClass ], andUpdateableClasses  updateableClasses: [String : AnyClass]) {
        self.dataSource = dataSource
        self.networkService = networkService
        self.syncableClasses = syncableClasses
       
        //Ensures that every class that is syncable is also updatable
        var combinedUpdateableArray = [String : AnyClass]()
        for (key, cls) in syncableClasses {
            combinedUpdateableArray[key] = cls
        }
        for (key, cls) in updateableClasses {
            combinedUpdateableArray[key] = cls
        }
        
        self.updateableClasses = combinedUpdateableArray
    }
    
    //MARK: Internal Facing Methods
    
    /**
    Method that should be called when the client has recieved new objects that are syncable.
    
    - parameter objects: New objects from the server that need to be persisted on the client/
    */
    internal func newObjectsReceivedFromServer(objects : [Syncable]) {
        
    }
    
    /**
    Sends all objects that are on the client, but need to be sent to the server.
    
    - parameter completion: Block to performed upon successful completion of the sending the objects.
    */
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachUpdateableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        postAllObjectsToTheServer(notFullySyncedObjectsOfEachClass)
    }
    
    /**
    Method that will pull down any changes that have been made on the server.
    
    - parameter completion: Block indicating when the pulled down changes has  been saved.
    */
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        
    }
    
    //MARK: Client Updating Methods
    
    /**
    Gets all objects persisted to the device that are being tracked for updating.
    
    - returns: Dictionary containing all updateable objects sorted by their classes.
    */
    private func getAllObjectsOfEachUpdateableClass() -> [String : [Updateable]] {
        
        var allObjectsDictionary = [String : [Updateable]]()
        
        performOperationOnEachUpdateableClass { [weak self] cls, classKey in
            let allObjectsInClass = self!.dataSource.allObjectsOfClass(cls)
            
            guard let allSyncableObjectsInClass = allObjectsInClass else {
                allObjectsDictionary[classKey] = [Updateable]()
                return
            }
            
            allObjectsDictionary[classKey] = self!.convertAnyObjectArrayToUpdateableArray(allSyncableObjectsInClass)
        }
        
        return allObjectsDictionary
    }
    
    
    /**
    Performs the passed in block for each class that is being tracked for updates.
    
    - parameter blockToPerform: Block to execute for each class that is being tracked.
    */
    private func performOperationOnEachUpdateableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in updateableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
    
    /**
    Converts an array of AnyObects to an Array of Updateable objects as long as the objects conform to the
    updateable protocol
    
    - parameter anyObjectArray: original Array that needs to be converted
    
    - returns: Objects in the original array, but casted as Updateable.
    */
    private func convertAnyObjectArrayToUpdateableArray(anyObjectArray : [AnyObject]) -> [Updateable] {
        let syncableObjects = anyObjectArray.map { updateableObject in
            return updateableObject as! Updateable
        }
        
        return syncableObjects
    }
    
    /**
    Filters out all objects that are only fully updated on the client.
    
    - parameter dictionary: Dictionary to filter objects that need to be synced.
    
    - returns: Filtered dictionary containing only objects that need to be sent to the server.
    */
    private func filterNotFullySyncedObjectsOutOfDictionary(dictionary : [String : [Updateable]]) -> [String : [Updateable]] {
        
        var notFullySyncedObjectsDictionary = [String : [Updateable]]()
        
        for (classKey, classObjects) in dictionary {
            let classObjectsNotYetSynced = classObjects.filter { !$0.isFullySynced}
            notFullySyncedObjectsDictionary[classKey] = classObjectsNotYetSynced
        }
        
        return notFullySyncedObjectsDictionary
    }
    
    /**
    Posts all of the passed in objects to the server
    
    - parameter allObjects: Objects that need to be sent to the server.
    */
    private func postAllObjectsToTheServer(allObjects : [String : [Updateable]]) {
        performOperationOnEachUpdateableClass { cls, classKey in
            
        }
    }
    
    //MARK: Server Updating Methods
    
    /**
    Performs the passed in block for each class that is being tracked for syncing.
    
    - parameter blockToPerform: Block to execute for each class that is being tracked.
    */
    private func performOperationOnEachSyncableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in syncableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
}
