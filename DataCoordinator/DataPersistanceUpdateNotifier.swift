//
//  DataPersistanceUpdateNotifier.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/21/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

/**
*  Protocol an object must conform to in order to receive updates on objects being saved to the device.
*/
public protocol SyncableTypeUpdateListener {
    /**
    Method that will be called when the objects meeting the listener's criteria have been saved.
    
    - parameter newOrUpdatedObjects: objects that have been saved.
    */
    func objectsListeningToWereUpdatedOrCreated(newOrUpdatedObjects : [Syncable])
    
    /**
    Method that will be called when the objects meeting the listener's criteria have been deleted.
    
    - parameter newOrUpdatedObjects: objects that have been deleted.
    */
    func objectsListeningToWhereDeleted(deletedObjects : [Syncable])
}

/// This class is used to update subscribed listeners when
/// the Type they are subscribed to have an update in data
/// on the device.
public class DataPersistanceUpdateNotifier {
    
    /// Dictionary used to contain all the classes that listeners can
    /// subscribe to.
    private let syncableTypeDictionary : [String : Syncable.Type]
    
    /// Dictionary that contains the array of listeners for each Syncable class in the
    /// syncableTypeDictionary. Will have the same keys as the syncableTypeDictionary
    private var syncableTypeListenerDictionary = [String : [UpdateListenerInformation]]()
    
    public init(syncableTypeDictionary : [String : Syncable.Type]) {
        self.syncableTypeDictionary = syncableTypeDictionary
        
        for (key, _) in self.syncableTypeListenerDictionary {
            let listenersForType = [UpdateListenerInformation]()
            syncableTypeListenerDictionary[key] = listenersForType
        }
    }
    
    //MARK: Adding Listeners
    
    /**
    This method tells the DataPersistanceUpdateNotifier that the passed in listener wants save updates on the passed in Type. Additionally, a predicate can be 
    passed to filter the updates that the listener will receive to those objects meeting the condition of the filter predicate.
    
    - parameter listener:        Listener that is subscribing to updates.
    - parameter syncableType:    Type that the listener needs updates on.
    - parameter filterPredicates: Optional predicate to furthers restrict the objects that will trigger an update for the listener. Multiple predicates will be treated as OR.
    */
    public func addListener(listener : SyncableTypeUpdateListener, forSyncableType syncableType : Syncable.Type, withOptionalFilterPredicates filterPredicates : [NSPredicate]?) {
        
        //TODO: Clean this up.
        let keyOptional = getTypeKeyForSyncableType(syncableType)
        guard let key = keyOptional else { return }
        
        var listenersArray = syncableTypeListenerDictionary[key]
        let listenerInfoToAdd = UpdateListenerInformation(listenerObject: listener, predicates: filterPredicates)
        
        listenersArray!.append(listenerInfoToAdd)
        syncableTypeListenerDictionary[key] = listenersArray
    }
    
    /**
    Method to call when objects are being updated or created at on the device and persisted.
    
    - parameter updatedObjects: Objects that are being created or updated.
    */
    internal func objectsWereCreatedOrUpdated(updatedObjects : [Syncable]) {
        
        let seperatedObjectsDictionary = seperateObjectsIntoTypeDictionaries(updatedObjects)
        
        for (typeKey, objects) in seperatedObjectsDictionary {
            informListenersIfTheirObjectsWereUpdated(objects, withTypeKey: typeKey)
        }
    }
    
    /**
    Method to call when objects are being deleted from the disk.
    
    - parameter deletedObjects: objects that are being deleted.
    */
    internal func objectsWereDeleted(deletedObjects : [Syncable]) {
        let seperatedObjectsDictionary = seperateObjectsIntoTypeDictionaries(deletedObjects)
        for(typeKey, objects) in seperatedObjectsDictionary {
            informListenersIfTheirObjectsWereDeleted(objects, withTypeKey: typeKey)
        }
    }
    
    /**
    Tells each listener if the objects it needs updates on have been saved.
    
    - parameter objects: objects to inform the listeners with
    - parameter typeKey: key used to identify which type is being updated.
    */
    private func informListenersIfTheirObjectsWereUpdated(objects : [Syncable], withTypeKey typeKey : String) {
        
        let allListenersForType = syncableTypeListenerDictionary[typeKey]!
        
        for listenerInfo in allListenersForType {
            let objectsMeetingCriteria = listenerInfo.filteredObjectMeetingPredicates(objects)
            if objectsMeetingCriteria.count > 0 {
                listenerInfo.listenerObject.objectsListeningToWereUpdatedOrCreated(objectsMeetingCriteria)
            }
        }
    }
    
    /**
    Tells each listener if the objects it needs updates on have been saved.
    
    - parameter objects: objects to inform the listeners with
    - parameter typeKey: key used to identify which type is being deleted.
    */
    private func informListenersIfTheirObjectsWereDeleted(deletedObjects : [Syncable], withTypeKey typeKey : String) {
        
        let allListenersForType = syncableTypeListenerDictionary[typeKey]!
        
        for listenerInfo in allListenersForType {
            let objectsMeetingCriteria = listenerInfo.filteredObjectMeetingPredicates(deletedObjects)
            if objectsMeetingCriteria.count > 0 {
                listenerInfo.listenerObject.objectsListeningToWereUpdatedOrCreated(objectsMeetingCriteria)
            }
        }
    }
    
    /**
    Seperates the passed in objects into a dictionary that sorts the objects by their types.
    
    - parameter objects: objects that need to be sorted into their respective types.
    
    - returns: Dictionary that contains all the objects sorted by their types.
    */
    private func seperateObjectsIntoTypeDictionaries(objects : [Syncable]) -> [String : [Syncable]] {
        var seperatedObjects = [String : [Syncable]]()
        
        for object in objects {
            let keyForObjectTypeOptional = getTypeKeyForSyncableType(object.dynamicType)
            guard let keyForObjectType = keyForObjectTypeOptional else { break}
            
            if var arrayForThatClass = seperatedObjects[keyForObjectType] {
                arrayForThatClass.append(object)
                seperatedObjects[keyForObjectType] = arrayForThatClass
            } else {
                var arrayForClass = [Syncable]()
                arrayForClass.append(object)
                seperatedObjects[keyForObjectType] = arrayForClass
            }
        }
        
        return seperatedObjects
    }
    
    /**
    Returns the key for the passed in Type
    
    - parameter syncableType: Type that the  corresponding TypeKey is needed
    
    - returns: TypeKey for the type.
    */
    private func getTypeKeyForSyncableType(syncableType : Syncable.Type) -> String? {
        var keyOptional : String?
        
        for (key, value) in syncableTypeDictionary {
            if value == syncableType {
                keyOptional = key
                break
            }
        }
        
        return keyOptional
    }
}


//TODO: Better way to do or implement this?
/**
*  Private struct used to group the listener and the predicates it needs for filtering together.
*/
internal struct UpdateListenerInformation {
    
    /// Listener object that needs information
    var listenerObject : SyncableTypeUpdateListener
    
    /// predicates that define the objects that the listener needs to listen to.
    var predicates : [NSPredicate]?
    
    /**
    Filters the passed in objects according to the predicates property
    
    - parameter objects: objects that need to be filtered according to the predicates.
    
    - returns: filtered objects meeting the parameters of the predicate.
    */
    internal func filteredObjectMeetingPredicates(objects : [Syncable]) -> [Syncable] {
        guard let predicatesLocal = predicates else  { return objects }
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicatesLocal)
        return objects.filter {object in
            let castedObject = object as! AnyObject
            return compoundPredicate.evaluateWithObject(castedObject)
        }
    }
}