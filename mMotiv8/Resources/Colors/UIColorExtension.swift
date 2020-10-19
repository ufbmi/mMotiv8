//
//  UIColorExtension.swift
//  Template
//
//  Created by Pulkit Rohilla on 27/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var customBlue: UIColor{
        let customBlue = 0x0078AA
        return UIColor.rgb(fromHex: customBlue)
    }
    
    class var customOrangeYellow: UIColor{
        let customOrangeYellow = 0xE29023
        return UIColor.rgb(fromHex: customOrangeYellow)
    }
    
    class var customDarkGray: UIColor{
        let customDarkGray = 0x333333
        return UIColor.rgb(fromHex: customDarkGray)
    }
    
    class var customLightBlue: UIColor {

        let customBlue = 0xc8e4f0
        return UIColor.rgb(fromHex: customBlue)
    }
//
//    class var customNavyBlue:UIColor{
//
//        let customColor = 0x19395D
//        return UIColor.rgb(fromHex: customColor)
//    }
//
//    class var customDarkBlue: UIColor{
//
//        let customDarkBlue = 0x144996
//        return UIColor.rgb(fromHex: customDarkBlue)
//    }
//
//    class var customLightDarkBlue: UIColor{
//
//        let customDarkBlue = 0x2386DB
//        return UIColor.rgb(fromHex: customDarkBlue)
//    }
//
//    class var customMustard : UIColor{
//
//        let customMustard = 0xfda829
//        return UIColor.rgb(fromHex: customMustard)
//    }
//
//    class var customLightMaroon : UIColor{
//
//        let customLightMaroon = 0xf7e5e8
//        return UIColor.rgb(fromHex: customLightMaroon)
//    }
//
//    class var customMaroon : UIColor{
//
//        let customMaroon = 0xBE0124
//        return UIColor.rgb(fromHex: customMaroon)
//    }
//
//    class var customLightGray : UIColor{
//
//        let customLightGray = 0xD5D7D7
//        return UIColor.rgb(fromHex: customLightGray)
//    }
//
//    class var customHeaderGray : UIColor{
//
//        let customHeaderGray = 0xededed
//        return UIColor.rgb(fromHex: customHeaderGray)
//    }
    
    class func rgb(fromHex: Int) -> UIColor {
        
        let red =   CGFloat((fromHex & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((fromHex & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(fromHex & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
