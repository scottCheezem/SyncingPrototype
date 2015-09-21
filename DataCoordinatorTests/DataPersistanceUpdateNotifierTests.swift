//
//  DataPersistanceUpdateNotifierTests.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/21/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Quick
import Nimble
import DataCoordinator

class JustWorkOnce : SyncableTypeUpdateListener {
    func objectsListeningToWhereDeleted(deletedObjects: [Syncable]) {
        
    }
    func objectsListeningToWereUpdatedOrCreated(newOrUpdatedObjects: [Syncable]) {
        
    }
}
class DataPersistanceUpdateNotifierTests : QuickSpec {
    
    override func spec() {
        describe("Updating on deletes and adds") {
            beforeEach  {
                
            }
        }
    }
}