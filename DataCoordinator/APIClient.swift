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
        Alamofire.request(.GET, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON { (request, response, result) -> Void in
            debugPrint(response?.statusCode)
            completionHandler?(success: result.isSuccess,result: result.value!)
        }

    }
    
    public func postDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.POST, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func putDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.PUT, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func deleteDataForClass(classEndPoint : String, params:[String: AnyObject], headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.DELETE, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
}

public extension APIClient{
    
    public func authenticate(username: String, password: String, completionHandler:((request:URLRequestConvertible)-> Void)?) ->(){
        
        let grantType = "password"
    
        let authDic:[String:String] = ["password":password, "username":username, "grant_type":grantType]


        Alamofire.request(.POST, "https://staging.beam.dental/api/v1/users/token", parameters: authDic).responseJSON { (request, response, result) -> Void in
            
            let payload = result.value!["payload"] as! NSArray
            
            let bearerToken = payload.firstObject
            debugPrint("bearer token:",bearerToken)
            let bearerTokenString = bearerToken?["access_token"] as? String
            debugPrint(bearerTokenString)
            
            var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            defaultHeaders["Authorization"] = "Bearer \(bearerTokenString)"

            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.HTTPAdditionalHeaders = defaultHeaders
            self.manager = Alamofire.Manager(configuration: config)
            
            
            
            debugPrint(self.manager.session.configuration.HTTPAdditionalHeaders)

         
        }
        
        
    }
}

public extension URLRequestConvertible {
    
}


