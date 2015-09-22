//
//  Device.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/21/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData
import DataCoordinator

class Device: NSManagedObject, Syncable {


    static internal var name: String = "Device"
    
    convenience init(){
        print("creating a brush event")
        self.init(context:CoreDataManager.shared.managedObjectContext, name:Device.name)
        clientCreatedAt = NSDate()
    }
    
    // MARK: APIClass
    
    static var apiEndPointForClass: String = "devices"
    
    func populateWithJson(jsonDict: NSDictionary) {
        
    }
    
    func jsonRepresentation() -> NSDictionary {
        return [:]
    }
    
    static var primaryKeyTitle: String = "deviceID"
    
    var primaryKeyValue : String {
        get {
            return deviceID!
        }
    }
    
    // MARK: Updateable
    @NSManaged var clientCreatedAt: NSDate
    @NSManaged var updatedOnClientAndServer: Bool
    // Mark: Syncable
    @NSManaged var serverUpdatedAt: NSDate
    @NSManaged var serverCreatedAt: NSDate
    @NSManaged var clientUpdatedAt: NSDate
    @NSManaged var deletedAt: NSDate?
    
    //MARK: Class properties
    
    @NSManaged var batteryLevelPercentage: NSNumber?
    @NSManaged var bluetoothID: String?
    @NSManaged var colorInt: NSNumber?
    @NSManaged var deviceID: String?
    @NSManaged var eventReadIndex: NSNumber?
    @NSManaged var firmwareRevision: String?
    @NSManaged var hardwareRevision: String?
    @NSManaged var initialSetup: NSNumber?
    @NSManaged var macAddress: String?
    @NSManaged var resetAt: NSDate?
    @NSManaged var synchronizedAt: NSDate?
    @NSManaged var version: String?
    @NSManaged var connectedUser: User?
    @NSManaged var brushEvents: NSSet?


}
