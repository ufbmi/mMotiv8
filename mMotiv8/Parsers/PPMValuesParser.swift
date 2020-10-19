//
//  PPMValuesParser.swift
//  mMotiv8
//
//  Created by UF on 23/01/19.
//  Copyright © 2019 UF. All rights reserved.
//

import Foundation

class PPMValuesParser{
 
    class func returnParsedValues(dataArray : [[String : Any]]!) -> [String : Int]!{
        
        var ppmValues = [String : Int]()
        
        for dictData in dataArray{
        
            if let timeStamp = dictData["TimeStamp"] as? String{
                
                if let longDate = DateFormatter.timeStampFormat().date(from: timeStamp){
                    
                    let shortDate = DateFormatter.shortDateTimeFormat().string(from: longDate)
                    let reading = dictData["PPM"] as! Int
                    
                    ppmValues[shortDate] = reading
                }
            }
        }

        return ppmValues
    }
}

