//
//  LicenseAgreementViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 30/06/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class LicenseAgreementViewController: UITableViewController {

    static let cellIdentifier = "LicenseCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: LicenseAgreementCell! = tableView.dequeueReusableCellWithIdentifier(LicenseAgreementViewController.cellIdentifier) as! LicenseAgreementCell!
        
        cell.setupLicenseData()
        
        cell.selectionStyle = .None
        
        return cell
    }
    
}
