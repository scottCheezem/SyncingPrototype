//
//  ServerAndClientSyncService.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

protocol SyncingDataSource {
    func saveObjects(objects : [AnyObject], completion : (success : Bool) -> Void)
    func allObjectsOfClass(cls : AnyClass) -> [AnyObject]?
}

protocol SyncingNetworkService {
    func postObjects(objects : [Syncable])
}

class ServerAndClientSyncService {
    
    private let dataSource : SyncingDataSource
    private let networkService : SyncingNetworkService
    private let syncableClasses : [ String : AnyClass ]
    
    init(withDataSource  dataSource : SyncingDataSource, networkService : SyncingNetworkService, andSyncableClasses syncableClasses : [ String : AnyClass ]) {
        self.dataSource = dataSource
        self.networkService = networkService
        self.syncableClasses = syncableClasses
    }
    
    internal func newObjectsReceivedFromServer(objects : [Syncable]) {
        
    }
    
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachSyncableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        let objectsToSendToServerAsJSONDictionaries = convertObjectsInDictionaryArraysToJSONDictionaries(notFullySyncedObjectsOfEachClass)
    }
    
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        
    }
    
    private func getAllObjectsOfEachSyncableClass() -> [String : [Syncable]] {
        return [String : [Syncable]]()
    }
    
    private func filterNotFullySyncedObjectsOutOfDictionary(dictionary : [String : [Syncable]]) -> [String : [Syncable]] {
        return [String : [Syncable]]()
    }
    
    private func convertObjectsInDictionaryArraysToJSONDictionaries(dictionary : [String : [Syncable]]) -> [String : [[String : AnyObject]]] {
        return [String : [[String : AnyObject]]]
    }
}
