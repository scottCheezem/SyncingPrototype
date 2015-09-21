//
//  Syncable.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

/**
*  Protocol used for classes that are posted and or fetched from a server
*/
public protocol APIClass {
    static var name : String { get set }
    func populateWithJson(jsonDict : NSDictionary)
    func jsonRepresentation() -> NSDictionary
    static var apiEndPointForClass : String { get set }
    /// Name of the property that is used to hold the primaryKeyValue
    static var primaryKeyTitle : String { get }
    /// Value for the property that is the primaryKey
    var primaryKeyValue : String { get }
}

internal extension APIClass {
    /**
    Method that returns a predicate used to retrieve this object from
    a selection
    
    - returns: Predicate used for filtering this object from a larger collection.
    */
    internal func predicateForFindingThisObject() -> NSPredicate {
        let predicateString = Self.primaryKeyTitle + "= %@"
        return NSPredicate(format: predicateString, argumentArray: [primaryKeyValue])
    }
    
    /**
    Updates the called object with the content of the passed in object.
    
    - parameter apiClassObject: object whose properties will update the called object.
    */
    internal func updateWithContentsOfAPIClassObject(apiClassObject : APIClass) {
        
        guard apiClassObject.primaryKeyValue == primaryKeyValue else { return }
        
        let jsonForUpdatingObject = apiClassObject.jsonRepresentation()
        populateWithJson(jsonForUpdatingObject)
    }
}

/**
*  Protocol used for classes that can updated from client to server.
*/
//TODO: Change the name of this and Syncable
public protocol Updateable: APIClass {
    var clientCreatedAt : NSDate { get set }
    var updatedOnClientAndServer : Bool { get set }
}

/**
*  Protocol for classes that can be created and passed between the client and the server.
*/
public protocol Syncable: Updateable {
    var serverUpdatedAt : NSDate { get set }
    var clientUpdatedAt : NSDate { get set }
    var serverCreatedAt : NSDate { get set }
    var deletedAt : NSDate? { get set }
}

extension NSDate {
    
    enum format : String{
        case rfc3339DateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
    }
    
    var calendar: NSCalendar {
        return NSCalendar(identifier: NSCalendarIdentifierGregorian)!
    }
    
    func after(value: Int, calendarUnit:NSCalendarUnit) -> NSDate{
        return calendar.dateByAddingUnit(calendarUnit, value: value, toDate: self, options: NSCalendarOptions(rawValue: 0))!
    }
    
    func minus(date: NSDate) -> NSDateComponents{
        return calendar.components(NSCalendarUnit.Minute, fromDate: self, toDate: date, options: NSCalendarOptions(rawValue: 0))
    }
    
    func equalsTo(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedSame
    }
    
    func greaterThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedDescending
    }
    
    func lessThan(date: NSDate) -> Bool {
        return self.compare(date) == NSComparisonResult.OrderedAscending
    }
        
    public class func parse(dateString: String, format: String = format.rfc3339DateFormat.rawValue) -> NSDate{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.dateFromString(dateString)!
    }
    
    public func toString(format: String = format.rfc3339DateFormat.rawValue) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
}