//
//  APIClient.swift
//  CoreDataTest
//
//  Created by Scott Cheezem on 9/10/15.
//  Copyright © 2015 Beam Technologies. All rights reserved.
//

import UIKit
import Alamofire



protocol APIClass {
    func populateWithJson(jsonDict : NSDictionary)
    func jsonRepresentation() -> NSDictionary
    var apiEndPointForClass : String{ get set }
}


class APIClient: NSObject {

    
    let baseUrl: String = ""
    
    //should AnyClass be SyncableModel
    func getDataForClass(aClass : APIClass) -> NSArray {
        return []
    }
    
    func postDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
        return []
    }
    
    func putDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
        return []
    }
    
    func deleteDataForClass(params : NSDictionary, aClass : APIClass) -> NSArray {
        return []
    }
    
    
}
