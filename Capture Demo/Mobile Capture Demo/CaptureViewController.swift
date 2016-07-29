//
//  CaptureViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
}

class CaptureViewController: UIViewController, kfxKUIImageCaptureControlDelegate , UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var forceCaptureButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var torchButton: UIButton!

    @IBOutlet var retakeButton: UIButton!
    @IBOutlet var processImageButton: UIButton!
    
    @IBOutlet weak var captureControl: kfxKUIImageCaptureControl!
    @IBOutlet weak var reviewControl: kfxKUIImageReviewAndEdit!
    
    var waitingIndicator = WaitingIndicator()
    
    var flashState = kfxKUIFlashOff
    var manualCapturing = false
    
    var captureExperience: kfxKUIDocumentCaptureExperience!
    var captureCriteriaHolder = kfxKUIDocumentCaptureExperienceCriteriaHolder()
    
    let settings : Settings = Settings()

    var forceCaptureTimer: NSTimer?
    
    var torchEnabled : Bool = false
    let torchOnIcon = UIImage(named: "torchon.png")
    let torchOffIcon = UIImage(named: "torch_off.png")
    
    var capturedImage : kfxKEDImage?
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
    
    static let SeguePreviewImageViewController = "PreviewImageViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        waitingIndicator.show("Initializing...", superview: view)
        
        kfxKUIImageCaptureControl.initializeControl()
        kfxKUIImageReviewAndEdit.initializeControl()
        
        captureControl.delegate = self
        captureExperience = kfxKUIDocumentCaptureExperience(captureControl: captureControl, criteria: captureCriteriaHolder)
        
        self.setNeedsStatusBarAppearanceUpdate()

        processImageButton.layer.cornerRadius = 30;
        processImageButton.setBackgroundImage(UIImage.fromColor(UIColor.whiteColor()), forState: .Normal)
        processImageButton.setBackgroundImage(UIImage.fromColor(UIColor.grayColor()), forState: UIControlState.Highlighted.union(.Selected))
        processImageButton.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if capturedImage == nil {
            waitingIndicator.show("Initializing...", superview: view)

            self.performSelector(#selector(initializeCaptureControl), withObject:nil, afterDelay: 0.25)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if capturedImage == nil {
            settings.load()

            manualCapturing = false
            
            showCaptureControls(false)
            showReviewControls(false)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated:false)
        
        waitingIndicator.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func initializeCaptureControl() {

        captureControl.stabilityDelay = settings.StabilityDelay
        captureControl.levelThresholdPitch = settings.PitchThreshold
        captureControl.levelThresholdRoll = settings.RollThreshold
        captureControl.flash = settings.AutoTorch ? kfxKUIFlashAuto : flashState
        
        captureControl.pageDetectMode = kfxKUIPageDetectAutomatic
        forceCaptureButton.hidden = !manualCapturing

        showCaptureControls()
        
        waitingIndicator.hide()

        if !manualCapturing {
            performSelector(#selector(runManualCapturing), withObject:nil, afterDelay: NSTimeInterval(settings.ManualCaptureTime))
        }
    }
    
    func runManualCapturing() {

        manualCapturing = true
        if capturedImage == nil {
            forceCaptureButton.hidden = false
        }
    }
    
    func showCaptureControls(show: Bool) {
        captureControl.hidden = !show
        cancelButton.hidden = !show
        forceCaptureButton.hidden = !(show && manualCapturing)
        torchButton.hidden = !show || settings.AutoTorch || !(captureDevice.hasFlash && captureDevice.hasTorch)
        galleryButton.hidden = !show || !settings.CameraShowGallery
        
        if show {
            captureExperience.takePictureContinually()
        } else {
            captureExperience.stopCapture()
        }
    }
    
    func showReviewControls(show: Bool) {
        reviewControl.hidden = !show
        retakeButton.hidden = !show
        processImageButton.hidden = !show
        
        flashState = captureControl.flash
        captureControl.flash = kfxKUIFlashOff
    }
    
    func showCaptureControls() {
        showCaptureControls(true)
        showReviewControls(false)
        
        captureControl.flash = flashState
    }
    
    func showReviewControls() {
        showCaptureControls(false)
        showReviewControls(true)
    }
    
    @IBAction func OnCancelButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func OnCaptureButtonPressed() {
        captureControl.forceTakePicture()
    }
    
    @IBAction func OnTorchButtonPressed() {
        
        torchEnabled = !torchEnabled
        
        torchButton.setImage(torchEnabled ? torchOnIcon : torchOffIcon, forState: .Normal)
        
        captureControl?.flash = torchEnabled ? kfxKUITorch : kfxKUIFlashOff
    }
    
    @IBAction func OnRetakeImagePressed() {
        capturedImage = nil
        initializeCaptureControl()
    }
    
    @IBAction func OnProcessImagePressed() {
        if let kfxImage = capturedImage {
            Settings.updateLimitationCounter()
            performSegueWithIdentifier(CaptureViewController.SeguePreviewImageViewController, sender: kfxImage)
        }
    }
    
    @IBAction func OnOpenGallery() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .PhotoLibrary
        navigationController?.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let captureView = captureControl {
            captureView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height - 70)
        }
    }
    
    func imageCaptureControl(imageCaptureControl: kfxKUIImageCaptureControl!, imageCaptured image: kfxKEDImage!) {
        previewCapturedImage(image)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let image = info[UIImagePickerControllerOriginalImage]
        
        let kfxImage = kfxKEDImage(image: image as! UIImage)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        previewCapturedImage(kfxImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == CaptureViewController.SeguePreviewImageViewController)
        {
            let previewViewController: PreviewImageViewController = segue.destinationViewController as! PreviewImageViewController
            let image = sender as! kfxKEDImage
            
            previewViewController.image = image
        }
    }

    func previewCapturedImage(kfxImage: kfxKEDImage) {
        
        showReviewControls()

        capturedImage = kfxImage
        reviewControl.setImage(kfxImage)
    }
}
