//
//  CaptureViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
//

import UIKit

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
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

    var forceCaptureTimer: Timer?
    
    var torchEnabled : Bool = false
    let torchOnIcon = UIImage(named: "torchon.png")
    let torchOffIcon = UIImage(named: "torch_off.png")
    
    var capturedImage : kfxKEDImage?
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
    
    static let SeguePreviewImageViewController = "PreviewImageViewController"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        waitingIndicator.show(text: "Initializing...", superview: view)
        
        kfxKUIImageCaptureControl.initializeControl()
        kfxKUIImageReviewAndEdit.initializeControl()
        
        captureControl.delegate = self
        captureExperience = kfxKUIDocumentCaptureExperience(captureControl: captureControl, criteria: captureCriteriaHolder)
        
        self.setNeedsStatusBarAppearanceUpdate()

        processImageButton.layer.cornerRadius = 30;
        processImageButton.setBackgroundImage(UIImage.fromColor(color: UIColor.white), for: .normal)
        processImageButton.setBackgroundImage(UIImage.fromColor(color: UIColor.gray), for: UIControlState.highlighted.union(.selected))
        processImageButton.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if capturedImage == nil {
            waitingIndicator.show(text: "Initializing...", superview: view)

            self.perform(#selector(initializeCaptureControl), with:nil, afterDelay: 0.25)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if capturedImage == nil {
            settings.load()

            manualCapturing = false
            
            showCaptureControls(show: false)
            showReviewControls(show: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated:false)
        
        waitingIndicator.hide()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func initializeCaptureControl() {

        captureControl.stabilityDelay = settings.StabilityDelay
        captureControl.levelThresholdPitch = settings.PitchThreshold
        captureControl.levelThresholdRoll = settings.RollThreshold
        captureControl.flash = settings.AutoTorch ? kfxKUIFlashAuto : flashState
        
        captureControl.pageDetectMode = kfxKUIPageDetectAutomatic
        forceCaptureButton.isHidden = !manualCapturing

        showCaptureControls()
        
        waitingIndicator.hide()

        if !manualCapturing {
            perform(#selector(runManualCapturing), with:nil, afterDelay: TimeInterval(settings.ManualCaptureTime))
        }
    }
    
    @objc func runManualCapturing() {

        manualCapturing = true
        if capturedImage == nil {
            forceCaptureButton.isHidden = false
        }
    }
    
    func showCaptureControls(show: Bool) {
        captureControl.isHidden = !show
        cancelButton.isHidden = !show
        forceCaptureButton.isHidden = !(show && manualCapturing)
        torchButton.isHidden = !show || settings.AutoTorch || !((captureDevice?.hasFlash)! && (captureDevice?.hasTorch)!)
        galleryButton.isHidden = !show || !settings.CameraShowGallery
        
        if show {
            captureExperience.takePictureContinually()
        } else {
            captureExperience.stopCapture()
        }
    }
    
    func showReviewControls(show: Bool) {
        reviewControl.isHidden = !show
        retakeButton.isHidden = !show
        processImageButton.isHidden = !show
        
        flashState = captureControl.flash
        captureControl.flash = kfxKUIFlashOff
    }
    
    func showCaptureControls() {
        showCaptureControls(show: true)
        showReviewControls(show: false)
        
        captureControl.flash = flashState
    }
    
    func showReviewControls() {
        showCaptureControls(show: false)
        showReviewControls(show: true)
    }
    
    @IBAction func OnCancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func OnCaptureButtonPressed() {
        captureControl.forceTakePicture()
    }
    
    @IBAction func OnTorchButtonPressed() {
        
        torchEnabled = !torchEnabled
        
        torchButton.setImage(torchEnabled ? torchOnIcon : torchOffIcon, for: .normal)
        
        captureControl?.flash = torchEnabled ? kfxKUITorch : kfxKUIFlashOff
    }
    
    @IBAction func OnRetakeImagePressed() {
        capturedImage = nil
        initializeCaptureControl()
    }
    
    @IBAction func OnProcessImagePressed() {
        if let kfxImage = capturedImage {
            Settings.updateLimitationCounter()
            performSegue(withIdentifier: CaptureViewController.SeguePreviewImageViewController, sender: kfxImage)
        }
    }
    
    @IBAction func OnOpenGallery() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let captureView = captureControl {
            captureView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height - 70)
        }
    }
    
    func imageCaptureControl(_ imageCaptureControl: kfxKUIImageCaptureControl!, imageCaptured image: kfxKEDImage!) {
        previewCapturedImage(kfxImage: image)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage]
        
        let kfxImage = kfxKEDImage(image: image as! UIImage)
        
        picker.dismiss(animated: true, completion: nil)
        previewCapturedImage(kfxImage: kfxImage!)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == CaptureViewController.SeguePreviewImageViewController)
        {
            let previewViewController: PreviewImageViewController = segue.destination as! PreviewImageViewController
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
