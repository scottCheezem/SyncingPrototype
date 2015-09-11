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
    
    /*
        Main initialzer that is used to set the dataSource, networkService and syncableClasses properties.
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
    
    //MARK: Internal Methods
    
    /*
        Event method that handles new objects being received from the server.
    */
    internal func newObjectsReceivedFromServer(objects : [Syncable]) {
        
    }
    
    /*
        Sends all objects to the server that need to be synced.
    */
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachUpdateableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        postAllObjectsToTheServer(notFullySyncedObjectsOfEachClass)
    }
    
    /*
    
    */
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        
    }
    
    //MARK: Client Updating Methods
    
    /*
        Receives all objects that are persisted to the device in each class that the service is listening to.
        TODO: Finish
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
    
    
    /*
        Performs the passed in block on each class that is being synced.
    */
    private func performOperationOnEachUpdateableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in updateableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
    
    /*
        Converts an array of AnyObject to an array of objects that can be used as Syncable.
    */
    private func convertAnyObjectArrayToUpdateableArray(anyObjectArray : [AnyObject]) -> [Updateable] {
        let syncableObjects = anyObjectArray.map { updateableObject in
            return updateableObject as! Updateable
        }
        
        return syncableObjects
    }
    
    /*
        Filters arrays of Syncable objects down to the objects that have not yet been synced to the server.
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
    
    /*
    Performs the passed in block on each class that is being synced.
    */
    private func performOperationOnEachSyncableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in syncableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
}
