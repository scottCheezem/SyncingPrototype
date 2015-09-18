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
    func saveObjects(objects : [APIClass]) -> Bool
    func deleteObjects(objects : [APIClass]) -> Bool
    func allObjectsOfClass(cls : APIClass.Type) -> [AnyObject]
}

//MARK: SyncingNetworkService Protocol Definition

/*
    Protocol a class must conform to in order to be the network property
    of a ServerAndClientSyncService.
*/
protocol SyncingNetworkService {
    func postObjects(objects : [Updateable], withCompletion completion : (objects : [Updateable]?, error : NSError?) -> Void)
    func getObjectsFromServerOfClass(cls : Updateable.Type , withCompletion completion : (objects : [Syncable]?, error : NSError?) -> Void)
}

//MARK: Syncing Class

/*
    Class used to sync objects between a client and it's server.
*/
class ServerAndClientSyncService {
    
    //MARK: Constant Properties
    
    ///Object used to interact with data that is pulled from and saved to the device.
    private let dataSource : SyncingDataSource
    
    ///Object used to interact with data that is going to or from the server.
    private let networkService : SyncingNetworkService
    
    ///Dictionary containing all the classes that can be synced from the server to the device.
    private let serverUpdateableClasses : [String : Syncable.Type]
    
    ///Dictionary containing all the classes that can be synced from the device to the server.
    private let clientUpdateableClasses : [String : Updateable.Type]

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
    init(withDataSource  dataSource : SyncingDataSource, networkService : SyncingNetworkService, serverUpdateableClasses : [String : Syncable.Type], andClientUpdateableClasses  clientUpdateableClasses: [String : Updateable.Type]) {
        self.dataSource = dataSource
        self.networkService = networkService
        self.serverUpdateableClasses = serverUpdateableClasses
        self.clientUpdateableClasses = clientUpdateableClasses
        setupInitialValuesForAttemptsAtPostingClassDictionary()
    }
    
    //MARK: Internal Facing Methods
    
    /**
    Method that should be called when the client has recieved new objects that are syncable.
    
    - parameter objects: New objects from the server that need to be persisted on the client.
    */
    internal func newObjectsReceivedFromServer(objects : [Syncable]) {
        
        let objectsThatWillBeDeleted = objects.filter {$0.deletedAt != nil}

        let objectsAsAPIClass = objects.map {$0 as APIClass}
        let deletedObjectsAsAPIClass = objectsThatWillBeDeleted.map {$0 as APIClass}
        
        dataSource.deleteObjects(objectsAsAPIClass)
        dataSource.saveObjects(deletedObjectsAsAPIClass)
    }
    
    /**
    Sends all objects that are on the client, but need to be sent to the server.
    
    - parameter completion: Block to performed upon successful completion of the sending the objects.
    */
    internal func sendNotFullySyncedObjectsToServerWithCompletion(completion :() -> Void) {
        let allObjectsDictionary = getAllObjectsOfEachClientUpdateableClass()
        let notFullySyncedObjectsOfEachClass = filterNotFullySyncedObjectsOutOfDictionary(allObjectsDictionary)
        
        postAllObjectsToTheServer(notFullySyncedObjectsOfEachClass, withCompletion: completion)
    }
    
    /**
    Method that will pull down any changes that have been made on the server.
    
    - parameter completion: Block indicating when the pulled down changes has  been saved.
    */
    internal func updateSyncableClassesFromTheServerWithCompletion(completion : () -> Void) {
        
        let totalOfNumberOfCallBacksNeeded = serverUpdateableClasses.count
        var numberOfCallBacksCompleted = 0
        
        for (_, cls) in serverUpdateableClasses {
            networkService.getObjectsFromServerOfClass(cls) { [weak self] objects, error in
                
                numberOfCallBacksCompleted++
                guard let weakself = self else {return}
                if let objects = objects {
                    weakself.newObjectsReceivedFromServer(objects)
                }
                
                let allClassesHaveAttemptedFetch = numberOfCallBacksCompleted >= totalOfNumberOfCallBacksNeeded
                if allClassesHaveAttemptedFetch {
                    completion()
                }
            }
        }
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
            
            allObjectsDictionary[classKey] = allObjectsInClass.map {$0 as! Updateable}
        }
        
