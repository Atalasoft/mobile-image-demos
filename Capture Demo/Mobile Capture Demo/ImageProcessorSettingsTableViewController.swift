//
//  ImageProcessorSettingsTableViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class ImageProcessorSettingsTableViewController: BaseSettingsViewController {
    
    var useDefaultSettingsSwitch : UISwitch?
    
    var modeSegment : UISegmentedControl?
    var autoCropSwitch : UISwitch?
    var autoRotateSwitch : UISwitch?
    var deskewSwitch : UISwitch?
    var scaleSegment : UISegmentedControl?

    var selectedTextField : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 5
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                useDefaultSettingsSwitch = createSwitchWithTag(indexPath.row, value: settings.UseDefaultSettings)
                cell.accessoryView = useDefaultSettingsSwitch
                useDefaultSettingsSwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
                cell.textLabel?.text = "Use Default Settings:"
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                modeSegment = createSegmentedControlWithTag(0, items: ["BW", "Gray", "Color"], selectedSegment: settings.Mode)
                modeSegment?.addTarget(self, action:#selector(captureExperienceSwitchAction), forControlEvents:.ValueChanged)
                cell.accessoryView = modeSegment;
                cell.textLabel?.text = "Mode:"
                
            case 1:
                autoCropSwitch = createSwitchWithTag(indexPath.row, value: settings.AutoCrop)
                cell.accessoryView = autoCropSwitch
                autoCropSwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
                cell.textLabel?.text = "Auto Crop:"
                
            case 2:
                autoRotateSwitch = createSwitchWithTag(indexPath.row, value: settings.AutoRotate)
                cell.accessoryView = autoRotateSwitch
                autoRotateSwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
                cell.textLabel?.text = "Auto Rotate:"
                
            case 3:
                deskewSwitch = createSwitchWithTag(indexPath.row, value: settings.Deskew)
                cell.accessoryView = deskewSwitch
                deskewSwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
                cell.textLabel?.text = "Deskew:"
                
            case 4:
                scaleSegment = createSegmentedControlWithTag(0, items: ["No", "200", "300", "400"], selectedSegment: settings.Scale)
                scaleSegment?.addTarget(self, action:#selector(captureExperienceSwitchAction), forControlEvents:.ValueChanged)
                cell.accessoryView = scaleSegment;
                cell.textLabel?.text = "Scale (dpi):"
                
            default:
                assert(false)
            }
        }
        
        cell.selectionStyle = .None
        
        let enabledCell = !settings.UseDefaultSettings || (indexPath.section == 0 && indexPath.row == 0)
        cell.userInteractionEnabled = enabledCell
        cell.textLabel?.enabled = enabledCell
        cell.accessoryView?.userInteractionEnabled = enabledCell
        
        return cell!
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.5
        }
        
        return 25
    }
    
    
    // MARK: - Handlers
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        
        if sender == useDefaultSettingsSwitch {
            settings.UseDefaultSettings = sender.on
            tableView.reloadData()
        } else if sender == autoCropSwitch {
            settings.AutoCrop = sender.on
        } else if sender == autoRotateSwitch {
            settings.AutoRotate = sender.on
        } else if sender == deskewSwitch {
            settings.Deskew = sender.on
        }
    }
    
    @IBAction func captureExperienceSwitchAction(sender:UISegmentedControl) {
        
        if sender == modeSegment {
            settings.Mode = sender.selectedSegmentIndex
        } else if sender == scaleSegment {
            settings.Scale = sender.selectedSegmentIndex
        }
        
        tableView.reloadData()
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
}
