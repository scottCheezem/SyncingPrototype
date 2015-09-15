//
//  ServerAndClientSyncService.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

//MARK: SyncingDataSource Protocol Definition

/*
    Protocol a class must conform to in order to be the dataSource property
    of a ServerAndClientSyncService.
*/
protocol SyncingDataSource {
    func saveObjects(objects : [Updateable]) -> Bool
    func deleteObjects(objects : [Updateable]) -> Bool
    func allObjectsOfClass(cls : AnyClass) -> [AnyObject]?
}

//MARK: SyncingNetworkService Protocol Definition

/*
    Protocol a class must conform to in order to be the network property
    of a ServerAndClientSyncService.
*/
protocol SyncingNetworkService {
    func postObjects(objects : [Updateable], withCompletion completion : (objects : [Updateable]?, error : NSError?) -> Void)
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
    
    ///Dictionary containing all the classes that can be synced from the server to the device.
    private let serverUpdateableClasses : [String : AnyClass]
    
    ///Dictionary containing all the classes that can be synced from the device to the server.
    private let clientUpdateableClasses : [String : AnyClass]
    
    /// Boolean used to indicate if the syncing service is in the process of posting objects to the server.
    private var networkServiceIsPostingObjectsToServer = false
    
    //Number of attempts a class is allowed to fail at sending its objects that arent fully synced to the server.
    private let allowedAttemptsAtPostingToServer = 4
    
    ///Dictionary that uses the same keys as clientUpdateableClasses to count the number of failed attempts of each class at sending its
    ///objects that are not yet synced with the server.
    private var attemptsAtPostingClassDictionary : [String : Int] = [String : Int]()
    
    //MARK: Initializers
    
    /**
    Main Initiailizer for the ServerAndClientSyncService Class
    
    - parameter dataSource:        Class that the sync service will use to interact with data stored on the device.
    - parameter networkService:    Class that the sync service will use to interact with the data stored on the server.
    - parameter syncableClasses:   Dictionary of classes that can be updated on either the client or the server and that must be synced between the two.
    - parameter updateableClasses: Dictionary of classes that will only be created on the client but will need to be sent to the server.
    
    - returns: Instance of ServerAndClientSyncService.
    */
    init(withDataSource  dataSource : SyncingDataSource, networkService : SyncingNetworkService, serverUpdateableClasses : [String : AnyClass], andClientUpdateableClasses  clientUpdateableClasses: [String : AnyClass]) {
        self.dataSource = dataSource
        self.networkService = networkService
        self.serverUpdateableClasses = serverUpdateableClasses
        self.clientUpdateableClasses = clientUpdateableClasses
        setupInitialValuesForAttemptsAtPostingClassDictionary()
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
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion :() -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachClientUpdateableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        
        networkServiceIsPostingObjectsToServer = true
        postAllObjectsToTheServer(notFullySyncedObjectsOfEachClass) { [weak self] in
            guard let weakself = self else { return }
            weakself.networkServiceIsPostingObjectsToServer = false
            completion()
        }
    }
    
