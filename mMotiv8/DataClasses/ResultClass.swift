//
//  ResultClass.swift
//  mMotiv8
//
//  Created by UF on 24/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import Foundation

class ResultClass{
    
    private var testID : String!
    private var timeStamp : Date!
    private var ppmReading : Int!
    
    init(testID : String, timeStamp : Date, ppmReading : Int) {
        
        self.testID = testID
        self.timeStamp = timeStamp
        self.ppmReading = ppmReading
    }
    
    func getTestID() -> String{
    
        return testID != nil ? testID : "";
    }
    
    func getTimeStamp() -> Date{
        return timeStamp != nil ? timeStamp : Date();
    }
    
    func getPPMReading() -> Int{
        return ppmReading != nil ? ppmReading : 0;
    }
}
