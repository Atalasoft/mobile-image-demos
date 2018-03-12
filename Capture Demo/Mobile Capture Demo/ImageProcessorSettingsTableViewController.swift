//
//  ImageProcessorSettingsTableViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016-2017 Atalasoft. All rights reserved.
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 5
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                useDefaultSettingsSwitch = createSwitchWithTag(tag: indexPath.row, value: settings.UseDefaultSettings as AnyObject)
                cell.accessoryView = useDefaultSettingsSwitch
                useDefaultSettingsSwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
                cell.textLabel?.text = "Use Default Settings:"
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                modeSegment = createSegmentedControlWithTag(tag: 0, items: ["BW", "Gray", "Color"], selectedSegment: settings.Mode)
                modeSegment?.addTarget(self, action:#selector(captureExperienceSwitchAction), for:.valueChanged)
                cell.accessoryView = modeSegment;
                cell.textLabel?.text = "Mode:"
                
            case 1:
                autoCropSwitch = createSwitchWithTag(tag: indexPath.row, value: settings.AutoCrop as AnyObject)
                cell.accessoryView = autoCropSwitch
                autoCropSwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
                cell.textLabel?.text = "Auto Crop:"
                
            case 2:
                autoRotateSwitch = createSwitchWithTag(tag: indexPath.row, value: settings.AutoRotate as AnyObject)
                cell.accessoryView = autoRotateSwitch
                autoRotateSwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
                cell.textLabel?.text = "Auto Rotate:"
                
            case 3:
                deskewSwitch = createSwitchWithTag(tag: indexPath.row, value: settings.Deskew as AnyObject)
                cell.accessoryView = deskewSwitch
                deskewSwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
                cell.textLabel?.text = "Deskew:"
                
            case 4:
                scaleSegment = createSegmentedControlWithTag(tag: 0, items: ["No", "200", "300", "400"], selectedSegment: settings.Scale)
                scaleSegment?.addTarget(self, action:#selector(captureExperienceSwitchAction), for:.valueChanged)
                cell.accessoryView = scaleSegment;
                cell.textLabel?.text = "Scale (dpi):"
                
            default:
                assert(false)
            }
        }
        
        cell.selectionStyle = .none
        
        let enabledCell = !settings.UseDefaultSettings || (indexPath.section == 0 && indexPath.row == 0)
        cell.isUserInteractionEnabled = enabledCell
        cell.textLabel?.isEnabled = enabledCell
        cell.accessoryView?.isUserInteractionEnabled = enabledCell
        
        return cell!
    }

    // MARK: - Handlers
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        
        if sender == useDefaultSettingsSwitch {
            settings.UseDefaultSettings = sender.isOn
            tableView.reloadData()
        } else if sender == autoCropSwitch {
            settings.AutoCrop = sender.isOn
        } else if sender == autoRotateSwitch {
            settings.AutoRotate = sender.isOn
        } else if sender == deskewSwitch {
            settings.Deskew = sender.isOn
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
