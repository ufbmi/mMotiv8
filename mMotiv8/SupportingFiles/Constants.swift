//
//  Constants.swift
//  Template
//
//  Created by Pulkit Rohilla on 21/06/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit
import Foundation

enum StoryBoardID : String{
    
    case LoginViewController = "LoginViewController",
    Home = "HomeViewController",
    DrawerMenuController = "DrawerMenuController",
    Registration = "RegistrationViewController",
    Test = "TestViewController",
    Settings = "SettingsViewController",
    Progress = "ProgressViewController",
    NavigationController = "CommonNavigationController"
}

enum FontAwesomeIcon : String{
    
    case  Home = "",
    Chart = "",
    Logout = ""
}

struct AWSConstants{
    
    let ARNDev = "arn:aws:sns:***"
    let ARNProd = "arn:aws:sns:***"
    let PoolID = "***"
}

enum ImageName : String{

    case Inhale = "inhaleCircle",
    CountDown = "countdownCircle",
    Exhale = "exhaleCircle",
    Stabilize = "stabilizingCircle"
}

struct GlobalConstants {
    
    //MARK: Numbers
    let animationDuration = 0.25
    let encryptionKey = "b5k6s9a0wc32asbo"
    let encryptionIV = "h0s9t7e2l7n4sz3s"
}

struct SingletonConstants {
    
    let KVSavedData = "savedData"
    let KVUserName = "userName"
    let KVEndpointARN = "endpointARN"
    let KVDevicePinCode = "devicePinCode"
    let KVDemoUser = "demoUser"
    let KVLoggedIn = "loggedIn"
    let KVConfigured = "configured"
}

struct SettingsScreenConstants {
 
    let pinCodeRange = (280 ... 1120)
}

struct DrawerMenuConstants{
    
    let CellIdentifier = "defaultCellIdentifier"
    let CellHeight : CGFloat = 65.0
    let Width : CGFloat = 150
}

struct WebServiceManagerConstants{

    let lambdaFunctionName = "mMotiv8Requests"
    let S3BucketName = "mmotiv8/Pictures/"
    
    enum WebserviceID: String{
        case RegisterUser = "registerUser",
        AuthenticateUser = "authenticateUser",
        UpdateARN = "updateARN",
        SubmitResult = "submitResult",
        SaveUserConfiguration = "saveUserConfiguration",
        GetTestInfo = "getTestInfo",
        GetPPMValues = "getPPMValues"
    }
}

struct ActivityIndicatorConstants{

    enum Mode : Int{
    
    case Window = 1,
    View
    }

    let labelSize : CGFloat = 17
    let smallLabelSize : CGFloat = 14
}

struct CustomFonts{
    
    enum FontName : String{
     case FontAwesome = "FontAwesome",
        Roboto_Bold = "Roboto-Bold",
        Montserrat_Regular = "Montserrat-Regular"
    }
}

struct SmokerlyzerAPIConstants{
    
    let sampleRate : Double = 41000.0
    let frameSize : Float = 512.0
    
    let sineWaveAmplitude = 10.0
    let sineWaveFrequency = 500.0
    
    let fftHelperAccumulatorDataLength = 32768
}

struct AudioManagerConstants {
    
    let busNumber = 0
    
    enum State : Int{
        
        case Ideal = 0,
        Initializing,
        Stable,
        ReadZeroFrequency,
        ReadMaximumFrequency
    }
}

struct ImageManagerConstants{
    
    let padding : CGFloat = 10
    let compression : CGFloat = 0.25
}
