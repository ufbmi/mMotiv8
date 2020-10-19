//
//  NavigationDrawerController.swift
//  NavigationDrawer-Swift
//
//  Created by Pulkit Rohilla on 26/05/17.
//  Copyright © 2018 PulkitRohilla. All rights reserved.
//

import UIKit

class NavigationDrawerController: UIViewController, DrawerMenuDelegate {
    
    let DragWithDrawer = true
    
    let slideAnimationDuration = -5.0
    let cornerRadius : CGFloat = 5.0

    let widthPercentage : CGFloat = 0.80;
    var drawerWidth : CGFloat = 0

    var presentedRow : Int = 0

    var frontViewController : UIViewController
    var menuController : DrawerMenuController
    var isDrawerOpen : Bool = false
    
    let transparentView : UIView
    var leadingConstraint : NSLayoutConstraint!
    var trailingConstraint : NSLayoutConstraint!
    var rightSwipeScreenEdgeGesture  : UIScreenEdgePanGestureRecognizer!
    
    init(frontViewController : UIViewController, menuController : UIViewController) {
        
        self.frontViewController = frontViewController
        self.menuController = menuController as! DrawerMenuController
        self.transparentView = UIView.init(frame: frontViewController.view.frame)
        self.transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.2);
        
        let screenWidth =  UIScreen.main.bounds.width;
        drawerWidth = screenWidth * widthPercentage;
        
        super.init(nibName: nil, bundle: nil)
        
        self.menuController.delegate = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if (isDrawerOpen) {
            
            closeDrawer()
            
            return
        }
        
