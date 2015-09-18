//
//  ServerAndClientSyncServiceTests.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/15/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import Nimble
import Quick

@testable import DataCoordinator

class UpdateableTestClass: Updateable {
    
    static var primaryKeyTitle = "doesntMatter"
    
    func populateWithJson(jsonDict: NSDictionary) {
        
    }
    
    func jsonRepresentation() -> NSDictionary {
        return NSDictionary()
    }
    
    static var apiEndPointForClass = ""
    
    var primaryKeyValue = ""
    var clientCreatedAt = NSDate()
    var updatedOnClientAndServer = false
}

class SyncableTestClass : UpdateableTestClass, Syncable {
    var serverUpdatedAt = NSDate()
    var clientUpdatedAt = NSDate()
    var serverCreatedAt = NSDate()
    var deletedAt : NSDate? = NSDate()
}

class Car : SyncableTestClass {
    
}

class Driver : UpdateableTestClass {
    
}

class Mechanic: SyncableTestClass {
    
}

class GasStation : UpdateableTestClass {
    
}

class TestNetworkService: SyncingNetworkService {
    
    let errorOutOnAllCalls : Bool
    var attemptsAtPostingObject = 0
    var objectsThatHaveBeenPosted = [Updateable]()
    
    var objectsThatHaveBeenFetched = [Syncable]()
    
    var carsToBeFetched = [Car]()
    var mechanicsToBeFetched = [Mechanic]()
    
    init(errorOutOnAllCalls : Bool) {
        self.errorOutOnAllCalls = errorOutOnAllCalls
    }
    
    internal func postObjects(objects: [Updateable], withCompletion completion: (objects: [Updateable]?, error: NSError?) -> Void) {
        
        attemptsAtPostingObject++
        guard !errorOutOnAllCalls else {
            let error = NSError(domain: "Test", code: 123, userInfo: nil)
            completion(objects: nil, error: error)
            return
        }
        
        objectsThatHaveBeenPosted.appendContentsOf(objects)
        
        completion(objects: objects, error: nil)
    }
    
    internal func getObjectsFromServerOfClass(cls: Updateable.Type, withCompletion completion: (objects: [Syncable]?, error: NSError?) -> Void) {
        guard !errorOutOnAllCalls else {
            
            let error = NSError(domain: "Testing", code: 001, userInfo: nil)
            
            completion(objects: nil, error: error)
            return
        }
        
        
        var objectsToReturn = [Syncable]()
        
        switch cls {
        case is Car.Type :
            objectsToReturn = carsToBeFetched.map{$0 as Syncable}
        case is Mechanic.Type :
            objectsToReturn = mechanicsToBeFetched.map{$0 as Syncable}
        default :
            print("Class passed to fetch that cannnot be")
        }
        
        objectsThatHaveBeenFetched.appendContentsOf(objectsToReturn)
        completion(objects: objectsToReturn, error: nil)
    }
}

class TestDataSource: SyncingDataSource {
    
    //Testing Methods
    internal var savedObjects = [APIClass]()
    internal var deletedObjects = [APIClass]()
    
    private let cars : [Car]
    private let drivers : [Driver]
    private let mechanics : [Mechanic]
    private let gasStations : [GasStation]
    
    init(cars : [Car], drivers : [Driver], mechanics : [Mechanic], gasStations : [GasStation]) {

        self.cars = cars
        self.drivers = drivers
        self.mechanics = mechanics
        self.gasStations = gasStations
    }
    
    //SyncingDataSource Protocol
    internal func saveObjects(objects: [APIClass]) -> Bool {
        savedObjects.appendContentsOf(objects)
        return true
    }
    
    internal func deleteObjects(objects: [APIClass]) -> Bool {
        deletedObjects.appendContentsOf(objects)
        return true
    }
    
    internal func allObjectsOfClass(cls: APIClass.Type) -> [AnyObject] {
        switch cls {
            
        case is Car.Type :
            return cars
        case is Driver.Type :
            return drivers
        case is Mechanic.Type :
            return mechanics
        case is GasStation.Type :
            return gasStations
        default :
            return [String]()
        }
    }
}

