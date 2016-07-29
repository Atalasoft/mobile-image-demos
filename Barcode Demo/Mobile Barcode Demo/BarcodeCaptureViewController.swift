//
//  CaptureViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit
import Foundation

class BarcodeInfo : AnyObject
{
    var barcode: kfxKEDBarcodeResult!
    var image: kfxKEDImage!
}

class BarcodeCaptureViewController: UIViewController, kfxKUIBarCodeCaptureControlDelegate {

    @IBOutlet weak var captureControlView: kfxKUIBarCodeCaptureControl!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var torchButton: UIButton!
    
    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    var barcodeControlInitialized = false
    let settings : Settings = Settings()
    
    var barcodeDetectedPlayer: AVAudioPlayer?
    
    static let SeguePreviewImageViewController = "PreviewBarcodeViewController"
    
    static let DefaultStabilityDelay: Int32 = 95
    
    let torchOnImage = UIImage(named: "torchon.png")
    let torchOffImage = UIImage(named: "torch_off.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        torchButton.setImage(torchOffImage, forState: .Normal)
        torchButton.hidden = !(captureDevice.hasFlash && captureDevice.hasTorch)
        
        let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("beep-29", ofType: "wav")!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            try barcodeDetectedPlayer = AVAudioPlayer(contentsOfURL: alertSound)
            barcodeDetectedPlayer?.prepareToPlay()
            
        } catch {
            print("Failed to initialize audio")
            barcodeDetectedPlayer = nil
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        settings.load()

        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.performSelector(#selector(initializeCaptureControl), withObject:nil, afterDelay: 0.25)
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    func initializeCaptureControl() {
        
        if barcodeControlInitialized == false {

            captureControlView.delegate = self;
            captureControlView.guidingLine = kfxKUIGuidingLineLandscape
        }
        
        var symbologies = [Int]()
        for (index,value) in settings.barcodes.enumerate() {
            if value {
                symbologies.append(index);
            }
        }
        
        captureControlView.symbologies = symbologies as [AnyObject]
        
        captureControlView.readBarcode()
    }
    
    @IBAction func OnCancelButtonPressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func barcodeCaptureControl(barcodeCaptureControl: kfxKUIBarCodeCaptureControl!,
                               barcodeFound result : kfxKEDBarcodeResult, image:kfxKEDImage)
    {
        let barcodeInfo = BarcodeInfo()
        barcodeInfo.barcode = result
        barcodeInfo.image = image
        
        if let player = barcodeDetectedPlayer {
            let volume = AVAudioSession.sharedInstance().outputVolume
            player.volume = volume
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            } catch {}
            player.play()
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            
            Settings.updateLimitationCounter()
            
            self.performSegueWithIdentifier(BarcodeCaptureViewController.SeguePreviewImageViewController, sender: barcodeInfo)
        })
    }
    
    @IBAction func OnTorchButtonPressed() {
        if captureDevice.hasFlash && captureDevice.hasTorch {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.torchMode = captureDevice.torchMode == .Off ? .On : .Off
                captureDevice.unlockForConfiguration()
            } catch {
                print("Unable to turn on the torch")
            }
            
            torchButton.setImage(captureDevice.torchMode == .On ? torchOnImage : torchOffImage, forState: .Normal)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == BarcodeCaptureViewController.SeguePreviewImageViewController)
        {
            let previewViewController: PreviewBarcodeViewController = segue.destinationViewController as! PreviewBarcodeViewController
            let barcodeInfo = sender as! BarcodeInfo
            
            previewViewController.barcodeInfo = barcodeInfo
        }
    }
    
    func imageCaptureControl(imageCaptureControl: kfxKUIImageCaptureControl!, pageDetected previewImage: UIImage!, pageCoordinates bound: kfxKEDBoundingTetragon!) {
        OnCancelButtonPressed()
    }
    
}
