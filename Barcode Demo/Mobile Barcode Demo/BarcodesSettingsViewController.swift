//
//  BarcodesSettingsViewController.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 27/05/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class BarcodesSettingsViewController: BaseSettingsViewController {

    var switches : [UISwitch?]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switches = [UISwitch?](repeating: nil, count: BarcodeTypes.SymbologiesCount)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BarcodeTypes.SymbologiesCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: SettingsTableViewController.cellIdentifier)
        }
        
        assert(indexPath.section == 0)
        
        cell.textLabel?.font = UIFont(name:CellsFontName, size:15)
        
        var switchControl = switches?[indexPath.row]
        if switchControl == nil {
            switchControl = createSwitchWithTag(tag: indexPath.row, value: BarcodeTypes.BarcodeSymbologyToString(symbology: kfxKUISymbology(UInt32(indexPath.row))) as AnyObject)
            cell.accessoryView = switchControl
            switchControl?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            cell.textLabel?.text = BarcodeTypes.BarcodeSymbologyToString(symbology: kfxKUISymbology(UInt32(indexPath.row)))
            
            switches?[indexPath.row] = switchControl
        }
        
        cell.accessoryView = switchControl
        switchControl?.isOn = settings.barcodes[indexPath.row]
        
        cell.selectionStyle = .none
        
        return cell
    }

    @IBAction func switchValueChanged(sender: UISwitch) {
        
        let index = sender.tag
        settings.barcodes[index] = !settings.barcodes[index]
    }
}
