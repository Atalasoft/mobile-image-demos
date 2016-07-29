//
//  Settings.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 01/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import Foundation

class Settings {
    
    static let MaxUsagesPerMonth = 100 // set to -1 to disable usage limitation
    
    static var ExceedLimitation = false
    
    // Barcode settings
    var barcodes : [Bool] = [Bool](count: 11, repeatedValue: true)
    
    static let BarcodeSettingsKey   = "Barcodes"
    
    static let ShotsCounterKey      = "UsageCounter"
    static let UsageUpdateDateKey   = "UsageUpdateDate"
    
    func load() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        let bc = userDefaults.arrayForKey(Settings.BarcodeSettingsKey)
        if let configuredBarcodes = bc {
            for (index,value) in configuredBarcodes.enumerate() {
                if let enabled = value.boolValue {
                    barcodes[index] = enabled
                }
            }
        }
    }
    
    func save() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        userDefaults.setObject(barcodes, forKey: Settings.BarcodeSettingsKey)
        
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
