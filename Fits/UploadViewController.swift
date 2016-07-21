//
//  UploadViewController.swift
//  Fits
//
//  Created by Darren Moyer on 1/25/16.
//  Editions by Sophia Gebert
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation
import UIKit
import Parse

class UploadViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{
    
    //Main Container Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentsView: UIView!
    
    //Image Outlets
    @IBOutlet weak var albumImage: UIImageView!
    @IBOutlet weak var topRightImage: UIImageView!
    @IBOutlet weak var middleRightImage: UIImageView!
    @IBOutlet weak var bottomLeftImage: UIImageView!
    @IBOutlet weak var bottomMiddleImage: UIImageView!
    @IBOutlet weak var bottomRightImage: UIImageView!
    
    //Controls Outlets
    @IBOutlet weak var contextCharacterCounter: UILabel!
    @IBOutlet weak var outfitContextTextView: UITextView!
    @IBOutlet weak var tagsTextField: UITextField!
    @IBOutlet weak var allowCommentsSwitch: UISwitch!
    @IBOutlet weak var allowCommentsLabel: UILabel!
    
    
    @IBOutlet weak var uploadButton: UIButton!
    var id : String = ""
    var postID = ""
    var imageCount = 0
    var activeField: UITextField?
    var activeFieldView: UITextView?

    //Gestures
    let tapTRSingle = UITapGestureRecognizer()
    let tapMRSingle = UITapGestureRecognizer()
    let tapBLSingle = UITapGestureRecognizer()
    let tapBMSingle = UITapGestureRecognizer()
    let tapBRSingle = UITapGestureRecognizer()
    
    
    var oldSize: CGFloat = 0
    var photoTaken: UIImage!
    override func viewDidLoad() {
        //Setting the content height so it actually scrolls if it need to
        //scrollView.contentSize = CGSize(width: contentsView.frame.width , height: contentsView.frame.height)
        
        super.viewDidLoad()
        
        registerForKeyboardNotifications()
        self.outfitContextTextView.delegate = self
        self.tagsTextField.delegate = self
        
        allowCommentsSwitch.onTintColor = ACCENTCOLOR
        
        albumImage.layer.borderWidth = 1
        albumImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        topRightImage.layer.borderWidth = 1
        topRightImage.layer.borderColor = UIColor.whiteColor().CGColor
        middleRightImage.layer.borderWidth = 1
        middleRightImage.layer.borderColor = UIColor.whiteColor().CGColor
        bottomLeftImage.layer.borderWidth = 1
        bottomLeftImage.layer.borderColor = UIColor.whiteColor().CGColor
        bottomMiddleImage.layer.borderWidth = 1
        bottomMiddleImage.layer.borderColor = UIColor.whiteColor().CGColor
        bottomRightImage.layer.borderWidth = 1
        bottomRightImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        
        tagsTextField.attributedPlaceholder = NSAttributedString(string:tagsTextField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        
        uploadButton.layer.borderWidth = 1
        uploadButton.layer.borderColor = UIColor(white: 1.0, alpha: 0.35).CGColor
        
        allowCommentsSwitch.on = false
        
        contextCharacterCounter.textColor = UIColor(white: 1.0, alpha: 0.35)
        
        imageCount = 0
        setImages()
        print(PFUser.currentUser())
        setupGestures()
        oldSize = self.view.frame.height
        print("loaded Upload View")
    }
    override func viewWillDisappear(animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    @IBAction func uploadButtonClicked(sender: UIButton) {
        PostOutfit()
        print("Outfit Posted")
        //reset the image thumbnails to + image
        let image = UIImage(named: "AddIcon.png")
        albumImage.image = image
        topRightImage.image = image
        middleRightImage.image = image
        bottomLeftImage.image = image
        bottomRightImage.image = image
        bottomMiddleImage.image = image
        
        
        //        //iTry to iterte and find the tab bar controller...
        //        if let viewControllers = navigationController?.viewControllers {
        //            for viewController in viewControllers {
        //                if viewController.nibName == "Tab Bar Controller"{
        //                    //this may be bad practice, check with Dellinger
        //                    self.navigationController?.pushViewController(viewController, animated: true)
        //                }
        //            }
        //        }else{
        //            //no view controllers have been pushed on the stack...
        //
        //            let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //            let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Tab Bar Controller") as UIViewController
        //            self.presentViewController(vc, animated: true, completion: nil)
        //
        //        }
        
    }
   
    
    @IBAction func xButtonTapped(sender: UIButton) {
        //Mabe provide alert here that progress will be deleted
        
        //Delete the images on exit
        deleteAllImages()
        
        //iTry to iterte and find the tab bar controller...
        /*if let viewControllers = navigationController?.viewControllers {
         for viewController in viewControllers {
         if viewController.nibName == "Tab Bar Controller"{
         //this may be bad practice, check with Dellinger
         self.navigationController?.pushViewController(viewController, animated: true)
         }
         }
         }else{
         //no view controllers have been pushed on the stack...
         
         let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
         let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Tab Bar Controller") as UIViewController
         self.presentViewController(vc, animated: true, completion: nil)
         
         }*/
    }
    
    
    @IBAction func AllowCommentsValueChanged(sender: AnyObject) {
        if (allowCommentsSwitch.on){
            allowCommentsLabel.textColor = UIColor.whiteColor()
        } else {
            allowCommentsLabel.textColor = UIColor(white: 1.0, alpha: 0.35)
        }
    }
    
    
    
    
    /////////////////////////////////////////////
    /////  Handeling uploading the content  /////
    /////////////////////////////////////////////
    
    func PostOutfit(){
        //Original Post Object
        let postObject = getPostObject()
        let statObj = getStatObject(postObject)
        postObject.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            // Handle success or failure here ...
            if succeeded{
                print("Uploaded Successfully")
                print(postObject.objectId! + " : NEED THIS")
                self.id = postObject.objectId!
                NSNotificationCenter.defaultCenter().postNotificationName("UploadedPostNotification", object: nil)
                //Post Statistics Object
                //(Need to do in here so we are sure we get teh objectId)
                statObj["ParentObjectId"] = postObject.objectId!
                self.SaveObject(statObj)
                self.saveTags(postObject.objectId!)
                
            } else {
                print("Upload Failed")
            }
        })
        
        //Post Text Information Object
        var postChild = getTextObject(postObject)
        SaveObject(postChild)
        
        //Post Images Fullsize Object
        postChild = getImageObject(postObject)
        SaveObject(postChild)
        
        //delete the images after upload
        deleteAllImages()
    }
    
