//
//  APIClient.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
import Alamofire





public class APIClient: NSObject {

    public init(aBaseUrl:String){
        self.baseUrl = aBaseUrl
    }
    
    public var baseUrl : String = ""
    
    //should AnyClass be SyncableModel
    public func getDataForClass(classEndPoint : String, params:[String: AnyObject]? = nil, completionHandler:((success: Bool, results:[NSDictionary]) -> Void)?) -> (){
        Alamofire.request(.GET, self.baseUrl+classEndPoint, parameters:params).responseJSON { (_, _, result) -> Void in
            //result.value["payload"] as! NSArray
            let resultPayload = result.value as! [String: AnyObject]
            let payload = resultPayload["payload"] as! [NSDictionary]
            completionHandler?(success: result.isSuccess,results: payload)
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


