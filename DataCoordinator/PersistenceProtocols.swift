//
//  Syncable.swift
//  CoreDataTest
//
//  Created by Aaron Williams on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation

public protocol APIClass {
    func populateWithJson(jsonDict : NSDictionary)
    func jsonRepresentation() -> NSDictionary
    static var apiEndPointForClass : String { get set }
}


//the client code can update
protocol Updateable: APIClass {
    var clientCreatedAt : NSDate { get set }
    var isFullySynced : Bool { get set } //this was the dirty property
}

protocol Syncable: Updateable {
    var serverUpdatedAt : NSDate { get set }
    var clientUpdatedAt : NSDate { get set }
    var serverCreatedAt : NSDate { get set }
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