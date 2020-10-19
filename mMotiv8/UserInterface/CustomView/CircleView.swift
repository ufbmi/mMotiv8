//
//  CircleView.swift
//  mMotiv8
//
//  Created by UF on 25/01/19.
//  Copyright © 2019 UF. All rights reserved.
//

import UIKit

class CircleView: UIView {

    init(center : CGPoint, color : UIColor) {
    
        let diameter : CGFloat = 15
        let x = center.x - diameter/2
        let y = center.y - diameter/2
        let frame = CGRect.init(x: x, y: y, width: diameter, height: diameter)
        
        super.init(frame: frame)
        
        self.backgroundColor = color
        self.borderColor = UIColor.white
        self.borderWidth = 2
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    class func initView(center : CGPoint, color : UIColor) -> UIView{
//        
//        let diameter : CGFloat = 15
//        let x = center.x - diameter/2
//        let y = center.y - diameter/2
//        let frame = CGRect.init(x: x, y: y, width: diameter, height: diameter)
//        let circleView = UIView.init(frame: frame)
//       
//        circleView.asCircle()
//        
//        return circleView
//    }
}
