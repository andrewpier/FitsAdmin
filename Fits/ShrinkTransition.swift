//
//  ShrinkTransition.swift
//  Fits
//
//  Created by Darren Moyer on 2/12/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class ShrinkTransition: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        print(secondVCView.frame)
        
        // Get the screen width and height.
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // Specify the initial position of the destination view.
        //secondVCView.frame = CGRect(x: 0.0, y: 0.0, width: screenWidth, height: screenHeight)
        //print(secondVCView.frame)
        //firstVCView.frame = CGRectMake(0.0, 0.0, screenWidth, screenHeight)
        
        firstVCView.clipsToBounds = true
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.sharedApplication().keyWindow
        window?.addSubview(secondVCView)
        window?.addSubview(firstVCView)
        window?.bringSubviewToFront(firstVCView)
        
        // Animate the transition.
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(CGRect(x: screenWidth/2, y: screenHeight/2, width: 0.0, height: 0.0), 0.0, 0.0)
            //secondVCView.frame = CGRectOffset(secondVCView.frame, 0.0, 0.0)
            
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController as UIViewController,
                    animated: false,
                    completion: nil)
        }
        
    }
}

/*
*/