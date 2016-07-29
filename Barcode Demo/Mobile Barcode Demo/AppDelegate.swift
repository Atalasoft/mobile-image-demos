//
//  AppDelegate.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 20/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        Settings.validateLimitation()
        if Settings.ExceedLimitation {
            let alert = UIAlertController(title: "Error", message: "You have reached your monthly usage limit.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default) { action -> Void in })
            
            if let wnd = window {
                wnd.rootViewController?.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

