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
    public func getDataForClass(classEndPoint : String, params:[String: AnyObject]? = nil, completionHandler:((success: Bool, result:AnyObject) -> Void)?) -> (){
        Alamofire.request(.GET, self.baseUrl+classEndPoint, parameters:params).responseJSON { (_, _, result) -> Void in
            completionHandler?(success: result.isSuccess,result: result.value!)
        }

    }
    
    public func postDataForClass(classEndPoint : String, params:[String: AnyObject], completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.POST, self.baseUrl+classEndPoint, parameters:params).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func putDataForClass(classEndPoint : String, params:[String: AnyObject], completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.PUT, self.baseUrl+classEndPoint, parameters:params).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
    
    public func deleteDataForClass(classEndPoint : String, params:[String: AnyObject], completionHandler:((success: Bool, result:AnyObject) -> Void)?)->() {
        Alamofire.request(.DELETE, self.baseUrl+classEndPoint, parameters:params).responseJSON {
            (_, _, result)->Void in
            completionHandler?(success: result.isSuccess, result: result.value!)
        }
    }
}


