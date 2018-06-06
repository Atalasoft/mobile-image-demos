//
//  WaitingIndicator.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 07/06/16.
//  Copyright © 2016-2018 Atalasoft. All rights reserved.
//

import UIKit

class WaitingIndicator: UIView {
    
    var message = UILabel()
    var indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    let messageLabelHeight: CGFloat = 30
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let screenRect = UIScreen.main.bounds
        
        frame = CGRect(x:0, y:0, width:screenRect.width, height:screenRect.height)
        
        let labelFrame = CGRect(x:30, y:screenRect.midY - messageLabelHeight / 2, width:screenRect.width - 60, height:messageLabelHeight)
        message.frame = labelFrame
        
        let indicatorSize = indicator.frame.size
        let indicatorRect = CGRect(x:screenRect.midX - indicatorSize.width / 2 , y:labelFrame.minY - 20 - indicatorSize.height, width:indicatorSize.width, height:indicatorSize.height)
        indicator.frame = indicatorRect
    }
    
    func show(text: String, superview: UIView) {
        message.text = text
        indicator.startAnimating()
        
        message.textColor = UIColor.white
        message.textAlignment = .center
        message.font = message.font.withSize(24)
        message.adjustsFontSizeToFitWidth = true
        
        addSubview(message)
        addSubview(indicator)
        
        backgroundColor = UIColor.gray
        alpha = 0.5
        
        superview.addSubview(self)
        superview.bringSubview(toFront: self)
    }
    
    func hide() {
        message.removeFromSuperview()
        indicator.removeFromSuperview()
        isHidden = true
        removeFromSuperview()
    }
    
    func updateMessage(text: String) {
        message.text = text
    }
}
 
