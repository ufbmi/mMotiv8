//
//  LoginViewController.swift
//  mMotiv8
//
//  Created by UF on 18/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var viewContent: UIView!
    
    @IBOutlet weak var constraintCenter: NSLayoutConstraint!
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateContentViewVisibility()
        checkForLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeNotifcationObserver()
    }
        
    //MARK : Navigation
    
    func navigateToHomeScreen(){
        
        let storyBoard: UIStoryboard = self.storyboard!

        let menuController  = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.DrawerMenuController.rawValue)
        let frontNavController : UINavigationController = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.NavigationController.rawValue) as! UINavigationController
        
        if Singleton.shared.hasConfigured{
         
            let frontController = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.Home.rawValue)
            frontNavController.viewControllers = [frontController]
        }
        else
        {
            let frontController = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.Settings.rawValue)
            frontNavController.viewControllers = [frontController]
        }
        
        let navDrawerController = NavigationDrawerController.init(frontViewController: frontNavController, menuController: menuController)
        
        navDrawerController.modalPresentationStyle = UIModalPresentationStyle.custom
        navDrawerController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        self.present(navDrawerController, animated: true, completion: nil)
        
        clearPasswordTextField()
    }
    
    func navigateToRegistrationScreen(){
    
        let storyBoard: UIStoryboard = self.storyboard!
        let registrationController = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.Registration.rawValue)
        
        registrationController.modalPresentationStyle = UIModalPresentationStyle.custom
        registrationController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    
        self.present(registrationController, animated: true, completion: nil)

        clearPasswordTextField()
    }
    
    //MARK : UITapGestureRecognizer
    @IBAction func onBackgroundTap(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    //MARK : NotificationCenter
    @objc func keyboardWillShow(notification:NSNotification){
        
        var offset : CGFloat = 90.0;
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let rect = view.convert(keyboardRectangle, from: nil)
            let keyboardHeight = rect.height
            
            offset = min(keyboardHeight, offset)
        }
        
        constraintCenter.constant = -offset
        
        UIView.animate(withDuration: GlobalConstants().animationDuration) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        constraintCenter.constant = 0
        
        UIView.animate(withDuration: GlobalConstants().animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: UIButton
    
    @IBAction func actionLogin(_ sender: Any) {
        
        if isConnectedToNetwork() {
            
            if validateEntries(){
                
                self.view.endEditing(true)

                authenticateUser()
            }
        }
        else
        {
            let message = "Please check your internect connection and try again later."
            
            let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionRegister(_ sender: UIButton) {
        
        navigateToRegistrationScreen()
    }
    
    
    //MARK: UITextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtUserName{
            
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword{
            
            actionLogin(textField)
        }
        
        return true
    }
    
    //MARK: OtherMethods
    
    func setupKeyboardNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeNotifcationObserver(){
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func validateEntries() -> Bool{
        
        let userName = txtUserName.text
        let password = txtPassword.text
        
        let isValidUser = userName != nil && userName!.lengthOfBytes(using: .utf8) > 0
        let isValidPassword = password != nil && password!.lengthOfBytes(using: .utf8) > 0
        
        var isValid = false
        var message : String?
        
        if isValidUser && isValidPassword{
            
            txtUserName.becomeFirstResponder()
            
            isValid = true
        }
        else if !isValidUser && !isValidPassword{
            
            isValid = false
            message = "Please enter user name and password."
            
            txtUserName.becomeFirstResponder()
        }
        else if !isValidUser {
            
            isValid = false
            message = "Please enter user name."
            
            txtUserName.becomeFirstResponder()
        }
        else if !isValidPassword{
            
            isValid = false
            message = "Please enter password."
            
            txtPassword.becomeFirstResponder()
        }
        
        if message != nil{
            
            let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return isValid
    }
    
    func authenticateUser(){
        
        let userName = txtUserName.text!
        let password = txtPassword.text!
        
        ActivityIndicator.showIndicator(onView: self.view, withDescription: nil, Mode: .View)
        
        WebserviceManager.authenticateUser(userName: userName, password: password) { (success, error, data) in
            
            if(success){
                
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()
                    
                    if Singleton.shared.userName != userName{
                    
                        Singleton.shared.clearData()
                    }
                    
                    Singleton.shared.userName = userName
                    Singleton.shared.isDemoUser = (userName.lowercased() == "demo") ? true : false
                    Singleton.shared.hasLoggedIn = true

                    if !Singleton.shared.isDemoUser && data != nil{
                        
                        if let hasConfigured = data!["HasConfigured"] as? Bool{
                            Singleton.shared.hasConfigured = hasConfigured
                        }
                        
                        if let devicePinCode = data!["DevicePinCode"] as? Int{
                            Singleton.shared.devicePinCode = devicePinCode
                        }
                    }
                    
                    Singleton.shared.saveUserSelection(withKey: SingletonConstants().KVSavedData)
                    
                    KeyChainManager.savePassword(userName: userName, password: password)
                    
                    self.navigateToHomeScreen()
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
    
    func checkForLogin(){
        
        if(Singleton.shared.hasLoggedIn){
            
            let userName = Singleton.shared.userName
            let password = KeyChainManager.loadPassword(userName: userName)
            
            WebserviceManager.authenticateUser(userName: userName, password: password) { (success, error, data) in
                
                DispatchQueue.main.sync {
                    
                    if(success){
                        
                        if !Singleton.shared.isDemoUser && data != nil{
                            
                            if let hasConfigured = data!["HasConfigured"] as? Bool{
                                Singleton.shared.hasConfigured = hasConfigured
                            }
                            
                            if let devicePinCode = data!["DevicePinCode"] as? Int{
                                Singleton.shared.devicePinCode = devicePinCode
                            }
                        }
                        
                        self.navigateToHomeScreen()
                    }
                    else{
                        
                        ActivityIndicator.hide()
                        KeyChainManager.removePassword(userName: userName)
                        Singleton.shared.hasLoggedIn = false
                        
                        self.updateContentViewVisibility()
                        
                        let message = error != nil ? error : "Unable to authenticate. Please try again."
                        
                        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func updateContentViewVisibility(){
        
        if Singleton.shared.hasLoggedIn{
            
            viewContent.isHidden = true
        }
        else
        {
            viewContent.isHidden = false
            
            updateUserNameTextField()
        }
    }
    
    func updateUserNameTextField(){
        
        if(Singleton.shared.userName.lengthOfBytes(using: .utf8) > 0){
            
            txtUserName.text = Singleton.shared.userName
        }
    }
    
    func clearPasswordTextField(){
        
        txtPassword.text = nil
    }

}
