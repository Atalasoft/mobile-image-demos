//
//  AboutViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 10/06/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: AboutCell! = tableView.dequeueReusableCellWithIdentifier(AboutViewController.cellIdentifier) as! AboutCell!

        cell.setupAboutData()

        cell.selectionStyle = .None
        
        return cell
    }

}
