//
//  DateFormatterExtension.swift
//  Template
//
//  Created by Pulkit Rohilla on 02/08/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

extension DateFormatter {
    
    class func timeStampFormat() -> DateFormatter{
        
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return dateFormat
    }
    
    class func imageDateFormat() -> DateFormatter{
        
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "yyyyMMddHHmms"
        
        return dateFormat
    }
    
    class func shortDateFormat() -> DateFormatter{
    
//        8-JAN-17"
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "d MMM"
        
        return dateFormat
    }
    
    class func shortDateTimeFormat() -> DateFormatter{
        
        //        8 JAN 9:00 AM"
        let dateFormat = DateFormatter.init()
        dateFormat.dateFormat = "d MMM h:mm a"
        
        return dateFormat
    }
    
    class func shortTime() -> DateFormatter{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }
}
