//
//  DataPersistanceUpdateNotifierTests.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/21/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Quick
import Nimble
@testable import DataCoordinator

class CarWebSite : SyncableTypeUpdateListener {
    
    var deletedObjects = [Syncable]()
    var updatedOrCreatedObjects = [Syncable]()
    
    func objectsListeningToWereDeleted(newDeletedObjects: [Syncable]) {
        deletedObjects.appendContentsOf(newDeletedObjects)
    }
    func objectsListeningToWereUpdatedOrCreated(newOrUpdatedObjects: [Syncable]) {
        updatedOrCreatedObjects.appendContentsOf(newOrUpdatedObjects)
    }
}

class DataPersistanceUpdateNotifierTests : QuickSpec {
    
    override func spec() {
        describe("Updating on deletes and adds") {
            
            context("Getting updates on objects with one predicate") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                beforeSuite {
                    
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    let onlyUsedCars : (Syncable) -> Bool = { (syncableObject : Syncable) in
                        if let car = syncableObject as? Car {
                          return car.isUsed
                        } else {
                            return false
                        }
                    }
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks: [onlyUsedCars])
                }
                
                it("Should return the correct number of values when adding") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(1))
                }
                
                it("Should return the correct number of values when deleting") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(1))
                }
            }
            
            context("Getting updates on objects with no predicate") {
                
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks: nil)
                }
                
                it("Should return the correct number of values when adding") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(3))
                }
                
                it("Should return the correct number of values when deleting") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(3))
                }
            }
            
            context("Getting updates on objects with multiple filters") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    let post2007Cars : (Syncable) -> Bool = { (syncableObject : Syncable) in
                        if let car = syncableObject as? Car {
                            return car.year > 2007
                        } else {
                            return false
                        }
                    }
                    
                    let pre2007Cars : (Syncable) -> Bool = { (syncableObject : Syncable) in
                        if let car = syncableObject as? Car {
                            return car.year < 2007
                        } else {
                            return false
                        }
                    }
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks: [post2007Cars, pre2007Cars])
                }
                
                it("Should return the correct number of values when adding") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(3))
                }
                
                it("Should return the correct number of values when deleting") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(3))
                }
            }
            
            context("Multiple subscribers listening for same objects") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                var carWebsite2 : CarWebSite!
                
                let numPre2007Cars = 2
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    carWebsite2 = CarWebSite()

                    let pre2007Cars : (Syncable) -> Bool = { (syncableObject : Syncable) in
                        if let car = syncableObject as? Car {
                            return car.year < 2007
                        } else {
                            return false
                        }
                    }
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks: [pre2007Cars])
                    notifier.addListener(carWebsite2, forSyncableType: Car.self, withOptionalFilterBlocks: [pre2007Cars])
                }
                
                it("Should return the correct number of values when adding") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(numPre2007Cars))
                    expect(carWebsite2.updatedOrCreatedObjects.count).to(equal(numPre2007Cars))
                }
                
                it("Should return the correct number of values when deleting") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(numPre2007Cars))
                    expect(carWebsite2.deletedObjects.count).to(equal(numPre2007Cars))
                }
            }
            
            context("Subscriber attempting to listen to class that is not allowed") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    notifier.addListener(carWebsite, forSyncableType: RaceTrack.self, withOptionalFilterBlocks: nil)
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(0))
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(0))
                }
            }
            
            context("Subscriber listening to updates on multiple objects") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks: nil)
                    notifier.addListener(carWebsite, forSyncableType: Mechanic.self, withOptionalFilterBlocks: nil)
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    notifier.objectsWereCreatedOrUpdated(self.defaultMechanicsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(7))
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    notifier.objectsWereDeleted(self.defaultMechanicsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(7))
                }
            }
            
            context("Objects getting updated that are not subsrscribed to") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    
                    notifier.addListener(carWebsite, forSyncableType: Mechanic.self, withOptionalFilterBlocks: nil)
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(0))
                }
                
                it("Should not crash and return zero values") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(0))
                }
            }
            
            context("Multiple Class types being modified in one update") {
                var notifier : DataPersistanceUpdateNotifier!
                var carWebsite : CarWebSite!
                var carWebsite2 : CarWebSite!
                
                beforeSuite {
                    let dictionariesToTrack : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]
                    
                    notifier = DataPersistanceUpdateNotifier.init(syncableTypeDictionary: dictionariesToTrack)
                    carWebsite = CarWebSite()
                    carWebsite2 = CarWebSite()
                    
                    notifier.addListener(carWebsite, forSyncableType: Car.self, withOptionalFilterBlocks:nil)
                    notifier.addListener(carWebsite2, forSyncableType: Mechanic.self, withOptionalFilterBlocks: nil)
                }
                
                it("Should return the correct number of values when adding") {
                    notifier.objectsWereCreatedOrUpdated(self.defaultCarsAsSyncable + self.defaultMechanicsAsSyncable)
                    expect(carWebsite.updatedOrCreatedObjects.count).to(equal(3))
                    expect(carWebsite2.updatedOrCreatedObjects.count).to(equal(4))
                }
                
                it("Should return the correct number of values when deleting") {
                    notifier.objectsWereDeleted(self.defaultCarsAsSyncable + self.defaultMechanicsAsSyncable)
                    expect(carWebsite.deletedObjects.count).to(equal(3))
                    expect(carWebsite2.deletedObjects.count).to(equal(4))
                }
            }
            
            
        }
    }
    
    var defaultCarsAsSyncable : [Syncable] {
        return defaultCars.map {$0 as Syncable}
    }
    
    var defaultCars : [Car] {
        let car1 = Car()
        car1.year = 2015
        car1.make = "Ford"
        car1.isUsed = false
        
        let car2 = Car()
        car2.isUsed = true
        car2.year = 2001
        car2.make = "Toyota"
        
        let car3 = Car()
        car3.year = 2006
        car3.make = "Honda"
        car3.isUsed = false
        
        return [car1, car2, car3]
    }
    
    var defaultMechanicsAsSyncable : [Syncable] {
        return defaultMechanics.map {$0 as Syncable}
    }
    
    var defaultMechanics : [Mechanic] {
        let mechanic1 = Mechanic()
        let mechanic2 = Mechanic()
        let mechanic3 = Mechanic()
        let mechanic4 = Mechanic()
        
        mechanic1.isShady = true
        mechanic2.isShady = true
        mechanic3.isShady = true
        mechanic4.isShady = false
        
        mechanic1.laborRate = 45.0
        mechanic2.laborRate = 33.0
        mechanic3.laborRate = 56.00
        mechanic4.laborRate = 52.00
        
        mechanic1.title = "The Body Shop"
        mechanic2.title = "Dealership"
        mechanic3.title = "Mechanic 3"
        mechanic4.title = "Larry's Auto Shop"
        
        return [mechanic1, mechanic2, mechanic3, mechanic4]
    }
}

class RaceTrack : SyncableTestClass {
    
}