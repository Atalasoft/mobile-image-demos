//
//  PreviewImageViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 10/05/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
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

        retakeButton = UIButton(frame: CGRect(x:0, y:5, width:60, height:60))
        sendMailButton = UIButton(frame: CGRect(x:0, y:5, width:60, height:60))
            
        retakeButton.ConfigureButton(image: "camera_button_normal.png")
        retakeButton.addTarget(self, action: #selector(onRetakePicture), for: .touchUpInside)
        sendMailButton.ConfigureButton(image: "email.png")
        sendMailButton.addTarget(self, action: #selector(onSendImageByMail), for: .touchUpInside)
        
        let closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(onClosePreview))
        navigationItem.rightBarButtonItem = closeButton
        
        sendMailButton.isEnabled = MFMailComposeViewController.canSendMail()
        
        navigationItem.setHidesBackButton(true, animated: true);
        
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.separatorStyle = .none

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
                let data = NSData(base64Encoded: bcInfo.barcode.value, options: NSData.Base64DecodingOptions(rawValue: 0))
                barcodeValue = String(data: data! as Data, encoding: String.Encoding.utf8)!
            }
            
            mailBody =  "<html>" +
                            "<body>" +
                                "<p>Barcode information:</p>" +
                "<p>type: \(BarcodeTypes.BarcodeTypeToString(barcodeType: bcInfo.barcode.type))</p>" +
                "<p>value: \(String(describing: barcodeValue))</p>" +
                            "</body>" +
                        "</html>"
        } else {
            mailBody = String(format: "<html><body><p>Barcode information is unavailable.</p></body></html>")
        }
        
        mailComposeVC.setMessageBody(mailBody, isHTML: true)
        
        self.present(mailComposeVC, animated: true, completion: nil)
        
    }
    
    @IBAction func onRetakePicture() {
        navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onClosePreview() {
        let confirmAlert = UIAlertController(title: "", message: "Are you sure to close?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
        }))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func createPreviewCell(tableView: UITableView) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: PreviewBarcodeViewController.barcodeImageCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: PreviewBarcodeViewController.barcodeImageCellIdentifier)
        }
        
        var image : UIImage? = nil
        if let bcInfo = barcodeInfo, bcInfo.image != nil {
            image = bcInfo.image?.getBitmap()
        }
        
        let imageView = UIImageView(image: image)
        
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x:0, y:0, width:tableView.bounds.width, height:tableView.frame.height)
        cell.addSubview(imageView)
        var frame = cell.bounds
        frame.size.height = tableView.frame.height
        cell.bounds = frame
        
        return cell
    }
    
    func createBarcodeInfoCell(tableView: UITableView) -> UITableViewCell {
        let bcCell: BarcodeInfoCell! = tableView.dequeueReusableCell(withIdentifier: PreviewBarcodeViewController.barcodeInfoCellIdentifier) as! BarcodeInfoCell!
        
        if let bcInfo = barcodeInfo {
            bcCell.setupBarcodeInfoCell(bcInfo: bcInfo)
        }
        
        return bcCell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell!
        
        if indexPath.row == 0
        {
            cell = createBarcodeInfoCell(tableView: tableView)
        } else {
            cell = createPreviewCell(tableView: tableView)
        }
    
        cell.accessoryType = .none
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return -1
        }
        
        return tableView.frame.height
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 70
        }
        
        return 0
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            if buttonsView == nil {
                buttonsView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
                
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
