//
//  CaptureViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit
import Foundation

class BarcodeInfo
{
    var barcode: kfxKEDBarcodeResult!
    var image: kfxKEDImage!
}

class BarcodeCaptureViewController: UIViewController, kfxKUIBarCodeCaptureControlDelegate {

    @IBOutlet weak var captureControlView: kfxKUIBarCodeCaptureControl!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var torchButton: UIButton!
    
    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)

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
        
        torchButton.setImage(torchOffImage, for: .normal)
        torchButton.isHidden = !(captureDevice != nil && (captureDevice?.hasFlash)! && (captureDevice?.hasTorch)!)
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "beep-29", ofType: "wav")!)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            try barcodeDetectedPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
            barcodeDetectedPlayer?.prepareToPlay()
            
        } catch {
            print("Failed to initialize audio")
            barcodeDetectedPlayer = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settings.load()

        navigationController?.setNavigationBarHidden(true, animated: true)
        
        self.perform(#selector(initializeCaptureControl), with:nil, afterDelay: 0.25)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func initializeCaptureControl() {
        
        if barcodeControlInitialized == false {

            kfxKUILogging.enableConsoleLogging(true)
            kfxKENLogging.enableConsoleLogging(true)
            kfxKUTLogging.enableConsoleLogging(true)
            captureControlView.delegate = self;
            captureControlView.guidingLine = kfxKUIGuidingLineLandscape
        }
        
        var symbologies = [Int]()
        for (index,value) in settings.barcodes.enumerated() {
            if value {
                symbologies.append(index)
            }
        }
        
        captureControlView.symbologies = symbologies as [AnyObject]
        captureControlView.readBarcode()
    }
    
    @IBAction func OnCancelButtonPressed() {
        self.navigationController?.popViewController(animated: true)
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
        
        DispatchQueue.main.async {
            Settings.updateLimitationCounter()
            
            self.performSegue(withIdentifier: BarcodeCaptureViewController.SeguePreviewImageViewController, sender: barcodeInfo)
        }
    }
    
    @IBAction func OnTorchButtonPressed() {
        if (captureDevice?.hasFlash)! && (captureDevice?.hasTorch)! {
            do {
                try captureDevice?.lockForConfiguration()
                captureDevice?.torchMode = captureDevice?.torchMode == .off ? .on : .off
                captureDevice?.unlockForConfiguration()
            } catch {
                print("Unable to turn on the torch")
            }
            
            torchButton.setImage(captureDevice?.torchMode == .on ? torchOnImage : torchOffImage, for: .normal)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == BarcodeCaptureViewController.SeguePreviewImageViewController)
        {
            let previewViewController: PreviewBarcodeViewController = segue.destination as! PreviewBarcodeViewController
            let barcodeInfo = sender as! BarcodeInfo
            
            previewViewController.barcodeInfo = barcodeInfo
        }
    }
    
    func imageCaptureControl(imageCaptureControl: kfxKUIImageCaptureControl!, pageDetected previewImage: UIImage!, pageCoordinates bound: kfxKEDBoundingTetragon!) {
        OnCancelButtonPressed()
    }
    
}