class ServerAndClientSyncTests : QuickSpec {
    
    
    override func spec() {
        
        let clientUpdatableClasses : [String : Updateable.Type] = ["Car" : Car.self,"Driver" : Driver.self, "GasStation" : GasStation.self]
        let serverUpdateableClasses : [String : Syncable.Type] = ["Car" : Car.self, "Mechanic" : Mechanic.self]

        describe("Sending objects to the server") {

            context("All classes cannot post to server") {
                
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: true)
                let testDataSource = TestDataSource(cars: self.defaultCars, drivers: self.defaultDrivers, mechanics: self.defaultMechanics, gasStations: self.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                 beforeSuite {
                    waitUntil(timeout : 10) { done in
                        syncServiceToTest.sendNotFullySyncedObjectsToServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should not have posted any objects to the server") {
                    expect(testNetworkingService.objectsThatHaveBeenPosted).to(beEmpty())
                }
                it("Should have made the correct number of attempts at posting to the server") {
                    let correctNumberOfAttempts = clientUpdatableClasses.count * 4
                    expect(testNetworkingService.attemptsAtPostingObject).to(equal(correctNumberOfAttempts))
                }
                it("Should not have told the datasource to delete any objects") {
                    expect(testDataSource.deletedObjects).to(beEmpty())
                }
            }
            
            context("All classes post to the server correctly with assortment of data") {
                
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: false)
                let testDataSource = TestDataSource(cars: self.defaultCars, drivers: self.defaultDrivers, mechanics: self.defaultMechanics, gasStations: self.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                beforeSuite {
                    waitUntil(timeout : 10) { done in
                        syncServiceToTest.sendNotFullySyncedObjectsToServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should post each time for the number of client updateable classes") {
                    expect(testNetworkingService.attemptsAtPostingObject).to(equal(clientUpdatableClasses.count))
                }
                
                it("Should post the correct number of objects to the server") {
                    expect(testNetworkingService.objectsThatHaveBeenPosted.count).to(equal(3))
                }
                
                it("Should tell the datasource the correct number of objects to delete") {
                    expect(testDataSource.deletedObjects.count).to(equal(2))
                }
            }
            
            context("Having no records to query") {
                
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: false)
                let testDataSource = TestDataSource(cars: [Car](), drivers: [Driver](), mechanics: [Mechanic](), gasStations:[GasStation]())
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                beforeSuite {
                    waitUntil(timeout : 10) { done in
                        syncServiceToTest.sendNotFullySyncedObjectsToServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should not have posted any objects to the server") {
                    expect(testNetworkingService.objectsThatHaveBeenPosted.count).to(equal(0))
                }
                
                it("Should not have told it's datasource to delete any objects") {
                    expect(testDataSource.deletedObjects.count).to(equal(0))
                }
            }
        }
        
        describe("Retrieving new data from the server") {
            
            context("The server returns an assortment of data") { [weak self] in
                guard let weakself = self else {return}
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: false)
                let testDataSource = TestDataSource(cars: weakself.defaultCars, drivers: weakself.defaultDrivers, mechanics: weakself.defaultMechanics, gasStations: weakself.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                let cars = weakself.fetchedCars
                let mechanics = weakself.fetchedMechanics 
                
                testNetworkingService.carsToBeFetched = cars
                testNetworkingService.mechanicsToBeFetched = mechanics

                beforeSuite {
                    waitUntil(timeout: 10) { done in
                        syncServiceToTest.updateSyncableClassesFromTheServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should fetch the right number of objects from the server") {
                    expect(testNetworkingService.objectsThatHaveBeenFetched.count).to(equal(4))
                }
                
                it("should have saved the correct number of objects") {
                    expect(testDataSource.savedObjects.count).to(equal(4))
                }
            }

            context("Cannot successfully pull any data from the server") { [weak self] in
                guard let weakself = self else {return}
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: true)
                let testDataSource = TestDataSource(cars: weakself.defaultCars, drivers: weakself.defaultDrivers, mechanics: weakself.defaultMechanics, gasStations: weakself.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                beforeSuite {
                    waitUntil(timeout: 10) { done in
                        syncServiceToTest.updateSyncableClassesFromTheServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should not have received any objects") {
                    expect(testNetworkingService.objectsThatHaveBeenFetched.count).to(equal(0))
                }
                
                it("Should have not saved any objects") {
                    expect(testDataSource.savedObjects.count).to(equal(0))
                }
            }
            
            context("The Server has no new objects") { [weak self] in
                guard let weakself = self else {return}
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: false)
                let testDataSource = TestDataSource(cars: weakself.defaultCars, drivers: weakself.defaultDrivers, mechanics: weakself.defaultMechanics, gasStations: weakself.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                beforeSuite {
                    waitUntil(timeout: 10) { done in
                        syncServiceToTest.updateSyncableClassesFromTheServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should not have received any objects") {
                    expect(testNetworkingService.objectsThatHaveBeenFetched.count).to(equal(0))
                }
                
                it("Should have not saved any objects") {
                    expect(testDataSource.savedObjects.count).to(equal(0))
                }
            }
        }
    }
    
    var fetchedCars : [Car] {
        get {
            let car1 = Car()
            let car2 = Car()
            let car3 = Car()
            
            return [car1, car2, car3]
        }
    }
    var fetchedMechanics : [Mechanic] {
        get {
            let mechanic1 = Mechanic()
            return [mechanic1]
        }
    }
    
    var defaultCars : [Car] {
        get {
            let car1 = Car()
            let car2 = Car()
            let car3 = Car()
            
            car1.updatedOnClientAndServer = false
            car2.updatedOnClientAndServer = true
            car3.updatedOnClientAndServer = true
            
            let cars = [car1, car2, car3]
            
            return cars
        }
    }
    
    var defaultMechanics : [Mechanic] {
        get {
            let mechanic1 = Mechanic()
            let mechanic2 = Mechanic()
            
            mechanic1.updatedOnClientAndServer = true
            mechanic2.updatedOnClientAndServer = true
            
            let mechanics = [mechanic1, mechanic2]
            
            return mechanics
        }
    }
    
    var defaultDrivers : [Driver] {
        get {
            let driver1 = Driver()
            let driver2 = Driver()
            let driver3 = Driver()
            
            driver1.updatedOnClientAndServer = false
            driver2.updatedOnClientAndServer = true
            driver3.updatedOnClientAndServer = false
            
            let drivers = [driver1, driver2, driver3]
            
            return drivers
        }
    }
    
    var defaultGasStations : [GasStation] {
        get {
            //Used to test an empty array
            let gasStations = [GasStation]()
            
            return gasStations
        }
    }
}

