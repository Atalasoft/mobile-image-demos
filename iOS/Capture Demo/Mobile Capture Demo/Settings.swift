//
//  Settings.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 01/05/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
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
        
        let userDefaults = UserDefaults.standard

        let keys = userDefaults.dictionaryRepresentation().keys
        
        // load camera settings
        if keys.contains(Settings.CameraShowGalleryKey) {
            CameraShowGallery = userDefaults.bool(forKey: Settings.CameraShowGalleryKey)
        }
        if keys.contains(Settings.StabilityDelayKey) {
            StabilityDelay = Int32(userDefaults.integer(forKey: Settings.StabilityDelayKey))
        }
        if keys.contains(Settings.PitchThresholdKey) {
            PitchThreshold = Int32(userDefaults.integer(forKey: Settings.PitchThresholdKey))
        }
        if keys.contains(Settings.RollThresholdKey) {
            RollThreshold = Int32(userDefaults.integer(forKey: Settings.RollThresholdKey))
        }
        if keys.contains(Settings.ManualCaptureTimeKey) {
            ManualCaptureTime = Int32(userDefaults.integer(forKey: Settings.ManualCaptureTimeKey))
        }
        if keys.contains(Settings.AutoTorchKey) {
            AutoTorch = userDefaults.bool(forKey: Settings.AutoTorchKey)
        }
        
        UseDefaultSettings = Settings.UseDefaultIPSettings()
        if keys.contains(Settings.ModeKey) {
            Mode = userDefaults.integer(forKey: Settings.ModeKey)
        }
        if keys.contains(Settings.AutoCropKey) {
            AutoCrop = userDefaults.bool(forKey: Settings.AutoCropKey)
        }
        if keys.contains(Settings.AutoRotateKey) {
            AutoRotate = userDefaults.bool(forKey: Settings.AutoRotateKey)
        }
        if keys.contains(Settings.DeskewKey) {
            Deskew = userDefaults.bool(forKey: Settings.DeskewKey)
        }
        if keys.contains(Settings.ScaleKey) {
            Scale = userDefaults.integer(forKey: Settings.ScaleKey)
        }
    }
    
    func save() {
        
        let userDefaults = UserDefaults.standard
        
        // save camera settings
        userDefaults.set(CameraShowGallery, forKey: Settings.CameraShowGalleryKey)
        userDefaults.set(Int(StabilityDelay), forKey: Settings.StabilityDelayKey)
        userDefaults.set(Int(PitchThreshold), forKey: Settings.PitchThresholdKey)
        userDefaults.set(Int(RollThreshold), forKey: Settings.RollThresholdKey)
        userDefaults.set(Int(ManualCaptureTime), forKey: Settings.ManualCaptureTimeKey)
        userDefaults.set(AutoTorch, forKey: Settings.AutoTorchKey)
        
        saveIPSettings()
        
        userDefaults.synchronize()
    }

    static func UseDefaultIPSettings() -> Bool {
        let userDefaults = UserDefaults.standard
        
        if userDefaults.dictionaryRepresentation().keys.contains(Settings.UseDefaultSettingsKey) {
            return userDefaults.bool(forKey: Settings.UseDefaultSettingsKey)
        }
        
        return true
    }
    
    
    func saveIPSettings() {
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(UseDefaultSettings, forKey: Settings.UseDefaultSettingsKey)
        userDefaults.set(Mode, forKey: Settings.ModeKey)
        userDefaults.set(AutoCrop, forKey: Settings.AutoCropKey)
        userDefaults.set(AutoRotate, forKey: Settings.AutoRotateKey)
        userDefaults.set(Deskew, forKey: Settings.DeskewKey)
        userDefaults.set(Scale, forKey: Settings.ScaleKey)
        
        userDefaults.synchronize()
    }
    
    static func MonthOfDate(date: NSDate) -> Int {
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let dateComponents = calendar?.components(NSCalendar.Unit.month, from: date as Date)
        if let components = dateComponents {
            return components.month!
        }
        return -1
    }
    
    static func validateLimitation() {
        if Settings.MaxUsagesPerMonth == -1 {
            return
        }
        
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys
        
        var exceeded = false
        if keys.contains(Settings.ShotsCounterKey) && keys.contains(Settings.UsageUpdateDateKey) {
            let lastDateInterval : Int = userDefaults.integer(forKey: Settings.UsageUpdateDateKey)
            
            let lastDateMonth = MonthOfDate(date: NSDate(timeIntervalSince1970: TimeInterval(lastDateInterval)))
            let todaysMonth = MonthOfDate(date: NSDate())
            
            if lastDateMonth == todaysMonth {
                let shotsCounter = userDefaults.integer(forKey: Settings.ShotsCounterKey)
                exceeded = shotsCounter >= Settings.MaxUsagesPerMonth
            }
        }
        
        ExceedLimitation = exceeded
    }
    
    static func updateLimitationCounter() {
        if Settings.MaxUsagesPerMonth == -1 {
            return
        }
        
        let userDefaults = UserDefaults.standard
        let keys = userDefaults.dictionaryRepresentation().keys
        var shotsCounter = 0
        
        if keys.contains(Settings.ShotsCounterKey) && keys.contains(Settings.UsageUpdateDateKey) {
            let lastDateInterval : Int = userDefaults.integer(forKey: Settings.UsageUpdateDateKey)
            
            let lastDateMonth = MonthOfDate(date: NSDate(timeIntervalSince1970: TimeInterval(lastDateInterval)))
            let todaysMonth = MonthOfDate(date: NSDate())
            
            if lastDateMonth == todaysMonth {
                shotsCounter = userDefaults.integer(forKey: Settings.ShotsCounterKey)
            }
        }
        
        shotsCounter += 1
        
        userDefaults.set(shotsCounter, forKey: Settings.ShotsCounterKey)
        userDefaults.set(Int(NSDate().timeIntervalSince1970), forKey: Settings.UsageUpdateDateKey)
    }
}
