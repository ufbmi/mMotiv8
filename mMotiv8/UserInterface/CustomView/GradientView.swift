//
//  GradientView.swift
//  mMotiv8
//
//  Created by UF on 15/02/19.
//  Copyright © 2019 UF. All rights reserved.
//

import UIKit

class GradientView: UIView {

    @IBInspectable var firstColor : UIColor = UIColor.white
    @IBInspectable var secondColor : UIColor = UIColor.customLightBlue

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
    }

}
