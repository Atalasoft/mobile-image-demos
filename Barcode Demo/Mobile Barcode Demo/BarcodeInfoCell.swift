//
//  BarcodeInfoCell.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 04/07/16.
//  Copyright © 2016-2018 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class BarcodeInfoCell: UITableViewCell {
    @IBOutlet var barcodeInfoLabel : UILabel!
    @IBOutlet var barcodeValue : UITextView!
    
    func setupBarcodeInfoCell(bcInfo: BarcodeInfo) {
        barcodeInfoLabel.text = BarcodeTypes.BarcodeTypeToString(barcodeType: bcInfo.barcode.type)
        
        var value = bcInfo.barcode.value
        if bcInfo.barcode.dataFormat == KEDBarcodeDataFormats.init(2) {
            let data = NSData(base64Encoded: bcInfo.barcode.value, options: NSData.Base64DecodingOptions(rawValue: 0))
            value = String(data: data! as Data, encoding: String.Encoding.utf8)!
        }
        
        barcodeValue.text = value
    }
}
