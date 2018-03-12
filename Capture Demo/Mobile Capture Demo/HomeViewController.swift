//
//  HomeViewController.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 15/04/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    var mobileSdkInitialized: Bool = false
    
    @IBOutlet var cameraButton : UIButton!
    
    static let evrsLIcense = PROCESS_PAGE_SDK_LICENSE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if !mobileSdkInitialized
        {
            mobileSdkInitialized = true

            let license = kfxKUTLicensing()
            let lic = KFX_ERROR_IMAGE_PROCESSOR(rawValue: UInt32(license.setMobileSDKLicense(HomeViewController.evrsLIcense)))
            
            if lic == KMC_IP_LICENSE_EXPIRED || lic == KMC_IP_LICENSE_INVALID {
                showErrorMessage(licenseErrorCode: lic)
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationIsActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        cameraButton?.ConfigureButton(image: "camera_button_normal.png")
        
        navigationItem.title = "MobileImage Document Capture"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.isUserInteractionEnabled = !Settings.ExceedLimitation
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func applicationIsActive(notification: NSNotification) {
        cameraButton.isUserInteractionEnabled = !Settings.ExceedLimitation
    }
    
    func showErrorMessage(licenseErrorCode: KFX_ERROR_IMAGE_PROCESSOR) {
        let errorCode = Int32(licenseErrorCode.rawValue)
        let message = kfxError.findErrMsg(errorCode)
        let description = kfxError.findErrDesc(errorCode)
        
        var alertTitle: String
        var alertDescription: String
        
        let split = message?.split {$0 == ":"}.map(String.init)
        
        if split?.count == 2
        {
            alertTitle = split![0]
            alertDescription = String(format: "%@\n\n%@", split![1], description!)
            
        }
        else if split!.count > 2
        {
            var info = "";
            
            for item in split! {
                info = info.appendingFormat("%@", item)
            }
            
            alertTitle = split![0]
            alertDescription = String(format: "%@\n\n%@", info, description!)
        }
        else
        {
            alertTitle = "License Error!!!"
            alertDescription = String(format: "%@\n\n%@", message!, description!)
            
        }
        
        let alert = UIAlertController(title: alertTitle, message: alertDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { action -> Void in })
        self.present(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
