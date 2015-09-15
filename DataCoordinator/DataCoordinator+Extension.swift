//
//  DataCoordinator+Extension.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/15/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import CoreData

public extension DataCoordinator {

    // MARK: User
    
    public func currentUser() -> User? {
        let currentUserFetchRequest = NSFetchRequest(entityName: "User")
        let currentUserPredicate = NSPredicate(format: "currentUser == %@", true)
        currentUserFetchRequest.predicate = currentUserPredicate
        if DataSource.sharedInstance.executeFetchRequest(currentUserFetchRequest)?.first != nil {
            return DataSource.sharedInstance.executeFetchRequest(currentUserFetchRequest)?.first as? User
        } else {
            return nil
        }
    }
    
//    public func currentUserAndConnectedUsers() -> [User]? {
//        var userAndConnectedUsers = [User]()
//        let user = currentUser()
//            if user != nil {
//                userAndConnectedUsers.append(user!)
//            for connectedUser in user!.connectedUsers {
//                userAndConnectedUsers.append(connectedUser)
//            }
//        }
//        return userAndConnectedUsers
//    }
//    
//    public func login(email: String, password: String, completionHandler: (success: Bool) -> Void) -> () {
//        // TODO scott?
//    }
//    
//    public func logOut() {
//        // TODO scott?
//    }
//    
//    // MARK: RollingDay
//    
//    public func createRollingDay(date: NSDate, duration: NSNumber, userID: String, completionHandler: (rollingDay: RollingDay) -> Void) -> () {
//        let userIDFetchRequest = NSFetchRequest(entityName: "User")
//        let userIDPredicate = NSPredicate(format: "userID == %@", userID)
//        userIDFetchRequest.predicate = userIDPredicate
//        
//        let userForRollingDay = DataSource.sharedInstance.executeFetchRequest(userIDFetchRequest)?.first as! User
//        
//        let rollingDay = RollingDay()
//        rollingDay.date = date
//        rollingDay.summary = userForRollingDay.summary
//        
//        let morningSnapshot = Snapshot()
//        let eveningSnapshot = Snapshot()
//        
//        rollingDay.morningStats = morningSnapshot
//        rollingDay.eveningStats = eveningSnapshot
//        
//        let durationString = String("%@", Int(BT_createDurationStringWithDuration(duration)))
//        
//        if NSDate().BT_isMorning(date) {
//            rollingDay.morningStats.duration = durationString
//        } else {
//            rollingDay.eveningStats.duration = durationString
//        }
//
////        if DataSource.sharedInstance.saveObjects([rollingDay]) {
////            completionHandler(rollingDay)
////        }
//    }
//    
//    // MARK: BrushEvent
//
//    public func brushEventUpdate(notification: NSNotification) {
//        let userData: Dictionary<NSObject, String> = notification.userInfo as! Dictionary<NSObject, String>
//        let macAddress: String? = userData[kBTBluetoothMacAddressKey]
//        
//        let deviceToUse: Device? = firstDeviceForMacAddress(macAddress)
//        
//        let cdEvents = [BrushEvent]()
//        // Physical Event
//        if let device = deviceToUse {
//            let btEvents: [BTBrushEvent] = userData[kBTBluetoothBrushEventsKey]
//            
//            let latestEvent = btEvents[0]
//            
//            for btEvent in btEvents {
//                if btEvent.date.isAfter(latestEvent.date) {
//                    latestEvent = btEvent
//                }
//                
//                let event = BrushEvent()
//                event.startTime = NSDate()
//                event.endTime = event.startTime.dateByAddingTimeInterval(btEvent.duration)
//                event.device = deviceToUse
//                event.customData = btEvent.rawData
//                event.brushEventType = "PhysicalEvent"
//                
//                cdEvents.append(event)
//            }
//            
//            NSNotificationCenter.defaultCenter().postNotificationName(kBTBrushEventHasBeenCreated, object: cdEvents)
//            deviceToUse.eventReadIndex = latestEvent.eventIndex
//            deviceToUse.synchronizedAt = NSDate().BT_dateWithAppliedOffsetFromGMT()
//        }
//        // Virtual Event
//        else {
//            if notification.object != nil && !(notification.object!.isKindOfClass(BTBluetoothNotifier.self)) {
//                // TODO check!!!!
//                let objectsArray = notification.object
//                
//                let user = objectsArray?.lastObject as! User
//                // Some users are going to have a beam brush and some aren't.  Since we only get the most recent
//                // device back from the server, we should default to sending the virtual event with the beam brush.
//                deviceToUse = user.currentDevice
//                
//                let event = BrushEvent()
//                event.startTime = objectsArray?.firstObject as NSDate
//                event.endTime = objectsArray[1] as NSDate
//                event.device = deviceToUse
//                event.brushEventType = "VirtualEvent"
//                
//                cdEvents.append(event)
//                
//                NSNotificationCenter.defaultCenter().postNotificationName(kBTBrushEventHasBeenCreated, object: cdEvents)
//                deviceToUse.synchronizedAt = NSDate().BT_dateWithAppliedOffsetFromGMT()
//            }
//        }
//        
////        if DataSource.sharedInstance.saveObjects(cdEvents) {
////            
////        }
//    }
//    
//    // MARK: ClientDevice
//    
//    public func currentClientDevice() -> ClientDevice? {
//        let currentClientDeviceFetchRequest = NSFetchRequest(entityName: "ClientDevice")
//        let currentClientDevicePredicate = NSPredicate(format: "currentDevice == %@", true)
//        currentClientDeviceFetchRequest.predicate = currentClientDevicePredicate
//        if DataSource.sharedInstance.executeFetchRequest(currentClientDeviceFetchRequest)?.first != nil {
//            return DataSource.sharedInstance.executeFetchRequest(currentClientDeviceFetchRequest)?.first as? ClientDevice
//        } else {
//            return nil
//        }
//    }
//    
//    public func vendorID() -> String? {
//        return UIDevice.currentDevice().identifierForVendor?.UUIDString
//    }
//    
//    public func sendClientDeviceForTheCurrentUserToTheServer(completionHandler: (success: Bool) -> Void) -> () {
//        if let user = currentUser() {
//            let localClientDevice = ClientDevice()
//            localClientDevice.user = user
//            localClientDevice.notificationToken = BTSessionService.sharedInstance.remoteNotificationsDeviceToken
//            localClientDevice.currentDevice = NSNumber(bool: true)
////            if DataSource.sharedInstance.saveObjects([localClientDevice]) {
////                completionHandler(success: true)
////            }
//        } else {
//            print("Current user was nil, could not send client device to the server")
//            completionHandler(success: false)
//        }
//    }
//    
//    // MARK: ClientSession
//    
//    // MARK: ClientSoftware
//    
//    // MARK: Device
//    
//    public func fetchObjectsForBTSetupDevices(setupDevices: [BTSetupDevice], completionHandler: (objects: [AnyObject]?) -> Void) -> () {
//        var macAddresses = [String]()
//        for device in setupDevices {
//            macAddresses.append(device.brushData.macAddress)
//        }
//
//        if macAddresses.count == 0 {
//            print("macAddresses was empty")
//            completionHandler(objects: nil)
//        } else {
//            var devices = Set(macAddresses)
//            if devices.count == 0 {
//                completionHandler(objects: Array(devices))
//            }
//            // Fetch objects from the server. If something fails, still return
//            // what we have already fetched out of Core Data.
//            
////            else {
////                // TODO Scott?
////            }
//        }
//    }
//    
//    public func createDeviceFromSetupDevice(setupDevice: BTSetupDevice, user: User) -> Device? {
//        let localUserFetchRequest = NSFetchRequest(entityName: "User")
//        let localUserPredicate = NSPredicate(format: "userID == %@", user.userID)
//        localUserFetchRequest.predicate = localUserPredicate
//        if DataSource.sharedInstance.executeFetchRequest(localUserFetchRequest)?.first != nil {
//            let localUser = DataSource.sharedInstance.executeFetchRequest(localUserFetchRequest)?.first as? User
//            let device = Device(setupDevice, user: user)
//            return device
//        }
//        return nil
//    }
//    
//    public func connectedDevices() -> Set<Device>? {
//        var devices = Set<Device>
//        if let users = currentUserAndConnectedUsers() {
//            for user in users {
//                if user.currentDevice {
//                    devices.insert(user.currentDevice)
//                }
//            }
//        }
//        return devices
//    }
//    
//    // MARK: UserShare
    
}