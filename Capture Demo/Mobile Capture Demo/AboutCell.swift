//
//  AboutCell.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 23/06/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class AboutCell: UITableViewCell {
    
    @IBOutlet var versionLabel: UILabel!
    @IBOutlet var appNameLabel: UILabel!
    @IBOutlet var text1Label: UITextView!
    @IBOutlet var text2Label: UITextView!
    @IBOutlet var emailLabel: UITextView!
    
    var linkTapGestureRecognizer: UITapGestureRecognizer!
    
    func makeLink(text: NSMutableAttributedString, linkText: String, linkUrl: String) {
        
        let linkRange = (text.string as NSString).rangeOfString(linkText)
        text.addAttribute(NSLinkAttributeName, value: linkUrl, range: linkRange)
    }
    
    func setupAboutData() {
        
        if linkTapGestureRecognizer == nil {
            linkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapGestureRecognizer))
            linkTapGestureRecognizer.cancelsTouchesInView = false
            linkTapGestureRecognizer.delaysTouchesBegan = false
            linkTapGestureRecognizer.delaysTouchesEnded = false
            addGestureRecognizer(linkTapGestureRecognizer)
        }
        
        let appVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"];
        if let ver = appVersion {
            versionLabel.text = "Version \(ver)"
        }
        
        appNameLabel.text = "Atalasoft MobileImage Capture sample app"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Justified
        
        let text1 = NSMutableAttributedString(string: "This app shows developers what they could build with the Atalasoft MobileImage Capture SDK. When the user opens the camera, the software can guide them to take the image at the right angle. Access to the camera torch is enabled. Finally, the image taken is processed and cleaned up with eVRS and ready for a backend server process like OCR or storage.", attributes: [
            NSParagraphStyleAttributeName: paragraphStyle,
            NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
        
        text1Label.attributedText = text1
        
        let text2 = NSMutableAttributedString(string: "To build your own document capture, processing, or viewing app - visit Atalasoft and grab a 30-day evaluation copy for yourself. We'll provide the tools and the support you need to get started!", attributes: [
                NSParagraphStyleAttributeName: paragraphStyle,
                NSBaselineOffsetAttributeName: NSNumber(float: 0)
            ])
            
        makeLink(text2, linkText: "Atalasoft", linkUrl: "http://hubs.ly/H03pzS80")
        text2Label.attributedText = text2
        
        
        let email = NSMutableAttributedString(string: "sales@atalasoft.com")
        let emailUrl = "sales@atalasoft.com"
        
        makeLink(email, linkText: emailUrl, linkUrl: "mailto:sales@atalasoft.com")
        emailLabel.attributedText = email
    }
    
    func handleLinkTapGestureRecognizer(tapRecognizer: UITapGestureRecognizer) {
        
        let view = tapRecognizer.view
        let location = tapRecognizer.locationInView(view)
        
        var linkStr = ""
        
        if CGRectContainsPoint(text2Label.frame, location) {
            linkStr = getLinkOnText(tapRecognizer.locationInView(text2Label), textView: text2Label)
        } else if CGRectContainsPoint(emailLabel.frame, location) {
            linkStr = getLinkOnText(tapRecognizer.locationInView(emailLabel), textView: emailLabel)
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
            return linkStr as! String
        }
        
        return ""
    }
}
