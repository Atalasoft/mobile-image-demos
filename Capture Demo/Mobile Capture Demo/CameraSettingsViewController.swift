//
//  CameraSettingsViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
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

    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        assert(indexPath.section == 0)
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        switch indexPath.row {
        case 0:
            showGallerySwitch = createSwitchWithTag(tag: indexPath.row, value: settings.CameraShowGallery as AnyObject)
            cell.accessoryView = showGallerySwitch
            showGallerySwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            cell.textLabel?.text = "Show Gallery:"
            break
            
        case 1:
            stabilityDelayField = createTextFieldWithTag(tag: 0, frame: CGRect(x:0, y:0, width:50, height:25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.StabilityDelay))
            stabilityDelayField?.keyboardType = .numbersAndPunctuation
            stabilityDelayField?.delegate = self
            cell.accessoryView = stabilityDelayField
            cell.textLabel?.text = "Stability Delay (0 - 100):"
            break
            
        case 2:
            pitchThresholdField = createTextFieldWithTag(tag: 0, frame: CGRect(x:0, y:0, width:50, height:25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.PitchThreshold))
            pitchThresholdField?.keyboardType = .numbersAndPunctuation
            pitchThresholdField?.delegate = self
            cell.accessoryView = pitchThresholdField
            cell.textLabel?.text = "Pitch Threshold (0 - 45):"
            break
            
        case 3:
            rollThresholdField = createTextFieldWithTag(tag: 0, frame: CGRect(x:0, y:0, width:50, height:25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.RollThreshold))
            rollThresholdField?.keyboardType = .numbersAndPunctuation
            rollThresholdField?.delegate = self
            cell.accessoryView = rollThresholdField
            cell.textLabel?.text = "Roll Threshold (0 - 45):"
            break
            
        case 4:
            manualCaptureTimeField = createTextFieldWithTag(tag: 0, frame: CGRect(x:0, y:0, width:50, height:25), placeholder: "", text: String.localizedStringWithFormat("%d", settings.ManualCaptureTime))
            manualCaptureTimeField?.keyboardType = .numbersAndPunctuation
            manualCaptureTimeField?.delegate = self
            cell.accessoryView = manualCaptureTimeField
            cell.textLabel?.text = "Manual Capture Time:"
            break
            
        case 5:
            autoTorchSwitch = createSwitchWithTag(tag: indexPath.row, value: settings.AutoTorch as AnyObject)
            cell.accessoryView = autoTorchSwitch
            autoTorchSwitch?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            cell.textLabel?.text = "Auto Torch:"
            break
            
        default:
            assert(indexPath.row < Settings.CameraSettingsCount)
        }
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return captureDevice!.hasFlash && captureDevice!.hasTorch ? Settings.CameraSettingsCount : Settings.CameraSettingsCount - 1
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        
        if sender == showGallerySwitch {
            settings.CameraShowGallery = sender.isOn
        } else if sender == autoTorchSwitch {
            settings.AutoTorch = sender.isOn
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        selectedTextField = textField
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        var rect = CGRect()
        
        if textField == stabilityDelayField {
            rect = tableView.rectForRow(at: NSIndexPath(row: 1, section: 0) as IndexPath)
        } else if textField == pitchThresholdField {
            rect = tableView.rectForRow(at: NSIndexPath(row: 2, section: 0) as IndexPath)
        } else if textField == rollThresholdField {
            rect = tableView.rectForRow(at: NSIndexPath(row: 3, section: 0) as IndexPath)
        } else if textField == manualCaptureTimeField {
            rect = tableView.rectForRow(at: NSIndexPath(row: 4, section: 0) as IndexPath)
        }
        
        tableView.setContentOffset(CGPoint(x:0, y:rect.origin.y), animated: true)
    }
    
    func processTextFieldData(textField: UITextField) {
        let numbersOnly = NSCharacterSet.decimalDigits
        let characterSetFromTextField = NSCharacterSet(charactersIn: textField.text!)
        if !numbersOnly.isSuperset(of: characterSetFromTextField as CharacterSet) {
            return
        }

        if textField.isEqual(stabilityDelayField)
        {
            let intValue = Int(textField.text!)
            if intValue! < 0 || intValue! > 100
            {
                textField.text = String.localizedStringWithFormat("%d", 100)
            }
            
            settings.StabilityDelay = Int32(textField.text!)!
            
        } else if textField.isEqual(pitchThresholdField)
        {
            let intValue = Int(textField.text!)
            if intValue! < 0 || intValue! > 45
            {
                textField.text = String.localizedStringWithFormat("%d", 45)
            }
            
            settings.PitchThreshold = Int32(textField.text!)!
            
        } else if textField.isEqual(rollThresholdField)
        {
            let intValue = Int(textField.text!)
            if intValue! < 0 || intValue! > 45 {
                textField.text = String.localizedStringWithFormat("%d", 45)
            }
            settings.RollThreshold = Int32(textField.text!)!
            
        } else if textField.isEqual(manualCaptureTimeField)
        {
            settings.ManualCaptureTime = Int32(textField.text!)!
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        processTextFieldData(textField: textField)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        tableView.setContentOffset(CGPoint(x:0, y:0), animated:true)
        
        processTextFieldData(textField: textField)
        
        return true
    }
}
