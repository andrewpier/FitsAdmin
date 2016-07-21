//
//  SwitchCell.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
protocol SwitchCellDelegate : class {
    func didChangeSwitchState(sender: SwitchCell, isOn: Bool)
}
class SwitchCell: UITableViewCell {
    

    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var label: UILabel!
    var delegate: SwitchCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellSwitch.onTintColor = ACCENTCOLOR
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchFlipped() {
        if(cellSwitch.on) {
            cellSwitch.onTintColor = ACCENTCOLOR.colorWithAlphaComponent(0.5)
            print("\(label.text) switch was flipped on")
        } else {
            print("\(label.text) switch was flipped off")
        }
        delegate.didChangeSwitchState(self, isOn: cellSwitch.on)
    }

}
