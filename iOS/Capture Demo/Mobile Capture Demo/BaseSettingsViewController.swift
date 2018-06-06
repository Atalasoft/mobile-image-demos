//
//  BaseSettingsViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 19/05/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
//

import UIKit

class BaseSettingsViewController: UITableViewController {
    
    var settings : Settings = Settings()
    
    let CellsFontName = "HelveticaNeue"
    let CellsFontSize : CGFloat = 13
    
    override func viewWillAppear(_ animated: Bool) {
        settings.load()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        settings.save()
        
        super.viewWillDisappear(animated)
    }
    
    
    func createSwitchWithTag(tag: Int, value: AnyObject) -> UISwitch{
        let newSwitch = UISwitch()
        newSwitch.isOn = value.boolValue
        newSwitch.tag = tag
        return newSwitch
    }
    
    func createTextFieldWithTag(tag: Int, frame: CGRect, placeholder: String, text:String) -> UITextField {
        let textField = UITextField()
        textField.tag = tag
        textField.font = UIFont(name: CellsFontName, size: CellsFontSize)
        textField.borderStyle = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.placeholder = placeholder
        textField.textAlignment = .right
        textField.clearButtonMode = .whileEditing
        textField.text = text
        textField.frame = frame
        return textField
    }
    
    func createSegmentedControlWithTag(tag: Int, items: NSArray, selectedSegment: NSInteger) -> UISegmentedControl{
        let segmentControl = UISegmentedControl(items: items as [AnyObject])
        let dict : Dictionary<String, UIFont> = [NSAttributedStringKey.font.rawValue : UIFont(name: CellsFontName, size:15.0)!]
        segmentControl.setTitleTextAttributes(dict, for: .normal)
        segmentControl.selectedSegmentIndex = selectedSegment;
        segmentControl.tag = tag;
        return segmentControl;
    }
    
}
