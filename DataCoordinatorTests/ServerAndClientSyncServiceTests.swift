//
//  ServerAndClientSyncServiceTests.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/15/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import DataCoordinator

class UpdateableTestClass: Updateable {
    var clientCreatedAt = NSDate()
    var updatedOnClientAndServer = false
}

class SyncableTestClass : UpdateableTestClass, Syncable {
    var serverUpdatedAt = NSDate()
    var clientUpdatedAt = NSDate()
    var serverCreatedAt = NSDate()
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
    
    init(errorOutOnAllCalls : Bool) {
        self.errorOutOnAllCalls = errorOutOnAllCalls
    }
    
    internal func postObjects(objects: [Updateable], withCompletion completion: (objects: [Updateable]?, error: NSError?) -> Void) {
        guard errorOutOnAllCalls == false else {
            let error = NSError(domain: "Test", code: 123, userInfo: nil)
            completion(objects: nil, error: error)
            return
        }
        
        objectsThatHaveBeenPosted.appendContentsOf(objects)
    
        completion(objects: objects, error: nil)
    }
}

class TestDataSource: SyncingDataSource {
    
    //Testing Methods
    internal var savedObjects = [Updateable]()
    internal var deletedObjects = [Updateable]()
    
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
    internal func saveObjects(objects: [Updateable]) -> Bool {
        savedObjects.appendContentsOf(objects)
        return true
    }
    
    internal func deleteObjects(objects: [Updateable]) -> Bool {
        deletedObjects.appendContentsOf(objects)
        return true
    }
    
    internal func allObjectsOfClass(cls: AnyClass) -> [AnyObject]? {
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
        

        describe("Sending objects to the server") {
            
            let clientUpdatableClasses : [String : AnyClass] = ["Car" : Car.self,"Driver" : Driver.self, "GasStation" : GasStation.self]
            let serverUpdateableClasses : [String : AnyClass] = ["Car" : Car.self, "Driver" : Driver.self, "GasStation" : GasStation.self]

            context("All classes cannot post to server") {
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: true)
                let testDataSource = TestDataSource(cars: self.defaultCars, drivers: self.defaultDrivers, mechanics: self.defaultMechanics, gasStations: self.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                 beforeSuite {
                    waitUntil(timeout : 1) { done in
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
            
            context("All classes post to the server correctly") {
                let testNetworkingService = TestNetworkService(errorOutOnAllCalls: false)
                                let testDataSource = TestDataSource(cars: self.defaultCars, drivers: self.defaultDrivers, mechanics: self.defaultMechanics, gasStations: self.defaultGasStations)
                let syncServiceToTest = ServerAndClientSyncService(withDataSource: testDataSource, networkService: testNetworkingService, serverUpdateableClasses: serverUpdateableClasses, andClientUpdateableClasses: clientUpdatableClasses)
                
                beforeSuite {
                    waitUntil(timeout : 1) { done in
                        syncServiceToTest.sendNotFullySyncedObjectsToServerWithCompletion {
                            done()
                        }
                    }
                }
                
                it("Should post each time for the number of client updateable classes") {
                    expect(testNetworkingService.attemptsAtPostingObject).to(equal(clientUpdatableClasses.count))
                }
                
                it("Should post the correct number of objects to the server") {
                    
                }
                
                it("Should tell the datasource the correct number of objects to delete") {
                    
                }
            }
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