    func SaveObject(myObj: PFObject){
        myObj.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            // Handle success or failure here ...
            if succeeded{
                print("Uploaded Successfully")
                //print(myObj.objectId)
                //self.id = myObj.objectId!
            } else {
                print("Upload Failed")
            }
        })
        
    }
    
    func getPostObject() -> PFObject{
        let allowComments: Bool = allowCommentsSwitch.on
        let myArray = tagsTextField.text
        //if(tagsTextField != nil && tagsTextField != ""){
        //let tagsArray = split(myArray, isSeparator:" ")
        let tagsArray = myArray!.characters.split{$0 == " "}.map(String.init)
        
        let myObj = PFObject(className: "Post")
        myObj["AllowComments"] = allowComments
        myObj.addUniqueObjectsFromArray([tagsArray], forKey:"Tags")//need the object id for the post
        myObj["BelongsTo"] = PFUser.currentUser()
        myObj["Thumbnail"] = PFFile(name:"Thumbnail.JPEG", data:cropToBounds(albumImage.image!, width: 370, height: 370).lowestQualityJPEGNSData)
        myObj["ThumbnailRect"] = PFFile(name:"Thumbnail.JPEG", data:albumImage.image!.lowestQualityJPEGNSData)
        
        return myObj
    }
    
    func saveTags(postID: String) {
        let myArray = tagsTextField.text
        var tagsArray = myArray!.characters.split{$0 == ","}.map(String.init)
        
        print(tagsArray)
        for i in 0..<tagsArray.count{
            tagsArray[i] = tagsArray[i].stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet()
            )
        }
        print(tagsArray)
        
        PFCloud.callFunctionInBackground("addTags", withParameters: ["tags": tagsArray,"num": tagsArray.count, "postID": postID]) { (response: AnyObject?, error: NSError?) -> Void in }
    }
    
    func getStatObject(postID: PFObject) -> PFObject{
        let myObj = PFObject(className: "PostStatistics")
        myObj["PositiveVotes"] = 0
        myObj["NegativeVotes"] = 0
        myObj["BelongsTo"] = postID
        
        return myObj
    }
    
    
    func getImageObject(postDisplayID: PFObject) -> PFObject{
        let myObj = PFObject(className: "PostImages")
        
        let image = UIImage(named: "AddIcon.png")
        
        if albumImage.image! == image {
            print("\tAI is the add icon image!")
        } else {
            print("Shit")
        }
        
        if topRightImage.image! == image {
            print("\tTR is the add icon image!")
            
        }
        
        if middleRightImage.image! == image {
            print("\tMR is the add icon image!")
        }
        
        if bottomLeftImage.image! == image {
            print("\tBL is the add icon image!")
        }
        
        if bottomMiddleImage.image! == image {
            print("\tBM is the add icon image!")
        }
        
        if bottomRightImage.image! == image {
            print("\tBR is the add icon image!")
        }
        
        print(" -----------   \(imageCount)   -----------")
        
        
        switch imageCount {
        case 6:
            myObj["Image5"] = PFFile(name: "bottomRightImage.JPEG", data: (bottomRightImage.image?.highestQualityJPEGNSData)!)
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image2"] = PFFile(name: "middleRightImage.JPEG", data: (middleRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image3"] = PFFile(name: "bottomLeftImage.JPEG", data: (bottomLeftImage.image?.highestQualityJPEGNSData)!)
            myObj["Image4"] = PFFile(name: "bottomMiddleImage.JPEG", data: (bottomMiddleImage.image?.highestQualityJPEGNSData)!)
            break
        case 5:
            myObj["Image4"] = PFFile(name: "bottomMiddleImage.JPEG", data: (bottomMiddleImage.image?.highestQualityJPEGNSData)!)
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image2"] = PFFile(name: "middleRightImage.JPEG", data: (middleRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image5"] = PFFile(name: "bottomRightImage.JPEG", data: (bottomRightImage.image?.highestQualityJPEGNSData)!)
            break
        case 4:
            myObj["Image5"] = PFFile(name: "bottomRightImage.JPEG", data: (bottomRightImage.image?.highestQualityJPEGNSData)!)
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image2"] = PFFile(name: "middleRightImage.JPEG", data: (middleRightImage.image?.highestQualityJPEGNSData)!)
            break
        case 3:
            myObj["Image2"] = PFFile(name: "middleRightImage.JPEG", data: (middleRightImage.image?.highestQualityJPEGNSData)!)
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            break
        case 2:
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            break
        case 1:
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            break
        default:
            myObj["AlbumImage"] = PFFile(name: "albumImage.JPEG", data: (albumImage.image?.highestQualityJPEGNSData)!)
            myObj["Image1"] = PFFile(name: "topRightImage.JPEG", data: (topRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image2"] = PFFile(name: "middleRightImage.JPEG", data: (middleRightImage.image?.highestQualityJPEGNSData)!)
            myObj["Image3"] = PFFile(name: "bottomLeftImage.JPEG", data: (bottomLeftImage.image?.highestQualityJPEGNSData)!)
            myObj["Image4"] = PFFile(name: "bottomMiddleImage.JPEG", data: (bottomMiddleImage.image?.highestQualityJPEGNSData)!)
            myObj["Image5"] = PFFile(name: "bottomRightImage.JPEG", data: (bottomRightImage.image?.highestQualityJPEGNSData)!)
            break
        }
        
        myObj["BelongsTo"] = postDisplayID
        
        return myObj
    }
    
    func getTextObject(postDisplayID: PFObject) -> PFObject{
        let myArray = [""]
        var context = ""
        if outfitContextTextView.text! != "Provide some context with your outfit" {
            context = outfitContextTextView.text!
        }
        let myObj = PFObject(className: "PostTextItems")
        myObj["Comments"] = myArray
        myObj["UsersPostInformation"] = context
        myObj["BelongsTo"] = postDisplayID
        
        return myObj
    }
    
    
    
    
    /////////////////////////////////////////////
    /////       Handeling Tap Gestures      /////
    /////////////////////////////////////////////
    
    func setupGestures(){
        tapTRSingle.addTarget(self, action: #selector(UploadViewController.TappedtopRightImage))
        topRightImage.addGestureRecognizer(tapTRSingle)
        topRightImage.userInteractionEnabled = true
        
        tapMRSingle.addTarget(self, action: #selector(UploadViewController.TappedmiddleRightImage))
        middleRightImage.addGestureRecognizer(tapMRSingle)
        middleRightImage.userInteractionEnabled = true
        
        tapBLSingle.addTarget(self, action: #selector(UploadViewController.TappedbottomLeftImage))
        bottomLeftImage.addGestureRecognizer(tapBLSingle)
        bottomLeftImage.userInteractionEnabled = true
        
        tapBMSingle.addTarget(self, action: #selector(UploadViewController.TappedbottomMiddleImage))
        bottomMiddleImage.addGestureRecognizer(tapBMSingle)
        bottomMiddleImage.userInteractionEnabled = true
        
        tapBRSingle.addTarget(self, action: #selector(UploadViewController.TappedbottomRightImage))
        bottomRightImage.addGestureRecognizer(tapBRSingle)
        bottomRightImage.userInteractionEnabled = true
    }
    
    func TappedtopRightImage(){
        print("The Top Right Image was tapped!")
        topRightImage.image = nil
        tappedImageHandler("topRightImage.JPEG")
    }
    
    func TappedmiddleRightImage(){
        print("The Middle Right Image was tapped!")
        middleRightImage.image = nil
        tappedImageHandler("middleRightImage.JPEG")
    }
    
    func TappedbottomLeftImage(){
        print("The Bottom Left Image was tapped!")
        bottomLeftImage.image = nil
        tappedImageHandler("bottomLeftImage.JPEG")
    }
    
    func TappedbottomMiddleImage(){
        print("The Bottom Middle Image was tapped!")
        bottomMiddleImage.image = nil
        tappedImageHandler("bottomMiddleImage.JPEG")
    }
    
    func TappedbottomRightImage(){
        print("The Bottom Right Image was tapped!")
        bottomRightImage.image = nil
        tappedImageHandler("bottomRightImage.JPEG")
    }
    
    func tappedImageHandler(imageName: String) {
        photoTaken = nil
        let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
        let manager = NSFileManager.defaultManager()
        //if the image exists, delete it
        if(manager.fileExistsAtPath(imagePath)){
            do{
                try manager.removeItemAtPath(imagePath)
                print("Deleted - " + imageName)
            }catch let error as NSError{
                print(error.description)
                print("Unable to delete " + imageName)
            }
        }
        //Iterate through the view controllers on the stack until you find the camera one
        //no view controllers have been pushed on the stack...
        let cameraView = self.storyboard?.instantiateViewControllerWithIdentifier("CameraView") as! CameraViewController
        cameraView.cameFromUploadView = true
        self.presentViewController(cameraView, animated: true, completion: nil)
    }
    
    
    
    /////////////////////////////////////////////
    /////   Handeling the textview content  /////
    /////////////////////////////////////////////
    
    func textViewDidChange(textView: UITextView) {
        if (textView.text.characters.count > 140){
            var content = textView.text.characters
            while (content.count > 140){
                content.removeLast()
            }
            textView.text = String(content)
            contextCharacterCounter.text = "0"
        } else {
            contextCharacterCounter.text = String(140 - textView.text.characters.count)
        }
    }
    
  
    
    
    
    ////////////////////////////////////////////
    /////   Moving the view for textviews  /////
    ////////////////////////////////////////////
    
    var TextfieldSelectedForEditingLocation: CGPoint!
    
    @IBAction func TouchUpInsideField(sender: UIView) {
        let globalPoint = sender.superview?.convertPoint(sender.frame.origin, toView: nil)
        print(globalPoint)
        TextfieldSelectedForEditingLocation = globalPoint
    }
    
    func registerForKeyboardNotifications()
    {
        //Adding notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UploadViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications()
    {
        //Removing notifies on keyboard appearing
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.scrollEnabled = true
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField
        {
            if (!CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                let rect = CGRectMake(activeFieldPresent.frame.minX, activeFieldPresent.frame.minY, activeFieldPresent.frame.width, activeFieldPresent.frame.height+50)
                self.scrollView.scrollRectToVisible(rect, animated: true)
                
            }
        }
        
        else if let activeFieldPresent = outfitContextTextView
        {
            if (CGRectContainsPoint(aRect, activeFieldPresent.frame.origin))
            {
                let rect = CGRectMake(activeFieldPresent.frame.minX, activeFieldPresent.frame.minY, activeFieldPresent.frame.width, activeFieldPresent.frame.height+50)
                self.scrollView.scrollRectToVisible(rect, animated: true)
                
            }
        }
    }
    func keyboardWillBeHidden(notification: NSNotification)
    {
        //Once keyboard disappears, restore original positions
        let info : NSDictionary = notification.userInfo!
        
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0,self.view.frame.height-keyboardSize!.height*2, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.scrollEnabled = true
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if (textView.text == "Provide some context with your outfit") {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
        activeFieldView = textView
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Provide some context with your outfit"
            textView.textColor = UIColor(white: 1.0, alpha: 0.35)
        }
        activeFieldView = nil
    }
    
    ////////////////////////////////////////////
    /////       Other Functionality        /////
    ////////////////////////////////////////////
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        outfitContextTextView.resignFirstResponder()
        tagsTextField.resignFirstResponder()
        self.scrollView.scrollEnabled = true

    }
    
    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let contextImage: UIImage = UIImage(CGImage: image.CGImage!)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, cgwidth, cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, rect)!
        let image: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
    
    func setImages(){
        //start with album image
        print("setting up images")
        var imageName = "albumImage.JPEG"
        let manager = NSFileManager.defaultManager()
        var imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
        if (manager.fileExistsAtPath(imagePath)) {
            let image = UIImage(contentsOfFile: imagePath)
            albumImage.image = image
            print("set album image")
            imageName = "topRightImage.JPEG"
            imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            imageCount += 1
        }
        if(manager.fileExistsAtPath(imagePath)){
            let image = UIImage(contentsOfFile: imagePath)
            topRightImage.image = image
            print("set album image")
            imageName = "middleRightImage.JPEG"
            imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            imageCount += 1
        }
        if(manager.fileExistsAtPath(imagePath)){
            let image = UIImage(contentsOfFile: imagePath)
            middleRightImage.image = image
            print("set album image")
            imageName = "bottomRightImage.JPEG"
            imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            imageCount += 1
        }
        if(manager.fileExistsAtPath(imagePath)){
            let image = UIImage(contentsOfFile: imagePath)
            bottomRightImage.image = image
            print("set album image")
            imageName = "bottomMiddleImage.JPEG"
            imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            imageCount += 1
        }
        if(manager.fileExistsAtPath(imagePath)){
            let image = UIImage(contentsOfFile: imagePath)
            bottomMiddleImage.image = image
            print("set album image")
            imageName = "bottomLeftImage.JPEG"
            imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageName)
            imageCount += 1
        }
        if(manager.fileExistsAtPath(imagePath)){
            let image = UIImage(contentsOfFile: imagePath)
            print("set album image")
            bottomLeftImage.image = image
            //imageCount += 1
        }
    }
    
    func deleteAllImages() {
        deleteImage("albumImage.JPEG")
        deleteImage("topRightImage.JPEG")
        deleteImage("middleRightImage.JPEG")
        deleteImage("bottomRightImage.JPEG")
        deleteImage("bottomMiddleImage.JPEG")
        deleteImage("bottomLeftImage.JPEG")
    }
    
    
    
    
    
    
    
    
}












func deleteImage(imageNamed:String){
    let imagePath = getDocumentsDirectory().stringByAppendingPathComponent(imageNamed)
    let manager = NSFileManager.defaultManager()
    //if the image exists, delete it
    if(manager.fileExistsAtPath(imagePath)){
        do{
            try manager.removeItemAtPath(imagePath)
            print("\(imageNamed) deleted")
        }catch let error as NSError{
            print(error.description)
            print("Unable to delete \(imageNamed)")
        }
    }else{
        print("\(imageNamed) does not exists")
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory
}

extension UIImage {
    var uncompressedPNGData: NSData      { return UIImagePNGRepresentation(self)!        }
    var highestQualityJPEGNSData: NSData { return UIImageJPEGRepresentation(self, 1.0)!  }
    var highQualityJPEGNSData: NSData    { return UIImageJPEGRepresentation(self, 0.75)! }
    var mediumQualityJPEGNSData: NSData  { return UIImageJPEGRepresentation(self, 0.5)!  }
    var lowQualityJPEGNSData: NSData     { return UIImageJPEGRepresentation(self, 0.25)! }
    var lowestQualityJPEGNSData:NSData   { return UIImageJPEGRepresentation(self, -0.25)!  }
}
