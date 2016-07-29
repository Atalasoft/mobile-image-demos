//
//  WaitingIndicator.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 07/06/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import UIKit

class WaitingIndicator: UIView {
    
    var message = UILabel()
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    let messageLabelHeight: CGFloat = 30
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let screenRect = UIScreen.mainScreen().bounds
        
        frame = CGRectMake(0, 0, screenRect.width, screenRect.height)
        
        let labelFrame = CGRectMake(30, screenRect.midY - messageLabelHeight / 2, screenRect.width - 60, messageLabelHeight)
        message.frame = labelFrame
        
        let indicatorSize = indicator.frame.size
        let indicatorRect = CGRectMake(screenRect.midX - indicatorSize.width / 2 , labelFrame.minY - 20 - indicatorSize.height, indicatorSize.width, indicatorSize.height)
        indicator.frame = indicatorRect
    }
    
    func show(text: String, superview: UIView) {
        message.text = text
        indicator.startAnimating()
        
        message.textColor = UIColor.whiteColor()
        message.textAlignment = .Center
        message.font = message.font.fontWithSize(24)
        message.adjustsFontSizeToFitWidth = true
        
        addSubview(message)
        addSubview(indicator)
        
        backgroundColor = UIColor.grayColor()
        alpha = 0.5
        
        superview.addSubview(self)
        superview.bringSubviewToFront(self)
    }
    
    func hide() {
        message.removeFromSuperview()
        indicator.removeFromSuperview()
        hidden = true
        removeFromSuperview()
    }
    
    func updateMessage(text: String) {
        message.text = text
    }
}
 