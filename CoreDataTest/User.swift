//
//  User.swift
//  CoreDataTest
//
//  Created by Adam Bailey on 9/9/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import CoreData
import DataCoordinator

class User: NSManagedObject, Syncable {
    
    // MARK: Initialization
    
    /**
    Init method that allows a user to be created though User()
    */
    convenience init() {
        print("Creating a User")
        self.init(context: CoreDataManager.shared.managedObjectContext, name: "User")
        clientCreatedAt = NSDate()
    }
    
    static var name: String = "User"
    static var primaryKeyTitle: String = "userID"
 
    // MARK: Properties
    @NSManaged var serverUpdatedAt: NSDate
    @NSManaged var clientUpdatedAt: NSDate
    @NSManaged var serverCreatedAt: NSDate
    @NSManaged var clientCreatedAt: NSDate
    @NSManaged var updatedOnClientAndServer: Bool
    @NSManaged var deletedAt : NSDate?
    // MARK: Class Functions

    func populateWithJson(jsonDict: NSDictionary) {
        
        //might need to check if a key exists or has value with something like if prop = jsonDict["key"]{..}
        userID = jsonDict["id"] as? String
        firstName = jsonDict["first_name"] as! String
        lastName = jsonDict["last_name"] as? String
        brushColor = jsonDict["color"] as? String
        imageUrl = jsonDict["picture_url"] as? String
        gender = jsonDict["sex"] as? String
        zipCode = jsonDict["postal_code"] as? String
        email = jsonDict["email"] as? String
        motorSpeedPercentage = jsonDict["motor_speed"] as? NSNumber
        autoOffTimerEnabled = jsonDict["auto_off"] as? NSNumber //would casting to bool be the right choice here?
        quadrantTimerEnabled = jsonDict["quadrant_buzz"] as? NSNumber
        birthday = NSDate.parse((jsonDict["dob"] as? String)!)
        imageChangedOn = NSDate.parse((jsonDict["picture_changed"] as? String)!)
        serverCreatedAt = NSDate.parse((jsonDict["created_at"] as? String)!)
        serverUpdatedAt = NSDate.parse((jsonDict["updated_at"] as? String)!)
        
    }
    
    var primaryKeyValue : String {
        get {
            return userID!
        }
    }
    
    func jsonRepresentation() -> NSDictionary {
        return [
            "first_name": firstName,
            "created_at": clientCreatedAt.toString(),
            "updated_at": clientCreatedAt.toString(),
            "last_name" : lastName!,
            "postal_code" : zipCode!,
            "dob" : birthday!.toString(),
            "sex":  gender!,
            "motor_speed" : motorSpeedPercentage!.stringValue,
            "auto_off" : autoOffTimerEnabled!.boolValue,
            "quadrant_buzz" : quadrantTimerEnabled!.boolValue,
            "id":userID!,
            "picture_changed" : imageChangedOn!.toString(),
            "postal_code" : zipCode!,
            "email" : email!
        ]
    }
    
    // MARK: API Endpoint
    
    static var apiEndPointForClass: String = "user"
    
    //MARK: Class specific properties
    
