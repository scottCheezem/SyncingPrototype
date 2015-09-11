//
//  APIClient.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit
import Alamofire



public protocol APIClass {
    func populateWithJson(jsonDict : NSDictionary)
    func jsonRepresentation() -> NSDictionary
    var apiEndPointForClass : String{ get set }
}


public class APIClient: NSObject {

    public init(aBaseUrl:String){
        self.baseUrl = aBaseUrl
    }
    
    
    public var baseUrl : String = ""
    //should AnyClass be SyncableModel
    public func getDataForClass(aClass : APIClass, params:[String: AnyObject]? = nil, completionHandler:((success: Bool, results:[NSDictionary], error:Error?) -> Void)?) {
        Alamofire.request(.GET, self.baseUrl+aClass.apiEndPointForClass, parameters:params).responseJSON { (request, response, result) -> Void in
            print("the request:", request)
            print(response)
            print(result)
        }

    }
    
//    public func postDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
//        return []
//    }
//    
//    public func putDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
//        return []
//    }
//    
//    public func deleteDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
//        return []
//    }
    
    
}
