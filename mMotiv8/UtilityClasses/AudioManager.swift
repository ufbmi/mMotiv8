//
//  AudioManager.swift
//  SmokingApp
//
//  Created by UF on 19/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioManagerDelegate : AnyObject{
    
    func didChangeVolume(_ volume : Float)
}

class AudioManager : NSObject{
    
    static let shared = AudioManager.init()

    let audioSession = AVAudioSession.sharedInstance()
    
    weak var delegate : AudioManagerDelegate!
    
    override init(){
    
        do{
            try audioSession.setActive(true, options: [])
        }
        catch{
            
            print("Unable to activate")
        }
//        setupNotifications()
    }
    
    //Hardware Checks
    
    func isDevicePluggedIn() -> Bool{
        
        let route = audioSession.currentRoute
        
        let outputs = route.outputs
        
        for output in outputs {
            
            if output.portType == AVAudioSession.Port.headphones{
                
                return true
            }
        }
        
        return false
    }
    
    
    func returnCurrentVolumeLevel() -> Float{
        
        var volumeLevel : Float = 0;
        
        volumeLevel = audioSession.outputVolume
        print(volumeLevel)
        
        return volumeLevel
    }
    
    func startObservingVolumeChanges() {
        
        audioSession.addObserver(self, forKeyPath: "outputVolume", options:
            NSKeyValueObservingOptions.new, context: nil)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            
            let volume = (change?[NSKeyValueChangeKey.newKey] as!
                NSNumber).floatValue
            
            if delegate != nil{
                
                delegate.didChangeVolume(volume)
            }
            
            print("Volume Changed")
        }
    }
    
    func stopObservingVolumeChanges() {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }
    
    //BreathTestMethods
    
    

//    func setupNotifications() {
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleRouteChange),
//                                               name: AVAudioSession.routeChangeNotification,
//                                               object: AVAudioSession.sharedInstance())
//    }
//
//    @objc func handleRouteChange(_ notification: Notification) {
//
//        guard let userInfo = notification.userInfo,
//            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
//            let reason = AVAudioSession.RouteChangeReason(rawValue:reasonValue) else {
//                return
//        }
//
//        let route = AVAudioSession.sharedInstance().currentRoute
//
//        print(route.description)
//        print(reasonValue)
//    }
}
