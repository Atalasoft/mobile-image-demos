//
//  BaseSettingsViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 19/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class BaseSettingsViewController: UITableViewController {
    
    var settings : Settings = Settings()
    
    let CellsFontName = "HelveticaNeue"
    let CellsFontSize : CGFloat = 13
    
    override func viewWillAppear(animated: Bool) {
        settings.load()
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        settings.save()
        
        super.viewWillDisappear(animated)
    }
    
    
    func createSwitchWithTag(tag: Int, value: AnyObject) -> UISwitch{
        let newSwitch = UISwitch()
        newSwitch.on = value.boolValue
        newSwitch.tag = tag
        return newSwitch
    }
    
    func createTextFieldWithTag(tag: Int, frame: CGRect, placeholder: String, text:String) -> UITextField {
        let textField = UITextField()
        textField.tag = tag
        textField.font = UIFont(name: CellsFontName, size: CellsFontSize)
        textField.borderStyle = .None
        textField.autocorrectionType = .No
        textField.returnKeyType = .Done
        textField.placeholder = placeholder
        textField.textAlignment = .Right
        textField.clearButtonMode = .WhileEditing
        textField.text = text
        textField.frame = frame
        return textField
    }
    
    func createSegmentedControlWithTag(tag: Int, items: NSArray, selectedSegment: NSInteger) -> UISegmentedControl{
        let segmentControl = UISegmentedControl(items: items as [AnyObject])
        let dict : Dictionary<String, UIFont> = [NSFontAttributeName : UIFont(name: CellsFontName, size:15.0)!]
        segmentControl.setTitleTextAttributes(dict, forState: .Normal)
        segmentControl.selectedSegmentIndex = selectedSegment;
        segmentControl.tag = tag;
        return segmentControl;
    }
    
}
