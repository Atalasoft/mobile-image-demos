//
//  SettingsTableViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    static let cellIdentifier = "SettingsCellIdentifier"
    static let SegueBarcodesSettingsViewController = "BarcodesSettingsViewController"
    static let SegueAboutViewController = "AboutViewController"
    static let SegueLicenseAgreementViewController = "LicenseAgreementViewController"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(SettingsTableViewController.cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }

        if indexPath.row == 0
        {
            cell.textLabel?.text = "Symbologies"
        } else if indexPath.row == 1
        {
            cell.textLabel?.text = "About"
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "License Agreement"
        }
        
        cell.accessoryType = .DisclosureIndicator

        return cell!;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var segueName : String = ""
        switch indexPath.row
        {
        case 0:
            segueName = SettingsTableViewController.SegueBarcodesSettingsViewController
            break
            
        case 1:
            segueName = SettingsTableViewController.SegueAboutViewController
            break
            
        case 2:
            segueName = SettingsTableViewController.SegueLicenseAgreementViewController
            break
            
        default:
            assert(false)
        }
        
        performSegueWithIdentifier(segueName, sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
