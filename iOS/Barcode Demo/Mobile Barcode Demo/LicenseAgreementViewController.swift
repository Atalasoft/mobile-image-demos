//
//  LicenseAgreementViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 30/06/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class LicenseAgreementViewController: UITableViewController {

    static let cellIdentifier = "LicenseCell"
    var cellHeight : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 100.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if cellHeight == 0 {
            let cell : LicenseAgreementCell = LicenseAgreementCell()
            cell.license = UITextView()
            cell.setupLicenseData()
            cellHeight = cell.license.contentSize.height + 30
        }
        return cellHeight
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LicenseAgreementCell! = tableView.dequeueReusableCell(withIdentifier: LicenseAgreementViewController.cellIdentifier) as! LicenseAgreementCell!
        
        cell.setupLicenseData()
        
        cell.selectionStyle = .none
        
        return cell
    }
    
}
