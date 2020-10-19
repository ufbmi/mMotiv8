//
//  AudioManager.swift
//  mMotiv8
//
//  Created by UF on 19/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import Foundation
import AVFoundation

protocol AudioManagerDelegate : AnyObject{
    
    func didChangeDeviceState(isPluggedIn : Bool)
    func didChangeVolume(_ volume : Float)
    func didFallOutOfRange()
    func didNotAllowMic()

    func finishingStabilization()
    func didStabilize()
    func didStartReading()
    func didCalculatePPM(_ reading : Int)
}

class AudioManager : NSObject, FFTHelperDelegate{
    
    weak var delegate : AudioManagerDelegate!

    let audioSession = AVAudioSession.sharedInstance()
    let audioEngine = AVAudioEngine()

    var sineWaveNode : SineWaveNode!
    var audioInputNode : AVAudioInputNode!

    var fft : FFTHelper!
    
    var state : AudioManagerConstants.State = AudioManagerConstants.State.Ideal
    
//    private var minFrequencies = [Int]()
    
    private var minFrequency = 1050
    private var maxFrequency = 0
    
    private let validFrequencyRange = 700...9500
    private let pinCode = Singleton.shared.devicePinCode
    
    private var subscribedToVolumeChanges = false
    
    override init(){
    
        super.init()
        
        do{
            try audioSession.setPreferredSampleRate(SmokerlyzerAPIConstants().sampleRate)
            try audioSession.setPreferredIOBufferDuration(0.01)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement, options: AVAudioSession.CategoryOptions.allowBluetoothA2DP)
            try audioSession.setActive(true)
            
            self.startObservingVolumeChanges()
            self.setupNotifications()
        }
        catch{
            
            print("Unable to activate")
        }
    }
    
    func deinitAudioManager() {
    
        do{
            if audioEngine.isRunning{
                
                audioEngine.stop()
            }
            
            try audioSession.setActive(false)
            
            self.stopObservingVolumeChanges()
            self.removeNotificationObserver()
        }
        catch{
            
            print("Unable to deactivate")
        }
    }
    
    //FFTHelperDelegate
    func didMeasureFrequency(frequency: Int) {
        
//        print(frequency)

        if validFrequencyRange.contains(frequency){
         
            switch state {
            case AudioManagerConstants.State.ReadZeroFrequency:
                
                minFrequency = min(minFrequency, frequency)
                
                break
            case AudioManagerConstants.State.ReadMaximumFrequency:
                
                maxFrequency = max(maxFrequency, frequency)
                
                let ppm = (maxFrequency - minFrequency)/(pinCode / 10)
                
                if(ppm > 0){
                    
                    DispatchQueue.main.async {
                        
                        if self.delegate != nil {
                            
                            self.delegate.didCalculatePPM(ppm)
                        }
                    }
                }
                
                break
            default:
                break;
            }
        }
        else
        {
            DispatchQueue.main.async {
                
                if self.delegate != nil {
                    
                    self.delegate.didFallOutOfRange()
                }
            }
        }
        
    }
    
    
    //Hardware Checks
    
    class func isDevicePluggedIn() -> Bool{
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .measurement, options: AVAudioSession.CategoryOptions.allowBluetoothA2DP)
            
            let route = AVAudioSession.sharedInstance().currentRoute
            
            let outputs = route.outputs
            
            var isOutputConnected = false
            var isInputConnected = false
            
            for output in outputs {
                
                if output.portType == AVAudioSession.Port.headphones{
                    
                    isOutputConnected = true
                    
                    break
                }
            }
            
            if let inputs = AVAudioSession.sharedInstance().availableInputs{
                
                for input in inputs {
                    
                    if input.portType == AVAudioSession.Port.headsetMic{
                        
                        isInputConnected = true
                        
                        break
                    }
                }
            }

            return (isOutputConnected && isInputConnected)
        }
        catch{
            return false
        }
    }
    
    func returnCurrentVolumeLevel() -> Float{
        
        var volumeLevel : Float = 0;

        volumeLevel = audioSession.outputVolume
        
        return volumeLevel
    }

    //MARK: Observers
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            
            let volume = (change?[NSKeyValueChangeKey.newKey] as!
                NSNumber).floatValue
            
            if delegate != nil{
                
                delegate.didChangeVolume(volume)
            }
        }
    }
    
    @objc func handleRouteChange(_ notification: Notification) {
        
        DispatchQueue.main.async {
            
            print(notification)
            
            if self.delegate != nil{
                
                self.delegate.didChangeDeviceState(isPluggedIn: AudioManager.isDevicePluggedIn())
            }
        }
    }
    
    //MARK: OtherMethods
    
    private func startObservingVolumeChanges() {
        
        audioSession.addObserver(self, forKeyPath: "outputVolume", options:NSKeyValueObservingOptions.new, context: nil)
        subscribedToVolumeChanges = true
    }
    
    private func stopObservingVolumeChanges() {
        
        if subscribedToVolumeChanges{
            
            audioSession.removeObserver(self, forKeyPath: "outputVolume")
            subscribedToVolumeChanges = false
        }
    }
    
    private func setupNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: AVAudioSession.routeChangeNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    private func removeNotificationObserver(){
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func updateAudioManagerState(){
        
        if state == AudioManagerConstants.State.Initializing{
            
            state = AudioManagerConstants.State.Stable
            
            if self.delegate != nil{
                
                self.delegate.finishingStabilization()
            }
            
            perform(#selector(AudioManager.updateAudioManagerState), with: nil, afterDelay: TimeInterval(3))
        }
        else if state == AudioManagerConstants.State.Stable{
            
            state = AudioManagerConstants.State.ReadZeroFrequency
            
            if self.delegate != nil{
                
                self.delegate.didStabilize()
            }
            
            perform(#selector(AudioManager.updateAudioManagerState), with: nil, afterDelay: TimeInterval(15))
        }
        else if state == AudioManagerConstants.State.ReadZeroFrequency{
            
            state = AudioManagerConstants.State.ReadMaximumFrequency
            
            if self.delegate != nil{
                
                self.delegate.didStartReading()
            }
        }
    }
    
    //BreathTestMethods
    
    func startBreathTest(){
     
        initFFTHelper()
        initInputOutput { (allowed) in
            
            if allowed{
                
                self.state = AudioManagerConstants.State.Initializing
                self.minFrequency = 1050
                self.maxFrequency = 0
                
                self.perform(#selector(AudioManager.updateAudioManagerState), with: nil, afterDelay: TimeInterval(7))
            }
            else
            {
                DispatchQueue.main.async {
                    
                    if self.delegate != nil {
                        
                        self.delegate.didNotAllowMic()
                    }
                }
            }
        }
    }
    
    func stopBreathTest(){
    
        if state != .Ideal{
           
            state = .Ideal
            
            audioEngine.stop()
            removeTap()
            
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    private func initFFTHelper(){
        
        fft = FFTHelper.init(withDelegate: self)
        fft.initializeAccumulator()
    }
    
    private func initInputOutput(didAllow: @escaping (Bool) -> ()){
    
        audioSession.requestRecordPermission() {
            [unowned self] (allowed: Bool) -> Void in
            if allowed {
                
                //Input
                self.audioInputNode = self.audioEngine.inputNode
                let inputFormat = self.audioInputNode.inputFormat(forBus: AudioManagerConstants().busNumber)
                
                self.installTap(withFormat: inputFormat)
                
                //Output
                self.sineWaveNode = SineWaveNode()
                self.audioEngine.attach(self.sineWaveNode)
                
                let outputNode = self.audioEngine.outputNode
                let outputFormat = AVAudioFormat(standardFormatWithSampleRate: self.sineWaveNode.sampleRate, channels: 1)
                
                self.audioEngine.connect(self.sineWaveNode, to: outputNode, format: outputFormat)
                
                do {
                    
                    try self.audioEngine.start()
                    self.playSound()
                    
                    didAllow(true)
                    
                } catch {
                    
                    self.deinitAudioManager()
                    
                    didAllow(false)
                    
                    print("Engine not starting \(error.localizedDescription)")
                }
                
            } else {
                
                self.deinitAudioManager()
                
                didAllow(false)
                
                print("Not allowed")
            }
        }
    }
    
    private func installTap(withFormat inputFormat : AVAudioFormat){
        
        self.audioInputNode.installTap(onBus: AudioManagerConstants().busNumber, bufferSize: AVAudioFrameCount(SmokerlyzerAPIConstants().frameSize), format: inputFormat)
        { (buffer, time) -> Void in
            
            let arraySize = Int(buffer.frameLength)
            let samples = Array(UnsafeBufferPointer(start: buffer.floatChannelData![0], count:arraySize))
            
            if self.fft != nil{
                self.fft.receiveFrames(frames: samples)
            }
        }
    }
    
    private func removeTap(){
        
        self.audioInputNode.removeTap(onBus: AudioManagerConstants().busNumber)
    }
    
    private func playSound(){
        
        sineWaveNode.preparePlaying()
        sineWaveNode.play()
    }

    private func stopSound(){
        
        sineWaveNode.stop()
    }
    

}
