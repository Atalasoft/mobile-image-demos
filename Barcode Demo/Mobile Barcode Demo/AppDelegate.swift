//
//  AppDelegate.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 20/05/16.
//  Copyright © 2016-2017 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Settings.validateLimitation()
        if Settings.ExceedLimitation {
            let alert = UIAlertController(title: "Error", message: "You have reached your monthly usage limit.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action -> Void in })
            
            if let wnd = window {
                wnd.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }


}

