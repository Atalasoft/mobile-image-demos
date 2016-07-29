//
//  LicenseAgreementCell.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 30/06/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class LicenseAgreementCell: UITableViewCell {
    
    @IBOutlet var license: UITextView!
    
    var linkTapGestureRecognizer: UITapGestureRecognizer!
    
    func makeLink(text: NSMutableAttributedString, linkText: String, linkUrl: String) {
        
        let linkRange = (text.string as NSString).rangeOfString(linkText)
        text.addAttribute(NSLinkAttributeName, value: linkUrl, range: linkRange)
    }
    
    func setupLicenseData() {
        
        if linkTapGestureRecognizer == nil {
            linkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapGestureRecognizer))
            linkTapGestureRecognizer.cancelsTouchesInView = false
            linkTapGestureRecognizer.delaysTouchesBegan = false
            linkTapGestureRecognizer.delaysTouchesEnded = false
            addGestureRecognizer(linkTapGestureRecognizer)
        }
        
        let path = NSBundle.mainBundle().pathForResource("eula", ofType: "rtf")
        do {
            let text = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
            
            let eula = try NSMutableAttributedString(data: text.dataUsingEncoding(NSUTF8StringEncoding)!, options: [NSDocumentTypeDocumentAttribute:NSRTFTextDocumentType], documentAttributes: nil)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = NSTextAlignment.Justified
            paragraphStyle.hyphenationFactor = 1
            
            eula.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, eula.length))
            makeLink(eula, linkText: "www.kofax.com", linkUrl: "http://www.kofax.com")
            
            license.attributedText = eula
        } catch {
        }
    }
    
    func handleLinkTapGestureRecognizer(tapRecognizer: UITapGestureRecognizer) {
        
        let view = tapRecognizer.view
        let location = tapRecognizer.locationInView(view)
        
        var linkStr = ""
        
        if CGRectContainsPoint(license.frame, location) {
            linkStr = getLinkOnText(tapRecognizer.locationInView(license), textView: license)
        }
        
        if !linkStr.isEmpty {
            let url: NSURL! = NSURL(string: linkStr)
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func getLinkOnText(location: CGPoint, textView: UITextView) -> String {
        
        var textPosition1 = textView.closestPositionToPoint(location)
        var textPosition2:UITextPosition?
        if let _ = textPosition1 {
            textPosition2 = textView.positionFromPosition(textPosition1!, offset: 1)
            if let _ = textPosition2 {
                textPosition1 = textView.positionFromPosition(textPosition1!, offset: -1)
                textPosition2 = textView.positionFromPosition(textPosition1!, offset: 1)
            } else  {
                return ""
            }
        }
        
        let range = textView.textRangeFromPosition(textPosition1!, toPosition: textPosition2!)
        let startOffset = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: range!.start)
        let endOffset = textView.offsetFromPosition(textView.beginningOfDocument, toPosition: range!.end)
        let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
        if offsetRange.location == NSNotFound || offsetRange.length == 0 {
            return ""
        }
        
        if NSMaxRange(offsetRange) > textView.attributedText.length {
            return ""
        }
        
        let attributedSubstring = textView.attributedText .attributedSubstringFromRange(offsetRange)
        let link = attributedSubstring.attribute(NSLinkAttributeName, atIndex: 0, effectiveRange: nil)
        
        if let linkStr = link {
            return linkStr.absoluteString
        }
        
        return ""
    }
}
