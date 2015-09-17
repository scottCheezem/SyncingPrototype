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
    
    
    public var manager = Alamofire.Manager.sharedInstance
    
    
    //should AnyClass be SyncableModel
    public func getDataForClass(classEndPoint : String, params:[String: AnyObject]? = nil, headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?) -> (){
        self.manager.request(.GET, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON { (_, _, result) -> Void in
            debugPrint(self.manager.session.configuration.HTTPAdditionalHeaders)
            completionHandler?(success: result.isSuccess,result: result.value!)
        }

    }
    
    public func postDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        self.manager.request(.POST, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func putDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        self.manager.request(.PUT, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func deleteDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        self.manager.request(.DELETE, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
}

public extension APIClient{
    
    public func authenticate(username: String, password: String){
        
        let grantType = "password"
    
        let authDic:[String:String] = ["password":password, "username":username, "grant_type":grantType]


        self.manager.request(.POST, "https://staging.beam.dental/api/v1/users/token", parameters: authDic).responseJSON { (request, response, result) -> Void in
            let payload = result.value!["payload"] as! NSArray
            let bearerToken = payload.firstObject
//            debugPrint(bearerToken)
            var authHeaders:[String:String] = [:]
            authHeaders["Authorization"] = "Bearer "+(bearerToken!["access_token"] as? String)!
            self.manager.session.configuration.HTTPAdditionalHeaders = authHeaders
            debugPrint("the manager's headers are here",self.manager.session.configuration.HTTPAdditionalHeaders)
         
        }

        
    }
}
