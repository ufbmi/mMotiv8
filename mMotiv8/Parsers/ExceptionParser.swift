//
//  ExceptionParser.swift
//  Template
//
//  Created by Pulkit Rohilla on 04/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import Foundation

func parseMessageFromServerException(data : Data) -> String!{
    
    var message : String!
    
    do{
        
        let serverData = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
        
        if let serverDict = serverData as? [String : Any]{
            
            if let string = serverDict["code"] as? String{
                
                message = string
            }
        }
        
    }
    catch{
        
        message = error.localizedDescription
        
        print("ExceptionParser exception \(error.localizedDescription)")
    }
    
    return message
}

