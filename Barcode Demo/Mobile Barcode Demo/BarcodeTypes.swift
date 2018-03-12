//
//  BarcodeTypes.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 27/05/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
//

import Foundation

class BarcodeTypes {
    
    static let SymbologiesCount = 11
    
    static let SymbologyCode39      = "Code39"
    static let SymbologyPdf417      = "PDF417"
    static let SymbologyQRCode      = "QR Code"
    static let SymbologyDataMatrix  = "DataMatrix"
    static let SymbologyCode128     = "Code128"
    static let SymbologyCode25      = "Code25"
    static let SymbologyEAN         = "EAN"
    static let SymbologyUPC         = "UPC"
    static let SymbologyCodabar     = "Codabar"
    static let SymbologyAztec       = "Aztec"
    static let SymbologyCode93      = "Code93"
    static let SymbologyPostNet     = "PostNet"
    
    static let SymbologyUnknown     = "Unknown"
    
    static func BarcodeTypeToString(barcodeType : KEDBarcodeTypes) -> String {
        var barcodeTypeStr = BarcodeTypes.SymbologyUnknown
        
        if barcodeType == BARCODE_QR {
            barcodeTypeStr = BarcodeTypes.SymbologyQRCode
        } else if barcodeType == BARCODE_EAN {
            barcodeTypeStr = BarcodeTypes.SymbologyEAN
        } else if barcodeType == BARCODE_PDF417 {
            barcodeTypeStr = BarcodeTypes.SymbologyPdf417
        } else if barcodeType == BARCODE_CODE39 {
            barcodeTypeStr = BarcodeTypes.SymbologyCode39
        } else if barcodeType == BARCODE_DATAMATRIX {
            barcodeTypeStr = BarcodeTypes.SymbologyDataMatrix
        } else if barcodeType == BARCODE_CODE128 {
            barcodeTypeStr = BarcodeTypes.SymbologyCode128
        } else if barcodeType == BARCODE_CODE25 {
            barcodeTypeStr = BarcodeTypes.SymbologyCode25
        } else if barcodeType == BARCODE_UPC {
            barcodeTypeStr = BarcodeTypes.SymbologyUPC
        } else if barcodeType == BARCODE_CODABAR {
            barcodeTypeStr = BarcodeTypes.SymbologyCodabar
        } else if barcodeType == BARCODE_AZTEC {
            barcodeTypeStr = BarcodeTypes.SymbologyAztec
        } else if barcodeType == BARCODE_CODE93 {
            barcodeTypeStr = BarcodeTypes.SymbologyCode93
        } else if barcodeType == BARCODE_POSTNET {
            barcodeTypeStr = BarcodeTypes.SymbologyPostNet
        }
        
        return barcodeTypeStr
    }
    
    static func BarcodeSymbologyToString(symbology: kfxKUISymbology) -> String {
        var symbologyStr = BarcodeTypes.SymbologyUnknown
        
        if symbology == kfxKUISymbologyCode39 {
            symbologyStr = BarcodeTypes.SymbologyCode39
        } else if symbology == kfxKUISymbologyPdf417 {
            symbologyStr = BarcodeTypes.SymbologyPdf417
        } else if symbology == kfxKUISymbologyQR {
            symbologyStr = BarcodeTypes.SymbologyQRCode
        } else if symbology == kfxKUISymbologyDataMatrix {
            symbologyStr = BarcodeTypes.SymbologyDataMatrix
        } else if symbology == kfxKUISymbologyCode128 {
            symbologyStr = BarcodeTypes.SymbologyCode128
        } else if symbology == kfxKUISymbologyCode25 {
            symbologyStr = BarcodeTypes.SymbologyCode25
        } else if symbology == kfxKUISymbologyEAN {
            symbologyStr = BarcodeTypes.SymbologyEAN
        } else if symbology == kfxKUISymbologyUPC {
            symbologyStr = BarcodeTypes.SymbologyUPC
        } else if symbology == kfxKUISymbologyCodabar {
            symbologyStr = BarcodeTypes.SymbologyCodabar
        } else if symbology == kfxKUISymbologyAztec {
            symbologyStr = BarcodeTypes.SymbologyAztec
        } else if symbology == kfxKUISymbologyCode93{
            symbologyStr = BarcodeTypes.SymbologyCode93
        }
        
        return symbologyStr
    }
}