        return allObjectsDictionary
    }
    
    /**
    Performs the passed in block for each class that is being tracked for updates.
    
    - parameter blockToPerform: Block to execute for each class that is being tracked.
    */
    private func performOperationOnEachClientUpdateableClass(blockToPerform : (cls : Updateable.Type, classKey : String) -> Void) {
        for (classKey, cls) in clientUpdateableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }

    /**
    Filters out all objects that are only fully updated on the server.
    
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
    private func postAllObjectsToTheServer(allObjects : [String : [Updateable]], withCompletion completion : () -> Void) {
        
        let numberOfClassesToPost = allObjects.count
        
        var postsCompletedOrAbandanoned = 0
        for (_, objectsToPost) in allObjects {

            self.networkService.postObjects(objectsToPost) { [weak self] objects, error in
                guard let weakself = self else { return }
                
                if error != nil {
                    weakself.attemptToPostObjects(objectsToPost, withAttemptNumber: 1) { succeeded in
                        postsCompletedOrAbandanoned++
                        if numberOfClassesToPost == postsCompletedOrAbandanoned {
                            completion()
                        }
                    }
                } else {
                    weakself.processObjectsThatWereSuccessfullyUpdatedOnTheServer(objectsToPost)
                    postsCompletedOrAbandanoned++
                    
                    if postsCompletedOrAbandanoned == numberOfClassesToPost {
                        completion()
                    }
                }
            }
        }
    }
    
    /**
    Attempts to post an array of objects set amount of times before failing
    
    - parameter objects:       Objects that need to be posted to the server
    - parameter attemptNumber: The number of times these objects have been attempted to be pushed to the server.
    - parameter completion:    Block to be performed upon either the successful post or upon the max number of failed attempts.
    */
    private func attemptToPostObjects(objects : [Updateable], withAttemptNumber attemptNumber : Int, andCompletion completion : (succeeded : Bool) -> Void) {
            let maxNumberOfAttempts = 4
        self.networkService.postObjects(objects) { [weak self] (apiObjects, error) -> Void in
            guard error == nil else {
                
                let newAttemptNumber = attemptNumber + 1
                
                if newAttemptNumber >= maxNumberOfAttempts {
                    completion(succeeded: false)
                } else {
                    self?.attemptToPostObjects(objects, withAttemptNumber: newAttemptNumber, andCompletion: completion)
                }
                return
            }
            self?.processObjectsThatWereSuccessfullyUpdatedOnTheServer(objects)
        }
    }
    
    /**
    Uses the passed in ClassKey to reset the attempts that class has at posting to the server.
    
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
            processObjectsThatWereSuccessfullyUpdatedOnTheServer(objects)
        }
    }
    
    /**
    Takes an array of objects and processes them for when they have been successfully updated on the server.
    
    - parameter objects: Objects that need to be processed after
    */
    private func processObjectsThatWereSuccessfullyUpdatedOnTheServer(objects : [Updateable]) {
        
        let firstObjectIsSyncable = objects.first as? Syncable
        
        if firstObjectIsSyncable != nil {
            //TODO: Move this out into a seperate method
            let syncableObjects : [Syncable] = objects.map { object in
                return object as! Syncable
            }
            handleServerUpdateableObjectsThatWereSuccesfullyUpdatedOnServer(syncableObjects)
        } else {
            handleClientUpdateableObjectsThatWereSuccessfullyUpdatedOnServer(objects)
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

        let devicePersistedFullSyncedObjects = syncableObjectsAsFullySynced.map{$0 as APIClass}
        dataSource.saveObjects(devicePersistedFullSyncedObjects)
    }
    
    /**
    Removes the objects that are passed in from the device since they are now on the server.
    
    - parameter updatedObjects: Objects that will be removed/
    */
    private func handleClientUpdateableObjectsThatWereSuccessfullyUpdatedOnServer(updatedObjects : [Updateable]) {
        let devicePersistedObjects = updatedObjects.map{$0 as APIClass}
        self.dataSource.deleteObjects(devicePersistedObjects)
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
    private func performOperationOnEachServerUpdateableClass(blockToPerform : (cls : Syncable.Type, classKey : String) -> Void) {
        for (classKey, cls) in serverUpdateableClasses {
            blockToPerform(cls: cls, classKey: classKey)
        }
    }
}
