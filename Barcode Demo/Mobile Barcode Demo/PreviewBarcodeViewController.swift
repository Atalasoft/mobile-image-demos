//
//  PreviewImageViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 10/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit
import MessageUI

class PreviewBarcodeViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    static let barcodeImageCellIdentifier = "BarcodeImageCellIdentifier"
    static let barcodeInfoCellIdentifier = "BarcodeInfoCell"
    
    var buttonsView : UIView!
    @IBOutlet var retakeButton : UIButton!
    @IBOutlet var sendMailButton : UIButton!
    
    var barcodeInfo : BarcodeInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        retakeButton = UIButton(frame: CGRectMake(0, 5, 60, 60))
        sendMailButton = UIButton(frame: CGRectMake(0, 5, 60, 60))
            
        retakeButton.ConfigureButton(image: "camera_button_normal.png")
        retakeButton.addTarget(self, action: #selector(onRetakePicture), forControlEvents: .TouchUpInside)
        sendMailButton.ConfigureButton(image: "email.png")
        sendMailButton.addTarget(self, action: #selector(onSendImageByMail), forControlEvents: .TouchUpInside)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(onClosePreview))
        navigationItem.rightBarButtonItem = closeButton
        
        sendMailButton.enabled = MFMailComposeViewController.canSendMail()
        
        navigationItem.setHidesBackButton(true, animated: true);
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.separatorStyle = .None

        tableView.estimatedRowHeight = 70.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onSendImageByMail() {

        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        mailComposeVC.setSubject("Email Subject")
        
        var mailBody: String = ""
        
        if let bcInfo = barcodeInfo {
            var barcodeValue = bcInfo.barcode.value
            if bcInfo.barcode.dataFormat == KEDBarcodeDataFormats.init(2) {
                let data = NSData(base64EncodedString: bcInfo.barcode.value, options: NSDataBase64DecodingOptions(rawValue: 0))
                barcodeValue = String(data: data!, encoding: NSUTF8StringEncoding)!
            }
            
            mailBody =  "<html>" +
                            "<body>" +
                                "<p>Barcode information:</p>" +
                                "<p>type: \(BarcodeTypes.BarcodeTypeToString(bcInfo.barcode.type))</p>" +
                                "<p>value: \(barcodeValue)</p>" +
                            "</body>" +
                        "</html>"
        } else {
            mailBody = String(format: "<html><body><p>Barcode information is unavailable.</p></body></html>")
        }
        
        mailComposeVC.setMessageBody(mailBody, isHTML: true)
        
        self.presentViewController(mailComposeVC, animated: true, completion: nil)
        
    }
    
    @IBAction func onRetakePicture() {
        navigationController?.popViewControllerAnimated(false)
    }
    
    @IBAction func onClosePreview() {
        let confirmAlert = UIAlertController(title: "", message: "Are you sure to close?", preferredStyle: .Alert)
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.navigationController?.popToRootViewControllerAnimated(true)
        }))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch (result) {
            case MFMailComposeResultSent:
                print("Email sent")
                break
            
            default:
                print("\(result)")
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func createPreviewCell(tableView: UITableView) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(PreviewBarcodeViewController.barcodeImageCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: PreviewBarcodeViewController.barcodeImageCellIdentifier)
        }
        
        var image : UIImage? = nil
        if let bcInfo = barcodeInfo where bcInfo.image != nil {
            image = bcInfo.image?.getImageBitmap()
        }
        
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .ScaleAspectFill
        imageView.frame = CGRectMake(0,0,tableView.bounds.width, tableView.frame.height)
        cell.addSubview(imageView)
        var frame = cell.bounds
        frame.size.height = tableView.frame.height
        cell.bounds = frame
        
        return cell
    }
    
    func createBarcodeInfoCell(tableView: UITableView) -> UITableViewCell {
        let bcCell: BarcodeInfoCell! = tableView.dequeueReusableCellWithIdentifier(PreviewBarcodeViewController.barcodeInfoCellIdentifier) as! BarcodeInfoCell!
        
        if let bcInfo = barcodeInfo {
            bcCell.setupBarcodeInfoCell(bcInfo)
        }
        
        return bcCell
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        var cell: UITableViewCell!
        
        if indexPath.row == 0
        {
            cell = createBarcodeInfoCell(tableView)
        } else {
            cell = createPreviewCell(tableView)
        }
    
        cell.accessoryType = .None
        cell.selectionStyle = .None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return -1
        }
        
        return tableView.frame.height
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 70
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if buttonsView == nil {
                buttonsView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 70))
                
                var retakeButtonFrame = retakeButton.frame
                retakeButtonFrame.origin.x = buttonsView.frame.width / 4 - retakeButtonFrame.width / 2
                retakeButton.frame = retakeButtonFrame
                
                var sendMailButtonFrame = sendMailButton.frame
                sendMailButtonFrame.origin.x = buttonsView.frame.width / 4 * 3 - sendMailButtonFrame.width / 2
                sendMailButton.frame = sendMailButtonFrame
                
                buttonsView.addSubview(retakeButton)
                buttonsView.addSubview(sendMailButton)
            }

            return buttonsView
        }
        
        return nil
    }
}
