//
//  HomeViewController.swift
//  mMotiv8
//
//  Created by UF on 18/12/18.
//  Copyright © 2018 UF. All rights reserved.
//

import UIKit
import UserNotifications

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        updateARN()
    }
    
    //MARK: Navigation
    func navigateToTestScreen(testID : String){
        
        let storyBoard: UIStoryboard = self.storyboard!
        let testViewController = storyBoard.instantiateViewController(withIdentifier: StoryBoardID.Test.rawValue) as! TestViewController
        testViewController.testID = testID
        
        self.navigationController?.pushViewController(testViewController, animated: true)
    }
    
    //MARK: UIButton
    @IBAction func actionNewBreathTest(_ sender: Any) {
                
        if AudioManager.isDevicePluggedIn(){

            getCurrentTestInfo()
        }
        else
        {
            let alert = UIAlertController(title: "mMotiv8", message: "An iCO device is not connected properly. Please reconnect the device and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    
    //MARK: OtherMethods
    
    func setupNavigationBar(){
        
        let barBtnNavigation : UIBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "navIcon"), style: .plain, target: navigationDrawerController(), action: #selector(NavigationDrawerController.toggleDrawer))        
        self.navigationItem.leftBarButtonItem = barBtnNavigation
        self.navigationItem.title = "Home"
    }
    
    func updateARN(){
        
        WebserviceManager.updateARN()
    }
    
    func getCurrentTestInfo(){
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        ActivityIndicator.showIndicator(onView: self.view, withDescription: "Retreiving test information.", Mode: .View)
        
        if Singleton.shared.isDemoUser{
         
            let now = Date()
            let formattedDate = DateFormatter.timeStampFormat().string(from: now)
            self.navigateToTestScreen(testID: formattedDate)
            
            ActivityIndicator.hide()

            return
        }
        
        WebserviceManager.getTestInfo { (success, error, data) in
            
            DispatchQueue.main.async {
             
                ActivityIndicator.hide()
                
                if(success && data != nil){
                    
                    let testAvailable = data!["testAvailable"] as? Bool
                    
                    if testAvailable! {
                        
                        if let ID = data!["testID"] as? String{
                            
                            self.navigateToTestScreen(testID: ID)
                        }
                    }
                    else
                    {
                        let alert = UIAlertController(title: "mMotiv8", message: "Breath test is not required at this time. Please come back later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
