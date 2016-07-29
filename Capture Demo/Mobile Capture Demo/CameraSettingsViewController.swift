//
//  CameraSettingsViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class CameraSettingsViewController: BaseSettingsViewController, UITextFieldDelegate {
    
    var showGallerySwitch : UISwitch?
    var stabilityDelayField : UITextField?
    var pitchThresholdField : UITextField?
    var rollThresholdField : UITextField?
    var manualCaptureTimeField : UITextField?
    var autoTorchSwitch : UISwitch?
    
    var selectedTextField : UITextField?

    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        assert(indexPath.section == 0)
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        switch indexPath.row {
        case 0:
            showGallerySwitch = createSwitchWithTag(indexPath.row, value: settings.CameraShowGallery)
            cell.accessoryView = showGallerySwitch
            showGallerySwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
            cell.textLabel?.text = "Show Gallery:"
            break
            
        case 1:
            stabilityDelayField = createTextFieldWithTag(0, frame: CGRectMake(0, 0, 50, 25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.StabilityDelay))
            stabilityDelayField?.keyboardType = .NumbersAndPunctuation
            stabilityDelayField?.delegate = self
            cell.accessoryView = stabilityDelayField
            cell.textLabel?.text = "Stability Delay (0 - 100):"
            break
            
        case 2:
            pitchThresholdField = createTextFieldWithTag(0, frame: CGRectMake(0, 0, 50, 25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.PitchThreshold))
            pitchThresholdField?.keyboardType = .NumbersAndPunctuation
            pitchThresholdField?.delegate = self
            cell.accessoryView = pitchThresholdField
            cell.textLabel?.text = "Pitch Threshold (0 - 45):"
            break
            
        case 3:
            rollThresholdField = createTextFieldWithTag(0, frame: CGRectMake(0, 0, 50, 25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.RollThreshold))
            rollThresholdField?.keyboardType = .NumbersAndPunctuation
            rollThresholdField?.delegate = self
            cell.accessoryView = rollThresholdField
            cell.textLabel?.text = "Roll Threshold (0 - 45):"
            break
            
        case 4:
            manualCaptureTimeField = createTextFieldWithTag(0, frame: CGRectMake(0, 0, 50, 25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.ManualCaptureTime))
            manualCaptureTimeField?.keyboardType = .NumbersAndPunctuation
            manualCaptureTimeField?.delegate = self
            cell.accessoryView = manualCaptureTimeField
            cell.textLabel?.text = "Manual Capture Time:"
            break
            
        case 5:
            autoTorchSwitch = createSwitchWithTag(indexPath.row, value: settings.AutoTorch)
            cell.accessoryView = autoTorchSwitch
            autoTorchSwitch?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
            cell.textLabel?.text = "Auto Torch:"
            break
            
        default:
            assert(indexPath.row < Settings.CameraSettingsCount)
        }
        
        cell.selectionStyle = .None
        
        return cell
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return captureDevice.hasFlash && captureDevice.hasTorch ? Settings.CameraSettingsCount : Settings.CameraSettingsCount - 1
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        
        if sender == showGallerySwitch {
            settings.CameraShowGallery = sender.on
        } else if sender == autoTorchSwitch {
            settings.AutoTorch = sender.on
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        var rect = CGRectZero
        
        if textField == stabilityDelayField {
            rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
        } else if textField == pitchThresholdField {
            rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))
        } else if textField == rollThresholdField {
            rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))
        } else if textField == manualCaptureTimeField {
            rect = tableView.rectForRowAtIndexPath(NSIndexPath(forRow: 4, inSection: 0))
        }
        
        tableView.setContentOffset(CGPointMake(0, rect.origin.y), animated: true)
    }
    
    func processTextFieldData(textField: UITextField) {
        let numbersOnly = NSCharacterSet.decimalDigitCharacterSet()
        let characterSetFromTextField = NSCharacterSet(charactersInString: textField.text!)
        if !numbersOnly.isSupersetOfSet(characterSetFromTextField) {
            return
        }

        if textField.isEqual(stabilityDelayField)
        {
            let intValue = Int(textField.text!)
            if intValue < 0 || intValue > 100
            {
                textField.text = String.localizedStringWithFormat("%d", 100)
            }
            
            settings.StabilityDelay = Int32(textField.text!)!
            
        } else if textField.isEqual(pitchThresholdField)
        {
            let intValue = Int(textField.text!)
            if intValue < 0 || intValue > 45
            {
                textField.text = String.localizedStringWithFormat("%d", 45)
            }
            
            settings.PitchThreshold = Int32(textField.text!)!
            
        } else if textField.isEqual(rollThresholdField)
        {
            let intValue = Int(textField.text!)
            if intValue < 0 || intValue > 45 {
                textField.text = String.localizedStringWithFormat("%d", 45)
            }
            settings.RollThreshold = Int32(textField.text!)!
            
        } else if textField.isEqual(manualCaptureTimeField)
        {
            settings.ManualCaptureTime = Int32(textField.text!)!
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        processTextFieldData(textField)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        tableView.setContentOffset(CGPointMake(0, 0), animated:true)
        
        processTextFieldData(textField)
        
        return true
    }
}
