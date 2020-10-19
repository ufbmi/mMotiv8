//
//  LambdaTaskManager.swift
//  mMotiv8
//
//  Created by UF on 24/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import Foundation
import AWSLambda

class LambdaTaskManager{
    
    class func taskWithJSON(jsonObject : [String : Any], completion: @escaping (_ success: Bool, _ error: String?, _ data: Any?)->()){
        
        let lambdaInvoker = AWSLambdaInvoker.default()
        let functionName = WebServiceManagerConstants().lambdaFunctionName
        
        let task = lambdaInvoker.invokeFunction(functionName, jsonObject: jsonObject)
        task.continueWith { (task: AWSTask) -> Any? in
            
            var success = false
            var error : String!
            var data : Any!
            
            if task.error != nil{
                
                success = false
                error = "Exception from server : " + (task.error!.localizedDescription)
            }
            else if task.result != nil{
                
                if let responseJSON = task.result as? [String: Any]{
                    
                    if let flag = responseJSON["success"] as? Bool{
                        
                        if flag{
                            
                            success = true
                            
                            if let dataJSON = responseJSON["data"]{
                                
                                data = dataJSON
                            }
                        }
                        else{
                            
                            success = false
                            error = returnMessageForError(resultDict: responseJSON)
                        }
                    }
                }
                
                if !success && error == nil {
                    
                    error = "Something went wrong. Please try again after sometime."
                }
            }
            
            completion(success, error, data)
    
            return nil
        }
    }
}
