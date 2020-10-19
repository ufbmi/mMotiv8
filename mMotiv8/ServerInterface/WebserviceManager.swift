//
//  WebserviceManager.swift
//  Template
//
//  Created by Pulkit Rohilla on 04/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import Foundation
import UIKit

class WebserviceManager{
    
    static var requestCounter : Int = 0

    class func registerUser(userName : String, password : String, completion: @escaping (_ success: Bool, _ error: String?)->()){
        
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.RegisterUser.rawValue
        let encryptedPassword = password.aesEncrypt(key: GlobalConstants().encryptionKey, iv: GlobalConstants().encryptionIV)!
        let hasConfiguredFlag = false
        
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased(),
                                           "password":encryptedPassword,
                                           "hasConfigured":hasConfiguredFlag]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            completion(success, error)
            
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }

    class func authenticateUser(userName : String, password : String, completion: @escaping (_ success: Bool, _ error: String?, _ data: [String : Any]?)->()){
        
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.AuthenticateUser.rawValue
        let encryptedPassword = password.aesEncrypt(key: GlobalConstants().encryptionKey, iv: GlobalConstants().encryptionIV)!

        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased(),
                                           "password":encryptedPassword]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            if data != nil{
                
                completion(success, error, data as? [String : Any])
            }
            else
            {
                completion(success, error, nil)
            }
            
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }
    
    class func updateARN(){
    
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
                
        let webserviceID = WebServiceManagerConstants.WebserviceID.UpdateARN.rawValue
        let userName = Singleton.shared.userName
        let endPointARN = Singleton.shared.endpointARN
        
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased(),
                                           "endPointARN":endPointARN]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            print(success)
            print(endPointARN)
            
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }
    
    class func submitResult(result : ResultClass, completion: @escaping (_ success: Bool, _ error: String?)->()){
        
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.SubmitResult.rawValue
        
        let userName = Singleton.shared.userName
        let testID = result.getTestID()
        let timeStamp = result.getTimeStamp()
        let timeStampString = DateFormatter.timeStampFormat().string(from: timeStamp)
        let ppmReading = result.getPPMReading()
        
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased(),
                                           "testID":testID,
                                           "timeStamp":timeStampString,
                                           "ppm":ppmReading]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            if success {
                
                if Singleton.shared.isDemoUser{
                    
                    DispatchQueue.main.async(execute: {
                        
                        completion(success, nil)
                    })
                    
                    WebserviceManager.decreaseRequestCounter()
                    WebserviceManager.updateNetworkActivityIndicator()
                    
                    return
                } // Not required to save image data for demo user
                
                if let imageData = ImageManager.getImageData(imageID: testID){
                    
                    S3Manager.uploadImage(imageName: testID, data: imageData, completion: { (uploaded, errorString) in
                        
                        let complete = uploaded && success
                        var message = error != nil ? error : errorString
                        
                        if(!complete && message == nil){
                            message = "Something went wrong. Please try again later."
                        }
                        
                        DispatchQueue.main.async(execute: {
                            
                            completion(complete, message)
                            
                        })
                        
                        WebserviceManager.decreaseRequestCounter()
                        WebserviceManager.updateNetworkActivityIndicator()
                    })
                }
            }
            
        }
    }
    
    class func saveUserConfiguration(startTime : Date, devicePinCode: Int, completion: @escaping (_ success: Bool, _ error: String?)->()){
        
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.SaveUserConfiguration.rawValue
        
        let userName = Singleton.shared.userName
        let startTimeString = DateFormatter.shortTime().string(from: startTime)
        
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased(),
                                           "startTime":startTimeString,
                                           "devicePinCode":devicePinCode]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            completion(success, error)
                        
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }
    
    class func getTestInfo(completion: @escaping (_ success: Bool, _ error: String?, _ data: [String : Any]?)->()){
    
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.GetTestInfo.rawValue
        
        let userName = Singleton.shared.userName
    
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased()]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
            
            if(data != nil){
                
                completion(success, error, data as? [String : Any])
            }
            else
            {
                completion(success, error, nil)
            }
            
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }
    
    class func getPPMValues(completion: @escaping (_ success: Bool, _ error: String?, _ data: [[String : Any]]?)->()){
    
        WebserviceManager.increaseRequestCounter()
        WebserviceManager.updateNetworkActivityIndicator()
        
        let webserviceID = WebServiceManagerConstants.WebserviceID.GetPPMValues.rawValue
        
        let userName = Singleton.shared.userName
        
        let jsonObject : [String : Any] = ["webserviceID":webserviceID,
                                           "userName":userName.lowercased()]
        
        LambdaTaskManager.taskWithJSON(jsonObject: jsonObject) { (success, error, data) in
   
            if(data != nil){
                
                completion(success, error, data as? [[String : Any]])
            }
            else
            {
                completion(success, error, nil)
            }
   
            WebserviceManager.decreaseRequestCounter()
            WebserviceManager.updateNetworkActivityIndicator()
        }
    }
    
    //MARK : ClassMethods

    class func increaseRequestCounter(){

        requestCounter += 1

        print("Request No. \(requestCounter)")
    }

    class func decreaseRequestCounter(){

        requestCounter -= 1

        print("Request No. \(requestCounter)")
    }

    class func updateNetworkActivityIndicator(){

        DispatchQueue.main.async {

            if requestCounter > 0 {

                if !UIApplication.shared.isNetworkActivityIndicatorVisible {

                    UIApplication.shared.isNetworkActivityIndicatorVisible = true
                }
            }
            else
            {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}

