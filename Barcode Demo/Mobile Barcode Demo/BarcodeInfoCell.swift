//
//  BarcodeInfoCell.swift
//  Mobile Barcode Demo
//
//  Created by Michael Chernikov on 04/07/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class BarcodeInfoCell: UITableViewCell {
    @IBOutlet var barcodeInfoLabel : UILabel!
    @IBOutlet var barcodeValue : UITextView!
    
    func setupBarcodeInfoCell(bcInfo: BarcodeInfo) {
        barcodeInfoLabel.text = BarcodeTypes.BarcodeTypeToString(bcInfo.barcode.type)
        
        var value = bcInfo.barcode.value
        if bcInfo.barcode.dataFormat == KEDBarcodeDataFormats.init(2) {
            let data = NSData(base64EncodedString: bcInfo.barcode.value, options: NSDataBase64DecodingOptions(rawValue: 0))
            value = String(data: data!, encoding: NSUTF8StringEncoding)!
        }
        
        barcodeValue.text = value
    }
}