        return
    }
    
    //Mark : Public Methods
    
    func showHomeScreen(){
        
        if let navigationController = self.frontViewController as? UINavigationController{
            
            let frontController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryBoardID.Home.rawValue)
            navigationController.setViewControllers([frontController], animated: true)
        }
        
        enableRightEdgeGesture()
        self.presentedRow = 0
    }
    
    func  enableRightEdgeGesture(){
    
        rightSwipeScreenEdgeGesture.isEnabled = true
    }
    
    func  disableRightEdgeGesture(){
        
        rightSwipeScreenEdgeGesture.isEnabled = false
    }
    
    func signOutHandler(alert: UIAlertAction!) {
        
        Singleton.shared.hasLoggedIn = false
        Singleton.shared.saveUserSelection(withKey: SingletonConstants().KVSavedData)
        
        KeyChainManager.removePassword(userName: Singleton.shared.userName)
        
        let loginViewController = UIApplication.shared.keyWindow!.rootViewController as! LoginViewController
        loginViewController.updateContentViewVisibility()
        
        self.dismiss(animated: true, completion: nil)
    }

    func signOut(){
        
        let message = "Are you sure you want to Sign Out?"
        
        let alert = UIAlertController(title: "mMotiv8", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:signOutHandler))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {action in
            self.menuController.setTableRowSelected(row: self.presentedRow)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    
    //Mark: - DrawerMenuDelegateMethods
    
    func didSelectMenuOptionAtIndex(indexPath: IndexPath) {
        
        if indexPath.row == presentedRow{
            
            toggleDrawer()
            
            return
        }
        
        closeDrawerOnCompletion { (complete) in
            
            if complete {
                
                switch indexPath.row {
                case 0:
                    
                    if let navigationController = self.frontViewController as? UINavigationController{
                        
                        navigationController.popToRootViewController(animated: false)
                    }
                    
                    self.presentedRow = indexPath.row
                    
                    break
                case 1:
                    
                    let progressController : ProgressViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: StoryBoardID.Progress.rawValue) as! ProgressViewController
                    
                    if let navigationController = self.frontViewController as? UINavigationController{
                        
                        navigationController.pushViewController(progressController, animated: false)
                    }
                    
                    self.presentedRow = indexPath.row
                    
                    break
                case 2:
                    
                    self.signOut()
                    
                    break
                default:
                    break
                }
            }
        }
    }
    
    //Mark: - OtherMethods
    
    func initView(){
        
        self.addChild(frontViewController)
        self.addChild(menuController)
        
        self.view.addSubview(frontViewController.view)
        self.view.addSubview(menuController.view)
        self.view.sendSubviewToBack(menuController.view)

        menuController.view.layer.cornerRadius = cornerRadius
        
        if DragWithDrawer {
            
            frontViewController.view.translatesAutoresizingMaskIntoConstraints = false
            frontViewController.view.autoresizingMask = [.flexibleRightMargin]

        }
        
        menuController.view.translatesAutoresizingMaskIntoConstraints = false
        menuController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.addInitialConstraints()
        self.addGestureRecognizers()
    }
    
    func addInitialConstraints(){
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|",
                                                                 options: .alignAllLeading,
                                                                 metrics: nil,
                                                                 views: ["view" : menuController.view])
        
        
        self.view.addConstraints(verticalConstraints)
        
        let widthConstraint = NSLayoutConstraint(
            item: menuController.view,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1.0,
            constant: drawerWidth)
        
        menuController.view.addConstraint(widthConstraint)
        
        self.leadingConstraint = NSLayoutConstraint(
            item: menuController.view,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self.view,
            attribute: .leading,
            multiplier: 1,
            constant: -drawerWidth)
        
        self.view.addConstraint(leadingConstraint)
        
        if DragWithDrawer {
            
            let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:[menuView]-0-[frontView]",
                                                                       options: [.alignAllTop, .alignAllBottom], //Important!! For Providing Height to FrontView
                metrics: nil,
                views: ["menuView" : menuController.view,
                        "frontView": frontViewController.view])

            self.view.addConstraints(horizontalConstraints)

            self.trailingConstraint = NSLayoutConstraint(
                item: frontViewController.view,
                attribute: .trailing,
                relatedBy: .equal,
                toItem: self.view,
                attribute: .trailing,
                multiplier: 1,
                constant: 0)
            
            self.view.addConstraint(trailingConstraint)
        }
    }
    
    func addGestureRecognizers(){
        
        let leftSwipeGesture = UISwipeGestureRecognizer.init(target: self, action: #selector(closeDrawer))
        leftSwipeGesture.direction = .left
        leftSwipeGesture.numberOfTouchesRequired = 1
        
        menuController.view.addGestureRecognizer(leftSwipeGesture)
        
        rightSwipeScreenEdgeGesture = UIScreenEdgePanGestureRecognizer.init(target: self, action: #selector(screenEdgePan(sender:)))
        rightSwipeScreenEdgeGesture.edges = [.left]
        
        self.view.addGestureRecognizer(rightSwipeScreenEdgeGesture)
    }
    
    @objc func screenEdgePan(sender: UIScreenEdgePanGestureRecognizer){
        
        if sender.state == .began {
            
            openDrawer()
        }
    }
    
    @objc func toggleDrawer(){
        
        if !isDrawerOpen {
            
            openDrawer()
        }
        else if isDrawerOpen && menuController.view.frame.origin.x == 0
        {
            closeDrawer()
        }
    }
    
    func openDrawer(){
        
        self.view.bringSubviewToFront(self.menuController.view)
        self.leadingConstraint.constant = 0
        
        if DragWithDrawer {
            self.trailingConstraint.constant = drawerWidth
        }
        
        UIView.animate(withDuration: slideAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            self.frontViewController.view.addSubview(self.transparentView)
            
        }, completion: { (Bool) in
            
            self.isDrawerOpen = true
        })
    }
    
    @objc func closeDrawer(){
        
        closeDrawerOnCompletion(completion: nil)
    }
    
    func closeDrawerOnCompletion(completion : ((Bool)->Void)?){
        
        self.leadingConstraint.constant = -drawerWidth
        
        if DragWithDrawer {
            self.trailingConstraint.constant = 0
        }
        
        UIView.animate(withDuration: slideAnimationDuration, delay: 0, options: .curveEaseInOut, animations: {
            
            self.view.layoutIfNeeded()
            self.transparentView.removeFromSuperview()
            
        }, completion: { (Bool) in
            
            self.isDrawerOpen = false
            self.view.sendSubviewToBack(self.menuController.view)
            
            if completion != nil{
                
                completion!(true)
            }
        })
    }
}

extension UIViewController{
    
    func navigationDrawerController() -> NavigationDrawerController{
        
        var parentViewController = self.parent!
        
        if parentViewController.isKind(of: NavigationDrawerController.self) {
            
            return parentViewController as! NavigationDrawerController
        }
        else
        {
            repeat{
                
                parentViewController = parentViewController.parent!
            }
                while !parentViewController.isKind(of: NavigationDrawerController.self)
            
            return parentViewController as! NavigationDrawerController
        }
    }
}

