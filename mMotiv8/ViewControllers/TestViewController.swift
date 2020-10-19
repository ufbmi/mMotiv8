//
//  TestViewController.swift
//  mMotiv8
//
//  Created by UF on 19/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, AudioManagerDelegate, ImageManagerDelegate {

    @IBOutlet weak var promptView: UIView!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var imgPrompt: UIImageView!
    @IBOutlet weak var lblPrompt: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblButtonPrompt: UILabel!
    
    @IBOutlet weak var btnStartTest: UIButton!
    
    let imageManager = ImageManager()
    let audioManager = AudioManager()
    
    var testID : String!
    var ppmReading : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initScreen()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Deinitialize running sessions
        audioManager.deinitAudioManager()
        imageManager.deinitialize()
        NotificationCenter.default.removeObserver(self)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: Notification
    @objc func didEnterBackground(_ notification: Notification) {

        self.navigationController?.popToRootViewController(animated: false)
    }
    
    //MARK: UIButton
    @IBAction func actionStartTest(_ sender: UIButton) {
        
        if sender.tag == 0 {
            
            audioManager.startBreathTest()
            
            updateScreenForCurrentState()
            
            disableStartButton()
            
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        else if sender.tag == 1
        {
            let timeStamp = Date()
            let result = ResultClass.init(testID: testID, timeStamp: timeStamp, ppmReading: ppmReading)
            
            submitTest(result: result)
        }
    }

    //MARK: AudioManagerDelegate
    func didChangeDeviceState(isPluggedIn: Bool) {
    
        if isPluggedIn {
            
            checkVolumeLevel()
        }
        else
        {
            resetTest()

            lblButtonPrompt.isHidden = false
            lblButtonPrompt.text = "An iCO device is not properly connected.\nPlease reconnect the device and try again."
            
            disableStartButton()
        }
    }
    
    func didChangeVolume(_ volume: Float) {
        
        updateScreenForVolumeChanges(volume: volume)
    }
    
    func finishingStabilization() {
    
        updateScreenForCurrentState()
    }
    
    func didStabilize() {
     
        updateScreenForCurrentState()
    }
    
    func didStartReading() {
        
        updateScreenForCurrentState()
    }
    
    func didCalculatePPM(_ reading: Int) {
        
        if ppmReading == 0 {
            
            imageManager.captureImage()

            perform(#selector(TestViewController.finishTest), with: nil, afterDelay: TimeInterval(20))
        }

        ppmReading = reading
        
        lblPrompt.text = "Blow slowly into the device.\nAim to empty your lungs completely.\n\nYour PPM Reading is \(reading)"
    }

    func didFallOutOfRange() {
    
        resetTest()
        
        let message = "Your iCO device is not working properly. Please reconnect the device and try again."
        
        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func didNotAllowMic() {

        let message = "Please allow application to use microphone for the test."
        
        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: hardwareNotAllowed))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: ImageManagerDelegate
    func didNotAllowCamera() {
        
        let message = "Please allow application to use camera for validation of the test."
        
        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: hardwareNotAllowed))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    //MARK: OtherMethods
    func initScreen(){
    
        checkVolumeLevel()
        initHardwareManager()
        
        imageManager.setImageID(imageID: testID)
        
        lblButtonPrompt.isHidden = true
        initInitialState()
    }
    
    @objc func updateScreenForCurrentState(){
    
        switch audioManager.state{
         
        case .Ideal:
            initInitialState()
            break
        case .Initializing:
            initStabilizingState()
            break
        case .Stable:
            initStableState()
            break
        case .ReadZeroFrequency:
            initInhaleCountDownState()
            break
        case .ReadMaximumFrequency:
            initExhaleState()
            break
        }
    }
    
    func hardwareNotAllowed(alert: UIAlertAction!){
    
        disableStartButton()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func initInitialState(){

        promptView.alpha = 0
        buttonView.alpha = 1
    }
    
    func initStabilizingState(){

        hideButtonView()
        showPromptView()
        
        imgPrompt.image = UIImage.init(named: ImageName.Stabilize.rawValue)

        lblPrompt.isHidden = true
        lblTime.isHidden = true
    }
    
    func initStableState(){

        imgPrompt.image = UIImage.init(named: ImageName.Inhale.rawValue)
        
        lblPrompt.isHidden = true
        lblTime.isHidden = true
    }
    
    func initInhaleCountDownState(){
        
        imgPrompt.image = UIImage.init(named: ImageName.CountDown.rawValue)
        
        lblPrompt.isHidden = true
        lblTime.isHidden = false
        
        updateTimerLabel(15)
    }
    
    func initExhaleState(){
     
        imgPrompt.image = UIImage.init(named: ImageName.Exhale.rawValue)
        lblPrompt.text = "Blow slowly into the device.\nAim to empty your lungs completely"
        
        lblPrompt.isHidden = false
        lblTime.isHidden = true
    }
    
    func initFinalState(){
    
        enableStartButton()
        
        btnStartTest.setTitle("Submit", for: .normal)
        btnStartTest.tag = 1
        
        hidePromptView()
        showButtonView()
    }
    
    func showButtonView(){
        
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonView.alpha = 1
        })
    }
    
    func hideButtonView(){
        
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonView.alpha = 0
        })
    }
    
    func showPromptView(){
        
        UIView.animate(withDuration: 0.5, animations: {
            self.promptView.alpha = 1
        })
    }
    
    func hidePromptView(){
    
        UIView.animate(withDuration: 0.5, animations: {
            self.promptView.alpha = 0
        })
    }
    
    func setupNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func initHardwareManager(){
    
        audioManager.delegate = self
        imageManager.delegate = self
    }
    
    func checkVolumeLevel(){
        
        let volumeLevel = audioManager.returnCurrentVolumeLevel()
        
        updateScreenForVolumeChanges(volume: volumeLevel)
    }
    
    func updateScreenForVolumeChanges(volume : Float){
        
        if AudioManager.isDevicePluggedIn(){
            
            if volume < 1 {
                
                resetTest()

                lblButtonPrompt.isHidden = false
                lblButtonPrompt.text = "Turn volume all the way up to start the test"
                
                disableStartButton()
            }
            else
            {
                lblButtonPrompt.isHidden = true
                enableStartButton()
            }
        }
    }
    
    func resetStartButton(){
    
        btnStartTest.setTitle("Start a new test", for: .normal)
    }
    
    func enableStartButton(){
        
        btnStartTest.isEnabled = true
        btnStartTest.backgroundColor = UIColor.customOrangeYellow
    }
    
    func disableStartButton(){
        
        btnStartTest.isEnabled = false
        btnStartTest.backgroundColor = UIColor.gray
    }
    
    @objc func finishTest(){
    
        imageManager.captureImage()
        audioManager.stopBreathTest()
        
        initFinalState()
    }
    
    @objc func updateTimerLabel(_ timeLeft : NSNumber){
        
        if(Int(truncating: timeLeft) > 0) && audioManager.state != .Ideal{
            
            lblTime.isHidden = false
            lblTime.text = "\(timeLeft)"
            
            let updatedTimeLeft = Int(truncating: timeLeft) - 1
            let selectorWithParam = #selector(updateTimerLabel(_ :))

            perform(selectorWithParam, with: updatedTimeLeft, afterDelay: TimeInterval(1))
        }
        else
        {
            lblTime.isHidden = true
        }
    }
    
    func resetTest(){
       
        let selectorWithParam = #selector(updateTimerLabel(_ :))
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selectorWithParam, object: 0)

        audioManager.stopBreathTest()
        imageManager.clearDirectory()
        
        updateTimerLabel(0)
        updateScreenForCurrentState()
        resetStartButton()
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    func submitTest(result : ResultClass){
        
        ActivityIndicator.showIndicator(onView: nil, withDescription: nil, Mode: .Window)
        
        WebserviceManager.submitResult(result: result) { (success, error) in
            
            if(success){
                
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()

                    let message = error != nil ? error : "Your results have been submitted successfully."
                    
                    let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction) in

                        self.navigationController?.popToRootViewController(animated: true)
                    }))
                    
                    self.present(alert, animated: true, completion: nil)

                }
            }
            else
            {
                
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()
                    
                    let message = error != nil ? error : "Something went wrong. Please try again later."
                    
                    let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
