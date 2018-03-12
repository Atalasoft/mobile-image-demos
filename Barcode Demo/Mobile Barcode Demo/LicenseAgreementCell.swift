//
//  LicenseAgreementCell.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 30/06/16.
//  Copyright © 2016-2017 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class LicenseAgreementCell: UITableViewCell {

    @IBOutlet var license: UITextView!
    
    var linkTapGestureRecognizer: UITapGestureRecognizer!
    
    func makeLink(text: NSMutableAttributedString, linkText: String, linkUrl: String) {
        
        let linkRange = (text.string as NSString).range(of: linkText)
        text.addAttribute(NSAttributedStringKey.link, value: linkUrl, range: linkRange)
    }
    
    func setupLicenseData() {
        
        if linkTapGestureRecognizer == nil {
            linkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapGestureRecognizer))
            linkTapGestureRecognizer.cancelsTouchesInView = false
            linkTapGestureRecognizer.delaysTouchesBegan = false
            linkTapGestureRecognizer.delaysTouchesEnded = false
            addGestureRecognizer(linkTapGestureRecognizer)
        }
        
        if let path = Bundle.main.url(forResource: "eula", withExtension: "rtf") {
            do {
                //let text = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                
                //let eula = try NSMutableAttributedString(data: text.data(using: String.Encoding.utf8)!, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                var eula : NSAttributedString
                if #available(iOS 9.0, *) {
                    eula = try NSAttributedString(url: path, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                } else {
                    // Fallback on earlier versions
                    let text = try String(contentsOf: path, encoding: String.Encoding.utf8)
                    eula = try NSAttributedString(data: text.data(using: String.Encoding.utf8)!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)
                }
                
                /*
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = NSTextAlignment.justified
                paragraphStyle.hyphenationFactor = 1
                
                eula.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, eula.length))
                makeLink(text: eula, linkText: "www.kofax.com", linkUrl: "http://www.kofax.com")
                */
                license.attributedText = eula
            } catch {
            }
        }
    }

    @objc func handleLinkTapGestureRecognizer(tapRecognizer: UITapGestureRecognizer) {
        
        let view = tapRecognizer.view
        let location = tapRecognizer.location(in: view)
        
        var linkStr = ""
        
        if license.frame.contains(location) {
            linkStr = getLinkOnText(location: tapRecognizer.location(in: license), textView: license)
        }
        
        if !linkStr.isEmpty {
            let url: NSURL! = NSURL(string: linkStr)
            UIApplication.shared.openURL(url as URL)
        }
    }
    
    func getLinkOnText(location: CGPoint, textView: UITextView) -> String {
        
        var textPosition1 = textView.closestPosition(to: location)
        var textPosition2:UITextPosition?
        if let _ = textPosition1 {
            textPosition2 = textView.position(from: textPosition1!, offset: 1)
            if let _ = textPosition2 {
                textPosition1 = textView.position(from: textPosition1!, offset: -1)
                textPosition2 = textView.position(from: textPosition1!, offset: 1)
            } else  {
                return ""
            }
        }
        
        let range = textView.textRange(from: textPosition1!, to: textPosition2!)
        let startOffset = textView.offset(from: textView.beginningOfDocument, to: range!.start)
        let endOffset = textView.offset(from:textView.beginningOfDocument, to: range!.end)
        let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
        if offsetRange.location == NSNotFound || offsetRange.length == 0 {
            return ""
        }
        
        if NSMaxRange(offsetRange) > textView.attributedText.length {
            return ""
        }
        
        let attributedSubstring = textView.attributedText.attributedSubstring(from: offsetRange)
        let link = attributedSubstring.attribute(NSAttributedStringKey.link, at: 0, effectiveRange: nil)
        
        if let linkStr = link {
            return ((linkStr as AnyObject).absoluteString as? String)!
        }
        
        return ""
    }
}
