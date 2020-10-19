//
//  SettingsViewController.swift
//  mMotiv8
//
//  Created by UF on 07/01/19.
//  Copyright © 2019 UF. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var txtPinCode: UITextField!
    @IBOutlet weak var lblStartTime: UILabel!
    
    var startTime : Date!
    var pinCode : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initScreen()
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            txtPinCode.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        let header : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.init(name: CustomFonts.FontName.Roboto_Bold.rawValue, size: 14)

    }

    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer : UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        footer.textLabel?.font = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: 14)
    }
    
    //MARK : DatePicker
    
    @IBAction func didChangeStartTime(_ sender: UIDatePicker) {
        
        if txtPinCode.isFirstResponder{
            txtPinCode.resignFirstResponder()
        }
        
        startTime = sender.date
        updateTimeLabel()
    }
    
    
    //MARK : UIBarButtonItem
    
    @objc func actionSave(){
        
        if isValidPinCode() && startTime != nil{
            
            if txtPinCode.isFirstResponder{
                
                txtPinCode.resignFirstResponder()
            }
            
            ActivityIndicator.showIndicator(onView: nil, withDescription: nil, Mode: .Window)
            Singleton.shared.devicePinCode = pinCode
            Singleton.shared.hasConfigured = true
            
            if Singleton.shared.isDemoUser{ //Not storing configuration settings on the internet for Demo user
                
                ActivityIndicator.hide()
                
                self.navigationDrawerController().showHomeScreen()
                
                return
            }
            
            WebserviceManager.saveUserConfiguration(startTime: startTime, devicePinCode: pinCode) { (success, error) in
                
                DispatchQueue.main.async {
                    
                    ActivityIndicator.hide()
                    
                    if success{
                        
                        self.navigationDrawerController().showHomeScreen()
                    }
                    else
                    {
                        let message = error != nil ? error : "Something went wrong. Please try again later."
                        
                        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        else
        {            
            let message = "Please enter a valid pin code."
            
            let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func actionCancel(){
    
        self.navigationDrawerController().signOut()
    }
    
    //MARK : OtherMethods
    
    func setupNavigationBar(){
        
        let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(SettingsViewController.actionSave))
        let cancelButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(SettingsViewController.actionCancel))
      
        self.navigationItem.rightBarButtonItem = saveButton
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.title = "Settings"
    }

    func initScreen(){
        
        setupNavigationBar()
        setStartTime()
        updateTimeLabel()
        
        self.navigationDrawerController().disableRightEdgeGesture()
        self.tableView.backgroundColor = UIColor.white
    }
    
    func setStartTime(){
    
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 1
        dateComponents.day = 1
        dateComponents.hour = 0
        dateComponents.minute = 0
        dateComponents.second = 0
        
        // Create date from components
        let userCalendar = Calendar.current // user calendar
        startTime = userCalendar.date(from: dateComponents)
    }
    
    func updateTimeLabel(){
    
        var startTimeString = "-"
        
        if startTime != nil{
            
            startTimeString = DateFormatter.shortTime().string(from: startTime!)
        }
        
        lblStartTime.text = startTimeString
    }
    
    func isValidPinCode()->Bool{
       
        if let pinCode = Int(txtPinCode.text!){
            
            if SettingsScreenConstants().pinCodeRange.contains(pinCode){
                
                self.pinCode = pinCode
                
                return true
            }
        }
        
        txtPinCode.becomeFirstResponder()

        return false
    }

}
