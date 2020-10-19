//
//  ExceptionParser.swift
//  Template
//
//  Created by Pulkit Rohilla on 04/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import Foundation

func returnMessageForError(resultDict : [String : Any]) -> String!{
    
    var message : String!
    
    if let errorDict = resultDict["error"] as? [String : Any]{
        
        if let code = errorDict["code"] as? String{
            
            if code == "ConditionalCheckFailedException"{
                
                message = "User already exists."
            }
        }
    }
    else if let error = resultDict["error"] as? String{
        
        message = error
    }
    
    return message
}

