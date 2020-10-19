//
//  DrawerMenuCell.swift
//  Template
//
//  Created by Pulkit Rohilla on 06/07/17.
//  Copyright © 2017 PulkitRohilla. All rights reserved.
//

import UIKit

class DrawerMenuCell: UITableViewCell {

    @IBOutlet weak var lblIcon: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setupCell(menuOption title:String, icon:String){
        
        lblTitle.text = title
        lblIcon.text = icon
        
        let backView = UIView.init()
        backView.backgroundColor = UIColor.darkGray
        
        self.selectedBackgroundView = backView
    }
}
