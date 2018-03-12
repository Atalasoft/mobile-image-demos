//
//  AboutCell.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 23/06/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
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
        
        let linkRange = (text.string as NSString).range(of: linkText)
        text.addAttribute(NSAttributedStringKey.link, value: linkUrl, range: linkRange)
    }
    
    func setupAboutData() {
        
        if linkTapGestureRecognizer == nil {
            linkTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLinkTapGestureRecognizer))
            linkTapGestureRecognizer.cancelsTouchesInView = false
            linkTapGestureRecognizer.delaysTouchesBegan = false
            linkTapGestureRecognizer.delaysTouchesEnded = false
            addGestureRecognizer(linkTapGestureRecognizer)
        }
        
        let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"];
        if let ver = appVersion {
            versionLabel.text = "Version \(ver)"
        }
        
        appNameLabel.text = "Atalasoft MobileImage Capture sample app"
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.justified
        
        let text1 = NSMutableAttributedString(string: "This app shows developers what they could build with the Atalasoft MobileImage Capture SDK. When the user opens the camera, the software can guide them to take the image at the right angle. Access to the camera torch is enabled. Finally, the image taken is processed and cleaned up with eVRS and ready for a backend server process like OCR or storage.", attributes: [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.baselineOffset: NSNumber(value: 0)
            ])
        
        text1Label.attributedText = text1
        
        let text2 = NSMutableAttributedString(string: "To build your own document capture, processing, or viewing app - visit Atalasoft and grab a 30-day evaluation copy for yourself. We'll provide the tools and the support you need to get started!", attributes: [
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.baselineOffset: NSNumber(value: 0)
            ])
            
        makeLink(text: text2, linkText: "Atalasoft", linkUrl: "http://hubs.ly/H03pzS80")
        text2Label.attributedText = text2
        
        
        let email = NSMutableAttributedString(string: "sales@atalasoft.com")
        let emailUrl = "sales@atalasoft.com"
        
        makeLink(text: email, linkText: emailUrl, linkUrl: "mailto:sales@atalasoft.com")
        emailLabel.attributedText = email
    }
    
    @objc func handleLinkTapGestureRecognizer(tapRecognizer: UITapGestureRecognizer) {
        
        let view = tapRecognizer.view
        let location = tapRecognizer.location(in: view)
        
        var linkStr = ""
        
        if text2Label.frame.contains(location) {
            linkStr = getLinkOnText(location: tapRecognizer.location(in: text2Label), textView: text2Label)
        } else if emailLabel.frame.contains(location) {
            linkStr = getLinkOnText(location: tapRecognizer.location(in: emailLabel), textView: emailLabel)
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
        let endOffset = textView.offset(from: textView.beginningOfDocument, to: range!.end)
        let offsetRange = NSMakeRange(startOffset, endOffset - startOffset)
        if offsetRange.location == NSNotFound || offsetRange.length == 0 {
            return ""
        }
        
        if NSMaxRange(offsetRange) > textView.attributedText.length {
            return ""
        }
        
        let attributedSubstring = textView.attributedText .attributedSubstring(from: offsetRange)
        let link = attributedSubstring.attribute(NSAttributedStringKey.link, at: 0, effectiveRange: nil)
        
        if let linkStr = link {
            return linkStr as! String
        }
        
        return ""
    }
}
