//
//  OverlayView.swift
//  Koloda
//
//  Created by Eugene Andreyev on 4/24/15.
//  Copyright (c) 2015 Eugene Andreyev. All rights reserved.
//

import UIKit

public enum OverlayMode{
    case None
    case Left
    case Right
}


public class OverlayView: UIView {
    
    public var overlayState:OverlayMode = OverlayMode.None

}

class VotingOverlayView: OverlayView {
    
    let pos = UIImage(named: "PositiveVote.png")
    let neg = UIImage(named: "NegativeVote.png")
    
    @IBOutlet lazy var overlayImageView: UIImageView! = {
        [unowned self] in
        
        var imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        
        return imageView
        }()
    
    override var overlayState:OverlayMode  {
        didSet {
            switch overlayState {
            case .Left :
                // Pale Red: 0.973, 0.698, 0.698
                overlayImageView.image = UIImage().makeImageWithColorAndSize(UIColor(red: 0.973, green: 0.598, blue: 0.598, alpha: 0.50), size: CGSizeMake(frame.width, frame.height))
            case .Right :
                //Pale Green: 0.702, 0.855, 0.651
                overlayImageView.image = UIImage().makeImageWithColorAndSize(UIColor(red: 0.702, green: 0.955, blue: 0.651, alpha: 0.50), size: CGSizeMake(frame.width, frame.height))
            default:
                overlayImageView.image = nil
            }
            
        }
    }
    
}

extension UIImage {
    func makeImageWithColorAndSize(backColor: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        backColor.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}