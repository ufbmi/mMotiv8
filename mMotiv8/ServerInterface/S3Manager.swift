//
//  S3Manager.swift
//  mMotiv8
//
//  Created by UF on 26/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import AWSS3

class S3Manager{
    
    class func uploadImage(imageName : String, data : Data, completion: @escaping (_ success: Bool, _ error: String?)->()) {
        
        let expression = AWSS3TransferUtilityUploadExpression()

        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        completionHandler = { (task, error) -> Void in
            
            if error != nil{
                
                completion(false, "Something went wrong. Please try again later.")
            }
            else{
                
                completion(true, nil)
                print("Uploaded")
            }
        }
        
        let transferUtility = AWSS3TransferUtility.default()
        let bucketName = WebServiceManagerConstants().S3BucketName + Singleton.shared.userName
        let key = imageName + ".jpg"
        let contentType = "image/jpg"
        
        transferUtility.uploadData(data,
                                   bucket: bucketName,
                                   key: key,
                                   contentType: contentType,
                                   expression: expression,
                                   completionHandler: completionHandler).continueWith {
                                    (task) -> AnyObject? in
                                    if let error = task.error {
                                        
                                        print("Error: \(error.localizedDescription)")
                                        completion(false, "Something went wrong. Please try again later.")
                                    }
                                    
                                    if let _ = task.result {
                                        // Do something with uploadTask.
                                    }
                                    return nil;
        }
    }
}
