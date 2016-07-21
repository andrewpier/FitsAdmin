//
//  CommentTableViewCell.swift
//  Fits
//
//  Created by Sophia Gebert on 2/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
