//
//  ClearGalleriesCell.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse

protocol ClearGalleriesCellDelegate{
    func clearGallery(button: UIButton, gallery: GalleriesViewController.Gallery)
}

class ClearGalleriesCell: UITableViewCell {
    @IBOutlet weak var clearGalleryButton: UIButton!
    
    var gallery: GalleriesViewController.Gallery!
    var delegate: ClearGalleriesCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTap() {
        delegate.clearGallery(clearGalleryButton, gallery: self.gallery)
        clearGalleryButton.alpha = 0.5
        clearGalleryButton.enabled = false
    }
    
}
