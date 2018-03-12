//
//  AboutViewController.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 27/05/16.
//  Copyright © 2016-2017 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {
    
    static let cellIdentifier = "AboutCell"
    
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AboutCell! = tableView.dequeueReusableCell(withIdentifier: AboutViewController.cellIdentifier) as! AboutCell!
        
        cell.setupAboutData()
        
        cell.selectionStyle = .none
        
        return cell
    }
    
}