    @NSManaged var motorSpeedPercentage : NSNumber?
    @NSManaged var brushColor : NSString?
    @NSManaged var email : String?
    @NSManaged var gender : String?
    @NSManaged var firstName: String
    @NSManaged var lastName : String?
    @NSManaged var pusherID : String?
    @NSManaged var userID : String?
    @NSManaged var zipCode : String?
    @NSManaged var autoOffTimerEnabled : NSNumber?
    @NSManaged var brushingReminderEnabled : NSNumber?
    @NSManaged var currentUser : NSNumber?
    @NSManaged var quadrantTimerEnabled : NSNumber?
    @NSManaged var birthday : NSDate?
    @NSManaged var imageChangedOn : NSDate?
    @NSManaged var imageUrl : NSString?
    @NSManaged var devices: NSSet?
    
    
//    // MARK: Computed Properties
//    
//    var brushColor: BTBrushColor {
//        if self.currentDevice != nil {
//            return self.currentDevice.brushColor
//        } else {
//            return .Unknown
//        }
//    }
//    
//    var backgroundColor: UIColor {
//        return UIColor().BT_uiColorWithBTBrushColor(brushColor)
//    }
//    
//    var foregroundColor: UIColor {
//        return UIColor().BT_forgroundColorForBackgroundColor(brushColor)
//    }
//    
//    var dataColor: UIColor {
//        return UIColor().BT_accentColorForBackgroundColor(brushColor)
//    }
//    
//    var fullName: String {
//        if lastName {
//            return firstName + " " + lastName
//        } else {
//            return firstName
//        }
//    }
//    
//    var isSharedUser: Bool {
//        return (DataCoordinator.currentUser().userID == userID) && (email.length > 0)
//    }
//    
//    var sourceUserShare: UserShare? {
//        // Ensure that this user is one side of the relationship, and the currentUser is the other.
//        let userShare: UserShare = sharesAsReceiver.first? as? UserShare
//        if (userShare != nil) && (userShare.sender != DataCoordinator.currentUser()) {
//            userShare = sharesAsSender.first? as? UserShare
//            if (userShare != nil) && (userShare.receiver != DataCoordinator.currentUser()) {
//                userShare = nil
//            }
//        }
//        return userShare
//    }
//    
//    var hasADevice: Bool {
//        return currentDevice != nil
//    }
//    
//    var isFullFledged: Bool {
//        return email.length > 0
//    }
//    
//    var isChild: Bool {
//        return !isFullFledged
//    }
//    
//    var imageUrlString: String {
//        return kBTAbsoluteUrlUserImageForUserID(userID)
//    }
//    
//    var connectedUsers: [User] {
//        let allUserShares = sharesAsReceiver + sharesAsSender
//        let connectedUsers = connectedUsersWithUserShares(allUserShares)
//        let sortedConnectedUsers = connectedUsers.sortedArrayUsingComparator { (user1: User, user2: User) -> NSComparisonResult in
//            return user1.compareWithUser(user2)
//        }
//        return sortedConnectedUsers
//    }
//    
//    var childUsers: [User] {
//        var children = [User]()
//        for user in connectedUsers {
//            if user.isChild {
//                children.append(user)
//            }
//        }
//        return children
//    }
//    
//    var currentDevice: Device? {
//        let device: Device? = nil
//
//        let isMinePredicate = NSPredicate(format: "connectedUser.userID == %@", userID)
//        let sortDescriptor = NSSortDescriptor(key: "updatedAt", ascending: false)
//        let devicesFetchRequest = NSFetchRequest(entityName: "Device")
//        devicesFetchRequest.predicate = isMinePredicate
//        devicesFetchRequest.sortDescriptors = [sortDescriptor]
//        let myDevices = DataSource.sharedInstance.executeFetchRequest(devicesFetchRequest)
//        
//        if let devices = myDevices {
//            device = devices.first as? Device
//            
//            for dev in devices {
//                if dev.macAddress != nil && dev.updatedAt == nil {
//                    device = dev
//                    break
//                }
//            }
//        }
//        return device
//    }
//    
//    // MARK: Property Functions
//    
//    func ownsDeviceDictionary(dictionary: Dictionary<String, String>, keys: [String], completionHandler: (value: Bool) -> Void) -> () {
//        var value = deviceMatchesUserInfo(dictionary)
//        
//        if value {
//            for key in keys {
//                if dictionary[key] == nil {
//                    value = false
//                }
//            }
//        }
//        
//        completionHandler(value: value)
//    }
//    
//    func currentUserChallengeWithBlock(block: UserChallengeBlock) {
//        if overrideChallenge {
//            if block {
//                block(overrideChallenge)
//            }
//        } else {
//            let filteredChallenges = [UserChallenge]()
//            for challenge in challenges {
//                if challenge.finishedAt == nil && (challenge.silent == nil || !challenge.silent) && challenge.current) {
//                    filteredChallenges.append(challenge)
//                }
//            }
//            
//            let currentChallenge = filteredChallenges.firstObject;
//            currentChallenge.type = BTChallengeTypeTextOnly;
//            
//            if currentChallenge.startedAt == nil {
//                currentChallenge.startedAt = NSDate()
//            }
//            
//            if block {
//                block(currentChallenge)
//            }
//        }
//    }
//    
//    func connectedUsersWithUserShares(userShares: [UserShare]) {
//        let acceptedUserShares = [UserShare]()
//        for userShare in userShares {
//            if userShare.accepted {
//                acceptedUserShares.append(userShare)
//            }
//        }
//        let connectedUsers = acceptedUserShares.BT_map:^User *(UserShare *userShare) {
//            return userShare.nonCurrentUser;
//        }
//        
//        return connectedUsers
//    }
//    
//    // MARK: Internal
//    
//    func deviceMatchesUserInfo(userInfo: Dictionary<String, String>) -> Bool {
//        let macAddress = userInfo[kBTBluetoothMacAddressKey]
//        let device = DataCoordinator.firstDeviceForMacAddress(macAddress)
//        return device != nil && device.connectedUser && device.connectedUser.userID == userID
//    }
//    
//    func compareWithUser(otherUser: User) -> NSComparisonResult {
//        // Return the users sorted based on '_firstName'. This will make sure the
//        // order is always consistently the same in a way that makes sense for the
//        // end user.
//        if isSharedUser && !otherUser.isSharedUser {
//            return .OrderedDescending
//        } else if !isSharedUser && otherUser.isSharedUser {
//            return .OrderedAscending;
//        } else {
//            return firstName.compare(otherUser.firstName)
//        }
//    }
//    
//    /**
//    If the user full fledged, '_currentUser' is set to 'YES'
//    */
//    func markAsCurrentUserIfNecessary {
//        if isFullFledged {
//            // Set the current user that way we can easily retrieve the record in
//            // '+[User currentUser]'
//            currentUser = true
//        }
//    }
    
}
