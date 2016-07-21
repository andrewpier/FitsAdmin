//
//  VotingTutorialView.swift
//  Fits
//
//  Created by Stephen Tam on 7/4/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class VotingTutorialView: UIView {
    
    var header: WelcomeTutorialLabel!
    var instruction: VotingTutorialInstructionLabel!
    var footer: VotingTutorialFooter!

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        //setup header
        let welcomeLabelOrigin = CGPoint(x: 0, y: 20)
        let welcomeLabelFrame = CGRect(origin: welcomeLabelOrigin, size: CGSize(width: self.frame.width, height: 200))
        header = WelcomeTutorialLabel(frame: welcomeLabelFrame)
        self.addSubview(header)
        
        //setup instruction
        let instructionOrigin = CGPoint(x: self.frame.width*0.2, y: self.frame.height*0.65)
        let instructionFrame = CGRect(origin: instructionOrigin, size: CGSize(width: self.frame.width*0.6, height: self.frame.height*0.1))
        instruction = VotingTutorialInstructionLabel(frame: instructionFrame, instruction: "Swipe right if you like an outfit, left if you don't.")
        self.addSubview(instruction)
        
        //setup footer
        let footerOrigin = CGPoint(x: 0, y: self.frame.height*0.75)
        let footerFrame = CGRect(origin: footerOrigin, size: CGSize(width: self.frame.width, height: self.frame.height*0.1))
        footer = VotingTutorialFooter(frame: footerFrame, text: "Tap anywhere to start")
        self.addSubview(footer)
    }


}
