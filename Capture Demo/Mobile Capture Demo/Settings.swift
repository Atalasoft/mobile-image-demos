//
//  Settings.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 01/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import Foundation

class Settings {
    
    static let CameraSettingsCount = 6
    static let MaxUsagesPerMonth = 100 // set to -1 to disable usage limitation
    
    static var ExceedLimitation = false

    // Camera settings
    
    var CameraShowGallery : Bool = true
    var StabilityDelay : Int32 = 95
    var PitchThreshold : Int32 = 45
    var RollThreshold : Int32 = 45
    var ManualCaptureTime : Int32 = 15
    var AutoTorch : Bool = true

    // IP settings
    var UseDefaultSettings : Bool = true
    var Mode : Int = 0
    var AutoCrop : Bool = true
    var AutoRotate : Bool = true
    var Deskew : Bool = true
    var Scale : Int = 1
    
    // Camera settings keys
    static let CameraShowGalleryKey = "CameraShowGallery"
    static let StabilityDelayKey    = "StabilityDelay"
    static let PitchThresholdKey    = "PitchThreshold"
    static let RollThresholdKey     = "RollThreshold"
    static let ManualCaptureTimeKey = "ManualCaptureTime"
    static let AutoTorchKey         = "AutoTorch"
    
    static let UseDefaultSettingsKey  = "UseDefaultSettings"
    static let ModeKey                = "Mode"
    static let AutoCropKey            = "AutoCrop"
    static let AutoRotateKey          = "AutoRotate"
    static let DeskewKey              = "Deskew"
    static let ScaleKey               = "Scale"
    
    static let ShotsCounterKey        = "UsageCounter"
    static let UsageUpdateDateKey     = "UsageUpdateDate"

    func load() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        let keys = userDefaults.dictionaryRepresentation().keys
        
        // load camera settings
        if keys.contains(Settings.CameraShowGalleryKey) {
            CameraShowGallery = userDefaults.boolForKey(Settings.CameraShowGalleryKey)
        }
        if keys.contains(Settings.StabilityDelayKey) {
            StabilityDelay = Int32(userDefaults.integerForKey(Settings.StabilityDelayKey))
        }
        if keys.contains(Settings.PitchThresholdKey) {
            PitchThreshold = Int32(userDefaults.integerForKey(Settings.PitchThresholdKey))
        }
        if keys.contains(Settings.RollThresholdKey) {
            RollThreshold = Int32(userDefaults.integerForKey(Settings.RollThresholdKey))
        }
        if keys.contains(Settings.ManualCaptureTimeKey) {
            ManualCaptureTime = Int32(userDefaults.integerForKey(Settings.ManualCaptureTimeKey))
        }
        if keys.contains(Settings.AutoTorchKey) {
            AutoTorch = userDefaults.boolForKey(Settings.AutoTorchKey)
        }
        
        UseDefaultSettings = Settings.UseDefaultIPSettings()
        if keys.contains(Settings.ModeKey) {
            Mode = userDefaults.integerForKey(Settings.ModeKey)
        }
        if keys.contains(Settings.AutoCropKey) {
            AutoCrop = userDefaults.boolForKey(Settings.AutoCropKey)
        }
        if keys.contains(Settings.AutoRotateKey) {
            AutoRotate = userDefaults.boolForKey(Settings.AutoRotateKey)
        }
        if keys.contains(Settings.DeskewKey) {
            Deskew = userDefaults.boolForKey(Settings.DeskewKey)
        }
        if keys.contains(Settings.ScaleKey) {
            Scale = userDefaults.integerForKey(Settings.ScaleKey)
        }
    }
    
    func save() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        // save camera settings
        userDefaults.setBool(CameraShowGallery, forKey: Settings.CameraShowGalleryKey)
        userDefaults.setInteger(Int(StabilityDelay), forKey: Settings.StabilityDelayKey)
        userDefaults.setInteger(Int(PitchThreshold), forKey: Settings.PitchThresholdKey)
        userDefaults.setInteger(Int(RollThreshold), forKey: Settings.RollThresholdKey)
        userDefaults.setInteger(Int(ManualCaptureTime), forKey: Settings.ManualCaptureTimeKey)
        userDefaults.setBool(AutoTorch, forKey: Settings.AutoTorchKey)
        
        saveIPSettings()
        
        userDefaults.synchronize()
    }

    static func UseDefaultIPSettings() -> Bool {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.dictionaryRepresentation().keys.contains(Settings.UseDefaultSettingsKey) {
            return userDefaults.boolForKey(Settings.UseDefaultSettingsKey)
        }
        
        return true
    }
    
    
    func saveIPSettings() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setBool(UseDefaultSettings, forKey: Settings.UseDefaultSettingsKey)
        userDefaults.setInteger(Mode, forKey: Settings.ModeKey)
        userDefaults.setBool(AutoCrop, forKey: Settings.AutoCropKey)
        userDefaults.setBool(AutoRotate, forKey: Settings.AutoRotateKey)
        userDefaults.setBool(Deskew, forKey: Settings.DeskewKey)
        userDefaults.setInteger(Scale, forKey: Settings.ScaleKey)
        
        userDefaults.synchronize()
    }
    
    static func MonthOfDate(date: NSDate) -> Int {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let dateComponents = calendar?.components(NSCalendarUnit.Month, fromDate: date)
        if let components = dateComponents {
            return components.month
        }
        return -1
    }
    
    static func validateLimitation() {
        if Settings.MaxUsagesPerMonth == -1 {
            return
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let keys = userDefaults.dictionaryRepresentation().keys
        
        var exceeded = false
        if keys.contains(Settings.ShotsCounterKey) && keys.contains(Settings.UsageUpdateDateKey) {
            let lastDateInterval : Int = userDefaults.integerForKey(Settings.UsageUpdateDateKey)
            
            let lastDateMonth = MonthOfDate(NSDate(timeIntervalSince1970: NSTimeInterval(lastDateInterval)))
            let todaysMonth = MonthOfDate(NSDate())
            
            if lastDateMonth == todaysMonth {
                let shotsCounter = userDefaults.integerForKey(Settings.ShotsCounterKey)
                exceeded = shotsCounter >= Settings.MaxUsagesPerMonth
            }
        }
        
        ExceedLimitation = exceeded
    }
    
    static func updateLimitationCounter() {
        if Settings.MaxUsagesPerMonth == -1 {
            return
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let keys = userDefaults.dictionaryRepresentation().keys
        var shotsCounter = 0
        
        if keys.contains(Settings.ShotsCounterKey) && keys.contains(Settings.UsageUpdateDateKey) {
            let lastDateInterval : Int = userDefaults.integerForKey(Settings.UsageUpdateDateKey)
            
            let lastDateMonth = MonthOfDate(NSDate(timeIntervalSince1970: NSTimeInterval(lastDateInterval)))
            let todaysMonth = MonthOfDate(NSDate())
            
            if lastDateMonth == todaysMonth {
                shotsCounter = userDefaults.integerForKey(Settings.ShotsCounterKey)
            }
        }
        
        shotsCounter += 1
        
        userDefaults.setInteger(shotsCounter, forKey: Settings.ShotsCounterKey)
        userDefaults.setInteger(Int(NSDate().timeIntervalSince1970), forKey: Settings.UsageUpdateDateKey)
    }
}
