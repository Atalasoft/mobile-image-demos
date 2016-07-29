//
//  PreviewImageViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 10/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
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
        
        imageView.layer.borderColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1.0).CGColor
        
        sendMailButton.enabled = MFMailComposeViewController.canSendMail()
        
        navigationItem.setHidesBackButton(true, animated: true);
        
        closeButton = UIBarButtonItem(title: "Close", style: .Done, target: self, action: #selector(onClosePreview))
        navigationItem.rightBarButtonItem = closeButton
    }
    
    func GetTopView() -> UIView {
        
        return (navigationController?.view)!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !openedEmail {
            self.performSelector(#selector(processImage), withObject:nil, afterDelay: 0.25)
        }
        
        openedEmail = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func processImage() {
        
        waitingIndicator.show("Processing image...", superview: GetTopView())
        
        let ipSettings = Settings()
        if !Settings.UseDefaultIPSettings() {
            ipSettings.load()
        }
        
        let basicSettings = kfxKEDBasicSettingsProfile()
        
        if ipSettings.Mode == 0 {
            basicSettings.specifyOutputBitDepth(KED_BITDEPTH_BITONAL)
        } else if ipSettings.Mode == 1 {
            basicSettings.specifyOutputBitDepth(KED_BITDEPTH_GRAYSCALE)
        } else {
            basicSettings.specifyOutputBitDepth(KED_BITDEPTH_COLOR)
        }
        
        basicSettings.doCrop = ipSettings.AutoCrop ? KED_CROP_AUTO : KED_CROP_NONE
        basicSettings.doRotate = ipSettings.AutoRotate ? KED_AUTOMATIC : KED_ROTATE_NONE
        basicSettings.doDeskew = ipSettings.Deskew
        
        if ipSettings.Scale == 1 {
            basicSettings.outputDPI = 200
        } else if ipSettings.Scale == 2 {
            basicSettings.outputDPI = 300
        } else if ipSettings.Mode == 3 {
            basicSettings.outputDPI = 400
        }
        
        processor.delegate = self
        processor.basicSettingsProfile = basicSettings
        
        let res = processor.processImage(image)
        if res != KMC_SUCCESS {
            print("Error \(res)")
            waitingIndicator.hide()
            
            let alert = UIAlertController(title: "Error", message: "Failed to run image processing. Error: \(res)", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onClosePreview() {
        let confirmAlert = UIAlertController(title: "", message: "Are you sure to close?", preferredStyle: .Alert)
        confirmAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            self.navigationController?.popToRootViewControllerAnimated(true)
            }))
        confirmAlert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        
        self.presentViewController(confirmAlert, animated: true, completion: nil)
    }
    
    @IBAction func onSaveImageToGallery() {
        
        if let kfxImage = image {
            dispatch_async(dispatch_get_main_queue(), {
                self.waitingIndicator.show("Saving image...", superview: self.GetTopView())
            })
            
            PhotoAlbum.sharedInstance.saveImage(kfxImage.getImageBitmap(), completionHandler: {(result: Bool, error: NSError?) in
                
                var title = ""
                var message = ""
                
                if result {
                    message = "Image saved successfully"
                } else {
                    title = "Error"
                    message = "Failed to save image to gallery."
                }
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.waitingIndicator.hide()
                    
                    let confirmAlert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
                    confirmAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    
                    self.presentViewController(confirmAlert, animated: true, completion: nil)
                })
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
            mailComposeVC.addAttachmentData(UIImageJPEGRepresentation(kfxImage.getImageBitmap(), 1.0)!, mimeType: "image/png", fileName:  "image.png")
        }
        
        mailComposeVC.setSubject("Email Subject")
        
        self.presentViewController(mailComposeVC, animated: true, completion: nil)
        
    }
    
    func imageOut(status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
        
        dispatch_async(dispatch_get_main_queue(), {
            self.image = kfxImage
            self.imageView.setImage(self.image)
            self.waitingIndicator.hide()
        })
    }
    
    func processProgress(status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
        dispatch_async(dispatch_get_main_queue(), {
            self.waitingIndicator.updateMessage("Processing image... \(percent)%")
        })
    }
    
    func analysisProgress(status: Int32, withMsg errorMsg: String!, imageID: String!, andProgress percent: Int32) {
    }
    
    func analysisComplete(status: Int32, withMsg errorMsg: String!, andOutputImage kfxImage: kfxKEDImage!) {
    }
    
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
