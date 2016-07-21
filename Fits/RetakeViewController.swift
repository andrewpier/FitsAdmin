//
//  RetakeViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 1/20/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class RetakeViewController: UIViewController {

    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var retakeButton: UIButton!
    @IBOutlet weak var useImageButton: UIButton!
    
    var imageTaken: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("loaded retake view")
        if(imageTaken  != nil){
            photo.image = imageTaken
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func retake(sender: UIButton) {
        imageTaken = nil;
        photo.image = nil;
    }

    @IBAction func useImage(sender: UIButton) {
        //Save the captured preview to image
        UIImageWriteToSavedPhotosAlbum(photo.image!, nil, nil, nil)
        
        // push to upload view
       let uploadView = self.storyboard?.instantiateViewControllerWithIdentifier("UploadView") as! UploadViewController
        self.navigationController?.pushViewController(uploadView, animated: true)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.destinationViewController.isKindOfClass(UploadViewController)){
            //save the image to a file so the upload view can load it in 
            if let image = self.photo.image{
                if let data = UIImageJPEGRepresentation(image, 1.0) {
                    //check to see what images are already there 
                    let imageName = getImageName()
                    let filename = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
                    data.writeToFile(filename, atomically: true)
                }
            }
            
            //set the image in the Upload View to the one that was taken
            let destViewController = segue.destinationViewController as! UploadViewController
            destViewController.photoTaken = self.photo.image
        }
    }
    func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImageName() -> String{
        //start with album image
        let imageNames = ["albumImage.JPEG","topRightImage.JPEG", "middleRightImage.JPEG", "bottomRightImage.JPEG", "bottomMiddleImage.JPEG", "bottomLeftImage.JPEG"]
        let manager = NSFileManager.defaultManager()
        for name in imageNames {
            let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(name)
            if(manager.fileExistsAtPath(imagePath)){
                print("\(name) already taken")
            }else {
                return name
            }
        }
        //if it gets to here just reset albumimage
        return "albumImage.JPEG"
    }
}

