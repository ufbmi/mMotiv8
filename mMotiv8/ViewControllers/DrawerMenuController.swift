//
//  DrawerMenuController.swift
//  NavigationDrawer-Swift
//
//  Created by Pulkit Rohilla on 26/05/17.
//  Copyright © 2018 PulkitRohilla. All rights reserved.
//

import UIKit

protocol DrawerMenuDelegate : NSObjectProtocol {
    
    func didSelectMenuOptionAtIndex(indexPath: IndexPath)
}

class DrawerMenuController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var titleItem: UINavigationItem!
    @IBOutlet weak var tblView: UITableView!
    
    var delegate : DrawerMenuDelegate!
    
    let titleArray = ["Home", "Progress", "Sign Out"]
    let iconArray = [FontAwesomeIcon.Home.rawValue, FontAwesomeIcon.Chart.rawValue, FontAwesomeIcon.Logout.rawValue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let userName = Singleton.shared.userName        
        titleItem.title = (userName.capitalized)
        
        setTableRowSelected(row: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PublicMethods
    
    func setTableRowSelected(row : Int){
        
        tblView.selectRow(at: IndexPath.init(row: row, section: 0), animated: false, scrollPosition: .none)
    }
    
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return titleArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: DrawerMenuConstants().CellIdentifier, for: indexPath) as! DrawerMenuCell
        
        cell.lblTitle.text = titleArray[indexPath.row]
        cell.lblIcon.text = iconArray[indexPath.row]
    
        let selectedColor = UIColor.customLightBlue

        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = selectedColor

        cell.selectedBackgroundView = selectedBackgroundView

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return DrawerMenuConstants().CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        delegate.didSelectMenuOptionAtIndex(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let dummyView = UIView.init()
        return dummyView
    }
}
