//
//  APIClient+Authentication.swift
//  
//
//  Created by Scott Cheezem on 9/21/15.
//
//

import DataCoordinator//disable this import to work with PlayGround


extension APIClient{
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

