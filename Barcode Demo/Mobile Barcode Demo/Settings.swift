//
//  Settings.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 01/05/16.
//  Copyright © 2016-2017 Atalasoft, a Kofax Company. All rights reserved.
//

import Foundation

class Settings {
    
    static let MaxUsagesPerMonth = 100 // set to -1 to disable usage limitation
    
    static var ExceedLimitation = false
    
    // Barcode settings
    var barcodes : [Bool] = [Bool](repeating: true, count: 11)
    
    static let BarcodeSettingsKey   = "Barcodes"
    
    static let ShotsCounterKey      = "UsageCounter"
    static let UsageUpdateDateKey   = "UsageUpdateDate"
    
    func load() {
        
        let userDefaults = UserDefaults.standard

        let bc = userDefaults.array(forKey: Settings.BarcodeSettingsKey)
        if let configuredBarcodes = bc {
            for (index,value) in configuredBarcodes.enumerated() {
                if let enabled = (value as AnyObject).boolValue {
                    barcodes[index] = enabled
                }
            }
        }
    }
    
    func save() {
        
        let userDefaults = UserDefaults.standard
        
        userDefaults.set(barcodes, forKey: Settings.BarcodeSettingsKey)
        
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