    /**
    Method that will pull down any changes that have been made on the server.
    
    - parameter completion: Block indicating when the pulled down changes has  been saved.
    */
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : (succeeded : Bool) -> Void) {
        
        for (_, cls) in serverUpdateableClasses {
            fetchObjectsOfClassFromTheServer(cls) { objects, error in
                
            }
        }
    }
    
    internal func fetchObjectsOfClassFromTheServer(cls : AnyClass, withCompletion completion : (objects : [Syncable]?, error : NSError?) -> Void) {
        
    }
    
    //MARK: Client Updating Server Methods
    
    /**
    Gets all objects persisted to the device that are being tracked for updating.
    
    - returns: Dictionary containing all updateable objects sorted by their classes.
    */
    private func getAllObjectsOfEachClientUpdateableClass() -> [String : [Updateable]] {
        
        var allObjectsDictionary = [String : [Updateable]]()
        
        performOperationOnEachClientUpdateableClass { [weak self] cls, classKey in
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
    private func performOperationOnEachClientUpdateableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in clientUpdateableClasses {
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
    Converts an array of Syncable objects to an Array of Updateable objects as long as the objects conform to the
    updateable protocol
    
    - parameter syncableArray: original Array that needs to be converted
    
    - returns: Objects in the original array, but casted as Updateable.
    */
    private func convertSyncableArrayToUpdateableArray(syncableArray : [Syncable]) -> [Updateable] {
        let updateableArray = syncableArray.map { syncableObject in
            return syncableObject as Updateable
        }
        
        return updateableArray
    }
    
    /**
    Filters out all objects that are only fully updated on the client.
    
    - parameter dictionary: Dictionary to filter objects that need to be synced.
    
    - returns: Filtered dictionary containing only objects that need to be sent to the server.
    */
    private func filterNotFullySyncedObjectsOutOfDictionary(dictionary : [String : [Updateable]]) -> [String : [Updateable]] {
        
        var notFullySyncedObjectsDictionary = [String : [Updateable]]()
        
        for (classKey, classObjects) in dictionary {
            let classObjectsNotYetSynced = classObjects.filter { !$0.updatedOnClientAndServer}
            notFullySyncedObjectsDictionary[classKey] = classObjectsNotYetSynced
        }
        
        return notFullySyncedObjectsDictionary
    }
    
    /**
    Posts all of the passed in objects to the server
    
    - parameter allObjects: Objects that need to be sent to the server.
    */
    private func postAllObjectsToTheServer(allObjects : [String : [Updateable]], withCompletion completion : (() -> Void)?) {
        
        var numberOfClassesToPost = clientUpdateableClasses.count
        
        var classesThatProducedErrors = [String : [Updateable]]()
        var classesThatUpdatedSuccessfully = [String : [Updateable]]()
        
        var numberOfNetworkCallsCompleted = 0
        
        for (clsKey, objectsToPost) in allObjects {
            
            //If we have reached the maximum attempts, dont allow this class to try and post again.
            guard attemptsAtPostingClassDictionary[clsKey] < allowedAttemptsAtPostingToServer else {
                resetAttemptsAtPostingToServerForClassKey(clsKey)
                numberOfClassesToPost--
                return
            }
            
            networkServiceIsPostingObjectsToServer = true
            
            self.networkService.postObjects(objectsToPost) { [weak self] objects, error in
                guard let weakself = self else {return}
                numberOfNetworkCallsCompleted++
                
                if error != nil {
                    
                    classesThatProducedErrors[clsKey] = objectsToPost
                    let previousNumberOfFailedAttempts = weakself.attemptsAtPostingClassDictionary[clsKey]!
                    weakself.attemptsAtPostingClassDictionary[clsKey] = previousNumberOfFailedAttempts + 1
                    
                } else {
                    classesThatUpdatedSuccessfully[clsKey] = objectsToPost
                    weakself.resetAttemptsAtPostingToServerForClassKey(clsKey)
                }
                
                if numberOfNetworkCallsCompleted >= numberOfClassesToPost {
                    
                    weakself.processDictionaryWithSuccessfullyUpdatedClasses(classesThatUpdatedSuccessfully)
                    weakself.processDictionariesThatProducedErrors(classesThatProducedErrors) {
                        
                        if let completion = completion {
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    /**
    Uses the passed in ClassKey to reset the attempts that class at posting to the server.
    
    - parameter clsKey: Key that is used to identifiy which class needs to be reset.
    */
    private func resetAttemptsAtPostingToServerForClassKey(clsKey : String) {
        attemptsAtPostingClassDictionary[clsKey] = 0
    }
    
    /**
    Process the objects for each key in the dictionary for when they have been successfully sent from the client
    to the server
    
    - parameter successfullClasses: A Dictionary containing the class key from the updateable class dictionary and 
      an array of the objects that were successfully updated.
    */
    private func processDictionaryWithSuccessfullyUpdatedClasses(successfullClasses : [String : [Updateable]]) {
        for (_, objects) in successfullClasses {
            if let syncableObjects = objects as? [Syncable] {
                handleServerUpdateableObjectsThatWereSuccesfullyUpdatedOnServer(syncableObjects)
            } else {
                handleClientUpdateableObjectsThatWereSuccessfullyUpdatedOnServer(objects)
            }
        }
    }
    
    /**
    Marks the passed in objects as fully synced then saves them to the device.
    
    - parameter syncableObjects: Objects that need to be marked as fully synced and then saved.
    */
    private func handleServerUpdateableObjectsThatWereSuccesfullyUpdatedOnServer(syncableObjects : [Syncable]) {
        
        var syncableObjectsAsFullySynced = [Syncable]()
        for syncableObject in syncableObjects {
            var mutSyncableObject = syncableObject
            mutSyncableObject.updatedOnClientAndServer = true
            syncableObjectsAsFullySynced.append(mutSyncableObject)
        }
        
        let updateableFullySyncedObjects = convertSyncableArrayToUpdateableArray(syncableObjectsAsFullySynced)
        dataSource.saveObjects(updateableFullySyncedObjects)
    }
    
    /**
    Removes the objects that are passed in from the device since they are now on the server.
    
    - parameter updatedObjects: Objects that will be removed/
    */
    private func handleClientUpdateableObjectsThatWereSuccessfullyUpdatedOnServer(updatedObjects : [Updateable]) {
        
        self.dataSource.deleteObjects(updatedObjects)
    }
    
    private func processDictionariesThatProducedErrors(failedClasses : [String : [Updateable]], withCompletion  completion : () -> Void) {
        guard !failedClasses.isEmpty else {
            completion()
            return
        }
        
        postAllObjectsToTheServer(failedClasses, withCompletion: nil)
    }
    
    /**
    Setups a dictionary that will be used to track how many times in a row each class has failed
    at updating its objects that need to be sent to the server.
    */
    private func setupInitialValuesForAttemptsAtPostingClassDictionary() {
        for (clsKey, _) in clientUpdateableClasses {
            attemptsAtPostingClassDictionary[clsKey] = 0
        }
    }
    
    //MARK: Server Updating Client Methods
    
    /**
    Performs the passed in block for each class that is being tracked for syncing.
    
    - parameter blockToPerform: Block to execute for each class that is being tracked.
    */
    private func performOperationOnEachServerUpdateableClass(blockToPerform : (cls : AnyClass, classKey : String) -> Void) {
        for (classKey, cls) in serverUpdateableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
    
    private func handleNewObjectsReceivedFromServer(objects : Syncable, forClass cls : AnyClass) {
      
    }
}
