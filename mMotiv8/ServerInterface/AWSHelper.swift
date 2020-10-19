//
//  AWSHelper.swift
//  mMotiv8
//
//  Created by UF on 12/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import AWSCore
import AWSSNS

class AWSHelper{
    
    class func setupAWS(){
        
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: AWSRegionType.USEast1,
            identityPoolId: AWSConstants().PoolID)
        
        let configuration = AWSServiceConfiguration(
            region: AWSRegionType.USEast1 ,
            credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    class func registerDeviceToken(deviceToken : String){
        
        let sns = AWSSNS.default()
        
        if let request = AWSSNSCreatePlatformEndpointInput(){
            
            request.token = deviceToken
            
            #if DEV
            request.platformApplicationArn = AWSConstants().ARNDev
            #else
            request.platformApplicationArn = AWSConstants().ARNProd
            #endif

            sns.createPlatformEndpoint(request).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask!) -> AnyObject? in
                if task.error != nil {
                    print("Error: \(task.error!)")
                } else {
                    let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
                    if let endpointArnForSNS = createEndpointResponse.endpointArn {
                        
                        Singleton.shared.endpointARN = endpointArnForSNS
                        print("endpointArn: \(endpointArnForSNS)")
                    }
                }
                return nil
            })
        }
    }
}


