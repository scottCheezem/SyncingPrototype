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

public class User: NSManagedObject, Syncable {
    
    // MARK: Initialization
    
    /**
    Init method that allows a user to be created though User()
    */
    convenience init() {
        print("Creating a User")
        self.init(context: CoreDataManager.shared.managedObjectContext, name: "User")
        clientCreatedAt = NSDate()
    }
    
    static public var name: String = "User"
    static public var primaryKeyTitle: String = "userID"
 
    // MARK: Properties
    
    @NSManaged public var firstName: String
    @NSManaged public var serverUpdatedAt: NSDate
    @NSManaged public var clientUpdatedAt: NSDate
    @NSManaged public var serverCreatedAt: NSDate
    @NSManaged public var clientCreatedAt: NSDate
    @NSManaged public var updatedOnClientAndServer: Bool
    @NSManaged public var deletedAt : NSDate?
    // MARK: Class Functions

    public func populateWithJson(jsonDict: NSDictionary) {
        firstName = jsonDict["first_name"] as! String
        
        serverCreatedAt = NSDate.parse((jsonDict["created_at"] as? String)!)
        serverUpdatedAt = NSDate.parse((jsonDict["updated_at"] as? String)!)
    }
    
    public var primaryKeyValue : String {
        get {
            return "EventuallyTheUserID"
        }
    }
    
    public func jsonRepresentation() -> NSDictionary {
        return ["first_name": firstName, "created_at": clientCreatedAt.toString(), "updated_at": clientCreatedAt.toString()]
    }
    
    // MARK: API Endpoint
    
    static public var apiEndPointForClass: String = "user"
    
    // MARK: Computed Properties
    
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
//    // MARK: Property Functions
//    
//    public func ownsDeviceDictionary(dictionary: Dictionary<String, String>, keys: [String], completionHandler: (value: Bool) -> Void) -> () {
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
//    // MARK: Internal
//    
//    func deviceMatchesUserInfo(userInfo: Dictionary<String, String>) -> Bool {
//        let macAddress = userInfo[kBTBluetoothMacAddressKey]
//        let device = DataCoordinator.firstDeviceForMacAddress(macAddress)
//        return device != nil && device.connectedUser && device.connectedUser.userID == userID
//    }
}
