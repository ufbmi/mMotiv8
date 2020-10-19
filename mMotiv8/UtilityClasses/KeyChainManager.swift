//
//  KeyChainManager.swift
//  mMotiv8
//
//  Created by UF on 31/12/18.
//  Copyright © 2018 UF. All rights reserved.
//
import Foundation
import Security

// Arguments for the keychain queries
let kSecClassValue = NSString(format: kSecClass)
let kSecAttrAccountValue = NSString(format: kSecAttrAccount)
let kSecValueDataValue = NSString(format: kSecValueData)
let kSecClassGenericPasswordValue = NSString(format: kSecClassGenericPassword)
let kSecAttrServiceValue = NSString(format: kSecAttrService)
let kSecMatchLimitValue = NSString(format: kSecMatchLimit)
let kSecReturnDataValue = NSString(format: kSecReturnData)
let kSecMatchLimitOneValue = NSString(format: kSecMatchLimitOne)

class KeyChainManager{

    class func savePassword(userName:String, password: String) {
        
        if let dataFromString = password.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            
            let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, userName, dataFromString], forKeys: [kSecClassValue, kSecAttrAccountValue, kSecValueDataValue])
            
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            
            if (status != errSecSuccess) {
                if #available(iOS 11.3, *) {
                    if let err = SecCopyErrorMessageString(status, nil) {
                        print("Write failed: \(err)")
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    
    class func removePassword(userName:String) {

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, userName, kCFBooleanTrue], forKeys: [kSecClassValue, kSecAttrAccountValue, kSecReturnDataValue])

        let status = SecItemDelete(keychainQuery as CFDictionary)
        if (status != errSecSuccess) {
            if #available(iOS 11.3, *) {
                if let err = SecCopyErrorMessageString(status, nil) {
                    print("Remove failed: \(err)")
                }
            } else {
                // Fallback on earlier versions
            }
        }

    }

    class func loadPassword(userName:String) -> String{

        let keychainQuery: NSMutableDictionary = NSMutableDictionary(objects: [kSecClassGenericPasswordValue, userName, kCFBooleanTrue, kSecMatchLimitOneValue], forKeys: [kSecClassValue, kSecAttrAccountValue, kSecReturnDataValue, kSecMatchLimitValue])

        var dataTypeRef :AnyObject?

        // Search for the keychain items
        let status: OSStatus = SecItemCopyMatching(keychainQuery, &dataTypeRef)
        var contentsOfKeychain = ""

        if status == errSecSuccess {
            if let retrievedData = dataTypeRef as? Data {
                contentsOfKeychain = String(data: retrievedData, encoding: String.Encoding.utf8)!
            }
        } else {
            print("Nothing was retrieved from the keychain. Status code \(status)")
        }

        return contentsOfKeychain
    }

}
