//
//  APIClient.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import Foundation
//import Alamofire

public class APIClient: NSObject {

    
    /**
    
    The APIClient class represents the basic standard REST actions GET PUT POST and DELETE.  each of these core methods comes with optionanl argments for headers, http parameters and a call back for the completion handler that returns the JSON encoded result and success Boolean.  This class is designed to work with model classes that conform to the APIClass protocol (or other classes/protocols that derive from it), using the apiEndPointForClass
    
    - parameter aBaseUrl: a String for the base url, currently must be terminated by a /
    
    
    */
    public init(aBaseUrl:String){
        self.baseUrl = aBaseUrl
    }
    
    public var baseUrl : String = ""
    
    public var manager = Manager.sharedInstance
    
    
    
    public func getDataForClass(classEndPoint : String, params:[String: AnyObject]? = nil, headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject, statusCode:Int?) -> Void)?) -> (){
        self.manager.request(.GET, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (request, response, result) -> Void in
            completionHandler?(success: result.isSuccess,result: result.value!, statusCode:response?.statusCode)
        }

    }
    
    public func postDataForClass(classEndPoint : String, params:[String: AnyObject]?=nil, headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject, statusCode:Int?) -> Void)?)->() {
        self.manager.request(.POST, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (request, response, result) -> Void in
            completionHandler?(success: result.isSuccess, result: result.value!, statusCode:response?.statusCode)
        }
    }
    
    public func putDataForClass(classEndPoint : String, params:[String: AnyObject]?=nil, headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject, statusCode:Int?) -> Void)?)->() {
        self.manager.request(.PUT, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (request, response, result) -> Void in
            completionHandler?(success: result.isSuccess, result: result.value!, statusCode:response?.statusCode)
        }
    }
    
    public func deleteDataForClass(classEndPoint : String, params:[String: AnyObject]?=nil, headers:[String : String]?=nil, completionHandler:((success: Bool, result:AnyObject, statusCode:Int?) -> Void)?)->() {
        self.manager.request(.DELETE, self.baseUrl+classEndPoint, parameters:params, headers:headers).responseJSON {
            (request, response, result) -> Void in
            completionHandler?(success: result.isSuccess, result: result.value!, statusCode:response?.statusCode)
        }
    }
}



public extension APIClient{

    
    
    
    public func authenticate(username: String, password: String, completionHandler:((success: Bool) -> Void)? ) ->(){
        let grantType = "password"
        let authDic:[String:String] = ["password":password, "username":username, "grant_type":grantType]
        
        request(.POST, "https://staging.beam.dental/api/v1/users/token", parameters: authDic).responseJSON {
            (request, response, result) -> Void in
            
            let payload = result.value!["payload"] as! NSArray
            
            let bearerToken = payload.firstObject
            
            let bearerTokenString = bearerToken?["access_token"] as? String
            
            var defaultHeaders = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
            defaultHeaders["Authorization"] = "Bearer \(bearerTokenString!)"
            
            let config = NSURLSessionConfiguration.defaultSessionConfiguration()
            config.HTTPAdditionalHeaders = defaultHeaders
            self.manager = Manager(configuration: config)
            completionHandler?(success: result.isSuccess)
            
        }
        
    }
    
    public func invalidateAccessToken(completionHandler:((success:Bool, result:AnyObject)-> Void)?) ->() {
        self.deleteDataForClass("users/token") { (success, result, statusCode) -> Void in
            var headers = self.manager.session.configuration.HTTPAdditionalHeaders ?? [:]
            headers.removeValueForKey("Authorization")
        }
    }

}


