//
//  BarcodesSettingsViewController.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 27/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class BarcodesSettingsViewController: BaseSettingsViewController {

    var switches : [UISwitch?]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switches = [UISwitch?](count: BarcodeTypes.SymbologiesCount, repeatedValue: nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BarcodeTypes.SymbologiesCount
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        assert(indexPath.section == 0)
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        var switchControl = switches?[indexPath.row]
        if switchControl == nil {
            switchControl = createSwitchWithTag(indexPath.row, value: BarcodeTypes.BarcodeSymbologyToString(kfxKUISymbology(UInt32(indexPath.row))))
            cell.accessoryView = switchControl
            switchControl?.addTarget(self, action: #selector(switchValueChanged), forControlEvents: .ValueChanged)
            cell.textLabel?.text = BarcodeTypes.BarcodeSymbologyToString(kfxKUISymbology(UInt32(indexPath.row)))
            
            switches?[indexPath.row] = switchControl
        }
        
        cell.accessoryView = switchControl
        switchControl?.on = settings.barcodes[indexPath.row]
        
        cell.selectionStyle = .None
        
        return cell
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        
        let index = sender.tag
        settings.barcodes[index] = !settings.barcodes[index]
    }
}
