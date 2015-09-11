//
//  ServerAndClientSyncService.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

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

/*
    Class used to sync objects between a client and it's server.
*/
class ServerAndClientSyncService {
    
    ///Object used to interact with data that is on the device.
    private let dataSource : SyncingDataSource
    
    ///Object used to interact with data that is going to or from the server.
    private let networkService : SyncingNetworkService
    
    ///Dictionary containing all the classes that the sync service should sync.
    private let syncableClasses : [ String : AnyClass ]
    
    /*
        Main initialzer that is used to set the dataSource, networkService and syncableClasses properties.
    */
    init(withDataSource  dataSource : SyncingDataSource, networkService : SyncingNetworkService, andSyncableClasses syncableClasses : [ String : AnyClass ]) {
        self.dataSource = dataSource
        self.networkService = networkService
        self.syncableClasses = syncableClasses
    }
    
    /*
        Event method that handles new objects being recieved from the server.
    */
    internal func newObjectsReceivedFromServer(objects : [Syncable]) {
        
    }
    
    /*
        Sends all objects to the server that need to be synced.
    */
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachSyncableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        let objectsToSendToServerAsJSONDictionaries = convertObjectsInDictionaryArraysToJSONDictionaries(notFullySyncedObjectsOfEachClass)
        postAllObjectsToTheServer(objectsToSendToServerAsJSONDictionaries)
    }
    
    /*
    
    */
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        
    }
    
    /*
        Receives all objects that are persisted to the device in each class that the service is listening to.
        TODO: Finish
    */
    private func getAllObjectsOfEachSyncableClass() -> [String : [Syncable]] {
        
        var allObjectsDictionary = [String : [Syncable]]()
        
        performOperationOnEachSyncableClass { [weak self] cls, classKey in
            let allObjectsInClass = self!.dataSource.allObjectsOfClass(cls)
            
            guard let allSyncableObjectsInClass = allObjectsInClass else {
                allObjectsDictionary[classKey] = [Syncable]()
                return
            }
            
            allObjectsDictionary[classKey] = self!.convertAnyObjectArrayToSyncableArray(allSyncableObjectsInClass)
        }
        
        return allObjectsDictionary
    }
    
    /*
        Converts an array of AnyObject to an array of objects that can be used as Syncable.
    */
    private func convertAnyObjectArrayToSyncableArray(anyObjectArray : [AnyObject]) -> [Syncable] {
        let syncableObjects = anyObjectArray.map { syncableObject in
            return syncableObject as! Syncable
        }
        
        return syncableObjects
    }
    
    /*
        Filters arrays of Syncable objects down to the objects that have not yet been synced to the server.
    */
    private func filterNotFullySyncedObjectsOutOfDictionary(dictionary : [String : [Syncable]]) -> [String : [Syncable]] {
        
        var notFullySyncedObjectsDictionary = [String : [Syncable]]()
        
        for (classKey, classObjects) in dictionary {
            let classObjectsNotYetSynced = classObjects.filter { !$0.isFullySynced}
            notFullySyncedObjectsDictionary[classKey] = classObjectsNotYetSynced
        }
        
        return notFullySyncedObjectsDictionary
    }
    
    /*
        Converts an Array of Syncable objects to jsonDictionaries that can be sent to the server.
    */
    private func convertObjectsInDictionaryArraysToJSONDictionaries(dictionary : [String : [Syncable]]) -> [String : [[String : AnyObject]]] {
        return [String : [[String : AnyObject]]]()
    }
}
