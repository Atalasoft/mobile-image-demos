//
//  PreviewImageViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 10/05/16.
//  Copyright © 2016-2017 Atalasoft. All rights reserved.
//

import UIKit
import MessageUI

class PreviewImageViewController: UIViewController, kfxKIPDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet var saveGalleryButton : UIButton!
    @IBOutlet var sendMailButton : UIButton!
    
    @IBOutlet var imageView : kfxKUIImageReviewAndEdit!
    
    var image : kfxKEDImage?
    let processor = kfxKENImageProcessor.instance()
    
    var closeButton: UIBarButtonItem!
    
    let waitingIndicator = WaitingIndicator()
    var openedEmail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveGalleryButton.ConfigureButton(image: "gallery.png")
        sendMailButton.ConfigureButton(image: "email.png")
        
        imageView.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).cgColor
        
        sendMailButton.isEnabled = MFMailComposeViewController.canSendMail()
        
        navigationItem.setHidesBackButton(true, animated: true);
        
        closeButton = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(onClosePreview))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func GetTopView() -> UIView {
        
        return (navigationController?.view)!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !openedEmail {
            self.perform(#selector(processImage), with:nil, afterDelay: 0.25)
        }
        
        openedEmail = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func processImage() {
        
        waitingIndicator.show(text: "Processing image...", superview: GetTopView())
        
        let ipSettings = Settings()
        if !Settings.UseDefaultIPSettings() {
            ipSettings.load()
        }
        
        let basicSettings = kfxKEDBasicSettingsProfile()
        
        if ipSettings.Mode == 0 {
            basicSettings?.specifyOutputBitDepth(KED_BITDEPTH_BITONAL)
        } else if ipSettings.Mode == 1 {
            basicSettings?.specifyOutputBitDepth(KED_BITDEPTH_GRAYSCALE)
        } else {
            basicSettings?.specifyOutputBitDepth(KED_BITDEPTH_COLOR)
        }
        
        basicSettings?.doCrop = ipSettings.AutoCrop ? KED_CROP_AUTO : KED_CROP_NONE
        basicSettings?.doRotate = ipSettings.AutoRotate ? KED_AUTOMATIC : KED_ROTATE_NONE
        basicSettings?.doDeskew = ipSettings.Deskew
        
        if ipSettings.Scale == 1 {
            basicSettings?.outputDPI = 200
        } else if ipSettings.Scale == 2 {
            basicSettings?.outputDPI = 300
        } else if ipSettings.Mode == 3 {
            basicSettings?.outputDPI = 400
        }
        
        processor?.delegate = self
        processor?.basicSettingsProfile = basicSettings
        
        let res = processor?.processImage(image)
        if res != KMC_SUCCESS {
            waitingIndicator.hide()
            
            let alert = UIAlertController(title: "Error", message: "Failed to run image processing. Error: \(String(describing: res))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClosePreview() {
        let confirmAlert = UIAlertController(title: "", message: "Are you sure to close?", preferredStyle: .alert)
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController?.popToRootViewController(animated: true)
            }))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func onSaveImageToGallery() {
        
        if let kfxImage = image {
            DispatchQueue.main.async {
                self.waitingIndicator.show(text: "Saving image...", superview: self.GetTopView())
            }
            
            PhotoAlbum.sharedInstance.saveImage(image: kfxImage.getBitmap(), completionHandler: {(result: Bool, error: NSError?) in
                
                var title = ""
                var message = ""
                
                if result {
                    message = "Image saved successfully"
                } else {
                    title = "Error"
                    message = "Failed to save image to gallery."
                }
                DispatchQueue.main.async {
                    
                    self.waitingIndicator.hide()
                    
                    let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    confirmAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.present(confirmAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func onSendImageByMail() {

        if !MFMailComposeViewController.canSendMail() {
            return
        }
        
        openedEmail = true
        
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        
        if let kfxImage = image {
            mailComposeVC.addAttachmentData(UIImageJPEGRepresentation(kfxImage.getBitmap(), 1.0)!, mimeType: "image/png", fileName:  "image.png")
        }
        
        mailComposeVC.setSubject("Email Subject")
        
        self.present(mailComposeVC, animated: true, completion: nil)
        
    }
    
    func imageOut(_ status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
        
        DispatchQueue.main.async {
            self.image = kfxImage
            self.imageView.setImage(self.image)
            self.waitingIndicator.hide()
        }
    }
    
    func processProgress(_ status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
        DispatchQueue.main.async {
            self.waitingIndicator.updateMessage(text: "Processing image... \(percent)%")
        }
    }
    
    func analysisProgress(_ status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
    }
    
    func analysisComplete(_ status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
    }
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}
