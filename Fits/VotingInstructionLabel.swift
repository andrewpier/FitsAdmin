//
//  VotingInstructionLabel.swift
//  Fits
//
//  Created by Stephen Tam on 7/4/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class VotingTutorialInstructionLabel: UILabel {
    
    var instructionText = ""
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    init(frame: CGRect, instruction: String) {
        super.init(frame: frame)
        self.instructionText = instruction
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    
    func commonInit() {
        self.text = instructionText
        self.textColor = UIColor.whiteColor()
        self.textAlignment = .Center
        self.font = self.font.fontWithSize(18)
        self.preferredMaxLayoutWidth = self.frame.width
        self.lineBreakMode = .ByWordWrapping
        self.numberOfLines = 0
    }
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        return false
    }

}
