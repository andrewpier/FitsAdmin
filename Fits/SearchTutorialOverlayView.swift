//
//  SearchTutorialOverlayView.swift
//  Fits
//
//  Created by Stephen Tam on 7/7/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class SearchTutorialOverlayView: UIView {
    var instruction: SearchInstructionLabel!
    var footer: SearchTutorialFooter!
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Dark))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        //setup the blurrrrr
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(blurEffectView)
        
        //setup instruction
        let welcomeLabelOrigin = CGPoint(x: 0, y: 20)
        let welcomeLabelFrame = CGRect(origin: welcomeLabelOrigin, size: CGSize(width: self.frame.width, height: 200))
        instruction = SearchInstructionLabel(frame: welcomeLabelFrame)
        self.addSubview(instruction)

        //setup footer
        let footerOrigin = CGPoint(x: 0, y: self.frame.height*0.75)
        let footerFrame = CGRect(origin: footerOrigin, size: CGSize(width: self.frame.width, height: self.frame.height*0.1))
        footer = SearchTutorialFooter(frame: footerFrame, text: "Tap anywhere to continue")
        self.addSubview(footer)
    }

}
