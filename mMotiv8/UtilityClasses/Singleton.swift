//
//  Singleton.swift
//  Template
//
//  Created by Pulkit Rohilla on 21/06/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

class Singleton : NSObject, NSCoding{

    static let shared = Singleton()

    var userName : String = ""
    var endpointARN : String = ""
    var devicePinCode : Int = 0
    
    var isDemoUser: Bool = false
    var hasLoggedIn : Bool = false
    var hasConfigured : Bool = false
    
    func saveUserSelection(withKey key : String){
        
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(encodedData, forKey: key)
    }
    
    func loadUserSelection(forKey key : String){
        
        if let data = UserDefaults.standard.data(forKey: key),
            
            let userSelection = NSKeyedUnarchiver.unarchiveObject(with: data) as? Singleton {
            
            userName = userSelection.userName
            endpointARN = userSelection.endpointARN
            devicePinCode = userSelection.devicePinCode
            isDemoUser = userSelection.isDemoUser
            hasLoggedIn = userSelection.hasLoggedIn
            hasConfigured = userSelection.hasConfigured
            
        } else {
            
//            print("Unable to retrieve selection")
        }

    }
    
    func clearData() {
        
        devicePinCode = 0
        
        isDemoUser = false
        hasConfigured = false
        hasLoggedIn = false
    }
    
    override init(){
        
    }
    
    //MARK: NSCoding
    
    func encode(with coder: NSCoder) {
        
        //Encode properties, other class variables, etc
        coder.encode(userName, forKey: SingletonConstants().KVUserName)
        coder.encode(endpointARN, forKey: SingletonConstants().KVEndpointARN)
        coder.encode(devicePinCode, forKey: SingletonConstants().KVDevicePinCode)
        coder.encode(isDemoUser, forKey: SingletonConstants().KVDemoUser)
        coder.encode(hasLoggedIn, forKey: SingletonConstants().KVLoggedIn)
        coder.encode(hasConfigured, forKey: SingletonConstants().KVConfigured)
    }
 
    required init?(coder decoder: NSCoder) {
     
        if let user = decoder.decodeObject(forKey: SingletonConstants().KVUserName) as? String{
        
            userName = user
        }
        
        if let ARN = decoder.decodeObject(forKey: SingletonConstants().KVEndpointARN) as? String{
            
            endpointARN = ARN
        }
        
        devicePinCode = decoder.decodeInteger(forKey: SingletonConstants().KVDevicePinCode)
        
        isDemoUser = decoder.decodeBool(forKey: SingletonConstants().KVDemoUser)
        hasLoggedIn = decoder.decodeBool(forKey: SingletonConstants().KVLoggedIn)
        hasConfigured = decoder.decodeBool(forKey: SingletonConstants().KVConfigured)

    }
}
