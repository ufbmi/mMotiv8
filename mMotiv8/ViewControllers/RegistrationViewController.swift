//
//  RegistrationViewController.swift
//  mMotiv8
//
//  Created by UF on 14/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    @IBOutlet weak var constraintCenter: NSLayoutConstraint!
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        removeNotifcationObserver()
    }

    
    //MARK : UITapGestureRecognizer
    @IBAction func onBackgroundTap(_ sender: Any) {
        
        self.view.endEditing(true)
        
    }
    
    //MARK : NotificationCenter
    @objc func keyboardWillShow(notification:NSNotification){
        
        var offset : CGFloat = 85.0;
        
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
    
    @IBAction func actionRegister(_ sender: Any) {
        
        if isConnectedToNetwork() {
            
            if validateEntries(){
                
                self.view.endEditing(true)
                
                registerUser()
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
    
    @IBAction func actionLogin(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: UITextField
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
     
        if textField == txtUserName{
            
            txtPassword.becomeFirstResponder()
        }
        else if textField == txtPassword{
            
            txtConfirmPassword.becomeFirstResponder()
        }
        else if textField == txtConfirmPassword{
            
            actionRegister(textField)
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
        let confirmPassword = txtConfirmPassword.text

        let isValidUser = userName != nil && userName!.lengthOfBytes(using: .utf8) > 0
        let isValidPassword = password != nil && password!.lengthOfBytes(using: .utf8) > 0
        let isValidConfirmPassword = confirmPassword != nil && confirmPassword!.lengthOfBytes(using: .utf8) > 0
        
        let isConfirmingPassword = isValidPassword && isValidConfirmPassword && password == confirmPassword
        
        var isValid = false
        var message : String?
        
        if isValidUser && isValidPassword && isConfirmingPassword{
            
            txtUserName.becomeFirstResponder()
            
            isValid = true
        }
        else if !isValidUser && !isValidPassword{
            
            isValid = false
            message = "Please provide valid user name and password."
            
            txtUserName.becomeFirstResponder()
        }
        else if !isValidUser {
            
            isValid = false
            message = "Please provide a valid user name."
            
            txtUserName.becomeFirstResponder()
        }
        else if !isValidPassword{
            
            isValid = false
            message = "Please provide a password."
            
            txtPassword.becomeFirstResponder()
        }
        else if !isValidConfirmPassword{
            
            isValid = false
            message = "Please confirm password."
            
            txtConfirmPassword.becomeFirstResponder()
        }
        else if !isConfirmingPassword{
            
            isValid = false
            message = "Password does not match the confirm password."

            txtConfirmPassword.becomeFirstResponder()
        }
        
        if message != nil{
            
            let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
       
        return isValid
    }
    
    func registerUser(){
        
        let userName = txtUserName.text
        let password = txtPassword.text
        
        ActivityIndicator.showIndicator(onView: self.view, withDescription: nil, Mode: .View)
        
        WebserviceManager.registerUser(userName: userName!, password: password!) { (success, error) in
            
            if(success){
                
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()

                    let message = "You have been registered successfully. Please login to continue."
                    
                    let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        
                        self.dismiss(animated: true, completion: nil)
                        
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
