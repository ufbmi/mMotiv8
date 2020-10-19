//
//  ActivityIndicator.swift
//  Template
//
//  Created by Pulkit Rohilla on 27/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

class ActivityIndicator {

    static var mainView, descriptionView, parentView : UIView!
    static var lblDescription : UILabel!
    static var activityIndicatorView : UIActivityIndicatorView!
    static var mode : ActivityIndicatorConstants.Mode!
    static var isShown = false
    
    class func showIndicator(onView view : UIView!,withDescription description : String!, Mode : ActivityIndicatorConstants.Mode){
        
        let isSameMode = (mode == Mode)
        let isSameParent = view != nil ? (parentView != nil && parentView == view) : false
        
        let addDescription = isShown && description != nil && isSameMode && isSameParent
        let updateDescription = isShown && lblDescription != nil && description != nil && isSameMode && isSameParent
        let removeDescription = isShown && description == nil && isSameMode && isSameParent
        
        DispatchQueue.main.async {
            
            if addDescription {
                
                self.addActivityIndicatorWithDescription(description: description)
            }
            else if updateDescription{
                
                lblDescription.text = description
            }
            else if removeDescription{
                
                self.addActivityIndicator()
            }
            else{
                
                mode = Mode
                
                if mainView != nil{
                    mainView.removeFromSuperview()
                }
                
                switch Mode {
                case .View:
                    
                    mainView = UIView.init(frame: view.bounds)
                    view.addSubview(mainView)
                    
                    break
                case .Window:
                    
                    let currentWindowScreen = UIApplication.shared.keyWindow
                    mainView = UIView.init(frame: (currentWindowScreen?.frame)!)
                    currentWindowScreen?.addSubview(mainView)
                    
                    break
                }
                
                mainView.alpha = 0
                mainView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                mainView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                activityIndicatorView = UIActivityIndicatorView.init(style: .whiteLarge)
                activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                activityIndicatorView.startAnimating()
                
                if description != nil {
                    
                    self.addActivityIndicatorWithDescription(description: description)
                }
                else
                {
                    self.addActivityIndicator()
                }
                
                UIView.animate(withDuration: GlobalConstants().animationDuration, animations: {
                    
                    mainView.alpha = 1
                    isShown = true
                })
            }
        }
    }
    
    class func hide(){
        
        DispatchQueue.main.async {
            
            if mainView != nil {
             
                mainView.removeFromSuperview()
            }
            
            mainView = nil
            descriptionView = nil
            parentView = nil
            activityIndicatorView = nil
            lblDescription = nil
            
            mode = ActivityIndicatorConstants.Mode(rawValue: 0)
            isShown = false
        }
        
    }

    class func addActivityIndicator(){
        
        if descriptionView != nil {
            
            descriptionView.removeFromSuperview()
            descriptionView = nil
        }

        lblDescription = nil
        
        mainView.addSubview(activityIndicatorView)
        mainView.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: mainView,
                                                       attribute: .centerX,
                                                       multiplier: 1,
                                                       constant: 0))
        mainView.addConstraint(NSLayoutConstraint.init(item: activityIndicatorView,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: mainView,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: 0))
    }
    
    class func addActivityIndicatorWithDescription(description : String){
        
        activityIndicatorView.removeFromSuperview()
        
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        descriptionView = UIView.init()
        descriptionView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        descriptionView.layer.cornerRadius = 6
        descriptionView.translatesAutoresizingMaskIntoConstraints = false

        lblDescription = UILabel.init()
        lblDescription.numberOfLines = 0
        lblDescription.text = description
        lblDescription.font = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: ActivityIndicatorConstants().labelSize)
        lblDescription.textColor = UIColor.white
        lblDescription.backgroundColor = UIColor.clear
        lblDescription.textAlignment = .center
        lblDescription.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionView.addSubview(activityIndicatorView)
        descriptionView.addSubview(lblDescription)
        
        let dictViews = ["activityIndicatorView" : activityIndicatorView,
                         "lblDescription" : lblDescription] as [String : Any]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[activityIndicatorView]-5-[lblDescription]-15-|",
                                                                 options: .alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: dictViews)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[lblDescription]-15-|",
                                                                 options: .alignAllCenterY,
                                                                 metrics: nil,
                                                                 views: dictViews)
        
        descriptionView.addConstraints(verticalConstraints)
        descriptionView.addConstraints(horizontalConstraints)
        
        mainView.addSubview(descriptionView)
        mainView.addConstraint(NSLayoutConstraint.init(item: descriptionView,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: mainView,
                                                       attribute: .centerX,
                                                       multiplier: 1,
                                                       constant: 0))
        mainView.addConstraint(NSLayoutConstraint.init(item: descriptionView,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: mainView,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: 0))
    }
    
    class func returnIndicatorView(view : UIView, description : String) -> UIView{
        
        let indicatorView = UIView.init(frame: view.frame)
        
        let indicator = UIActivityIndicatorView.init(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        
        let lblDesc = UILabel.init()
        lblDesc.numberOfLines = 0
        lblDesc.text = description
        lblDesc.font = UIFont.init(name: CustomFonts.FontName.Montserrat_Regular.rawValue, size: ActivityIndicatorConstants().smallLabelSize)
        lblDesc.textColor = UIColor.darkGray
        lblDesc.backgroundColor = UIColor.clear
        lblDesc.textAlignment = .center
        lblDesc.translatesAutoresizingMaskIntoConstraints = false
        
        indicatorView.addSubview(indicator)
        indicatorView.addSubview(lblDesc)
        
        let dictViews = ["activityIndicatorView" : indicator,
                         "lblDescription" : lblDesc] as [String : Any]
        
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[activityIndicatorView]-5-[lblDescription]",
                                                                 options: .alignAllCenterX,
                                                                 metrics: nil,
                                                                 views: dictViews)
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[lblDescription]-15-|",
                                                                   options: .alignAllCenterY,
                                                                   metrics: nil,
                                                                   views: dictViews)
        
        indicatorView.addConstraints(verticalConstraints)
        indicatorView.addConstraints(horizontalConstraints)
        
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicator,
                                                       attribute: .centerX,
                                                       relatedBy: .equal,
                                                       toItem: indicatorView,
                                                       attribute: .centerX,
                                                       multiplier: 1,
                                                       constant: 0))
        indicatorView.addConstraint(NSLayoutConstraint.init(item: indicator,
                                                       attribute: .centerY,
                                                       relatedBy: .equal,
                                                       toItem: indicatorView,
                                                       attribute: .centerY,
                                                       multiplier: 1,
                                                       constant: 0))
        return indicatorView
    }
}
