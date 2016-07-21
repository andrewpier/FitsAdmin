//
//  LoginNew.swift
//  Fits
//
//  Created by Darren Moyer on 2/3/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Parse

class NewRegisterViewController: UIViewController ,UITextFieldDelegate{
    
    
    @IBOutlet weak var UsernameTextfield: UITextField!
    @IBOutlet weak var FemaleGenderSelectionButton: UIButton!
    @IBOutlet weak var MaleGenderSelectionButton: UIButton!
    @IBOutlet weak var ConfirmPasswordTextfield: UITextField!
    @IBOutlet weak var PasswordTextfield: UITextField!
    @IBOutlet weak var EmailTextfield: UITextField!
    
    var activeField: UITextField?
    
    @IBOutlet weak var statusText: UILabel!
    
    var alert: UIAlertController!
    var Gender : String = ""
    var lastTouch = CGPoint()
    var ableToMoveView = true
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var ConfirmTextField: UITextField!
    @IBOutlet weak var RegisterButton: UIButton!
    @IBOutlet weak var MaleButton: UIButton!
    @IBOutlet weak var FemaleButton: UIButton!
    @IBOutlet weak var HeaderContentView: UIView!
    @IBOutlet weak var FooterContentView: UIView!
    @IBOutlet weak var MiddleContentView: UIView!
    
    override func viewDidLoad() {
        setupView()
        //SKTransition *reveal = [SKTransition revealWithDirection:SKTransitionDirectionLeft duration:1.0];
        UsernameTextfield.text! = ""
        EmailTextfield.text! = ""
        PasswordTextfield.text! = ""
        ConfirmPasswordTextfield.text! = ""
        Gender = ""
        PasswordTextField.delegate = self
        ConfirmTextField.delegate = self
        statusText.hidden = true
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewRegisterViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewRegisterViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        if ((HeaderContentView.frame.height + MiddleContentView.frame.height + FooterContentView.frame.height) <= self.view.frame.height) {
            ableToMoveView = false
        }
    }
    
    func setupView(){
        self.view.layer.addSublayer(self.playerLayer)
        self.view.bringSubviewToFront(ContentView)
        UsernameTextField.attributedPlaceholder = NSAttributedString(string:"Username", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        EmailTextField.attributedPlaceholder = NSAttributedString(string:"Email Address", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        PasswordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        ConfirmTextField.attributedPlaceholder = NSAttributedString(string:"Confirm Password", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        
        RegisterButton.layer.cornerRadius = 0;
        RegisterButton.layer.borderWidth = 1;
        RegisterButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
        
        MaleButton.layer.cornerRadius = 0;
        MaleButton.layer.borderWidth = 1;
        MaleButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
        
        FemaleButton.layer.cornerRadius = 0;
        FemaleButton.layer.borderWidth = 1;
        FemaleButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
        
         UsernameTextField.delegate = self
         EmailTextField.delegate = self
         PasswordTextField.delegate = self
         ConfirmTextField.delegate = self
        UsernameTextField.tag = 0
        EmailTextField.tag = 1
        PasswordTextField.tag = 2
        ConfirmTextField.tag = 3
        
        
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        switch textField.tag{
        case 0:
            EmailTextField.becomeFirstResponder()
            break
        case 1:
            PasswordTextField.becomeFirstResponder()
            break
        case 2:
            ConfirmTextField.becomeFirstResponder()
            break
        case 3:
            ConfirmTextField.resignFirstResponder()
            break
        default:
            break
        }
        
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // If orientation changes
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        playerLayer.frame = self.view.frame
    }
    
    func playerDidReachEnd(){
        self.playerLayer.player!.seekToTime(kCMTimeZero)
        self.playerLayer.player!.play()
        
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?).*[a-z]$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func isValidPass(testStr: String) -> Bool{
        //one upper one number at least 4 long
        let PassRegEx = "^(?=.*[A-Z][a-z])(?=.*[0-9]).{6,}$"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", PassRegEx)
        
        return passTest.evaluateWithObject(testStr)
    }
    
    @IBAction func textFieldEditingDidChange(sender: AnyObject) {
        if let field = PasswordTextField {
            if(isValidPass(field.text!)){
                statusText.hidden = true
            }
            else{
                statusText.textColor = UIColor.init(red: 0.937, green: 0.639, blue: 0.639, alpha: 1)
                statusText.text = "1 Uppercase 1 Number 6 Long"
                statusText.hidden = false
            }
        }
       
       
    }
    @IBAction func PasswordVaidation(sender: AnyObject){
        if let field = ConfirmTextField {
            if( PasswordTextField.text == field.text){
                statusText.hidden = true
            }
            else{
                statusText.textColor = UIColor.init(red: 0.937, green: 0.639, blue: 0.639, alpha: 1)
                statusText.text = "Passwords do not match"
                statusText.hidden = false
            }
        }
    }
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    
    func configUser(user:PFUser) -> Bool {
        var passed = true
        let userInfo = PFObject(className:"UserInformation")
        userInfo["SavedPosts"] = [""]
        userInfo["UserPosts"] = [""]
        userInfo["UserPosts"] = [""]
        userInfo["PostsCommentedOn"] = [""]
        userInfo["BelongsTo"] = user
        userInfo["HasVoted"] = false
        userInfo["HasSearched"] = false
        
        userInfo.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved. Pin info to local datastore
                self.pinUserInformation();
            } else {
                // There was a problem, check error.description
                passed = false
            }
        }
        var gender = false;
        if(self.Gender == "Male") { gender = true }
        let userSettings = PFObject(className:"UserSettings")
        userSettings["PublicProfile"] = true
        userSettings["Gender"] = gender

        userSettings["AllowComments"] = true
        userSettings["AllowNotificationsSound"] = true
        userSettings["BelongsTo"] = user
        
        userSettings.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                // The object has been saved.
                //get user settings
                self.getUserSettings()
            } else {
                passed = false
            }
        }
        if(!passed) { return false }
        return true
    
    }
    
    func getUserSettings() {
        let user = PFUser.currentUser()
        let query = PFQuery(className:"UserSettings")
        print(user!.objectId!)
        query.whereKey("BelongsTo", equalTo: (PFUser.currentUser())!)
        query.findObjectsInBackgroundWithBlock { //query results through network in background
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                objects?[0].pinInBackground() //pin user settings to local data store in background
            }
        }
    }
    
    func pinUserInformation() {
        let user = PFUser.currentUser()
        let query = PFQuery(className:"UserInformation")
        print(user!.objectId!)
        query.whereKey("BelongsTo", equalTo: (PFUser.currentUser())!)
        query.findObjectsInBackgroundWithBlock { //query results through network in background
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                objects?[0].pinInBackground() //pin user information to local data store in background
            }
        }
    }

    
    
    @IBAction func RegisterButtonTap(sender: AnyObject) {
       
        if(UsernameTextfield.text != nil  && EmailTextfield.text != nil && PasswordTextfield.text != nil && ConfirmPasswordTextfield.text != nil){
            if (PasswordTextfield.text == ConfirmPasswordTextfield.text && (PasswordTextfield.text != "" && ConfirmPasswordTextfield.text != "")){
                
                if(!isValidEmail(EmailTextfield.text!) ){//can use ! because we check for nil in prev if statement
                    //////How to use popup "alerts"//////////
                    
                    alert = UIAlertController(title: "Invalid Email", message: "Please Enter a Valid Email", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    /////////
                    PasswordTextfield.text = ""
                    ConfirmPasswordTextfield.text = ""
                    EmailTextfield.text = ""
                }
                else{
                    if(isValidPass((PasswordTextField?.text)!)){
                        let user = PFUser()
                        user.username = UsernameTextfield.text
                        user.password = PasswordTextfield.text
                        user.email = EmailTextfield.text
                        // other fields can be set just like with PFObject
                        // user["phone"] = "415-392-0202"
                        
                        
                        
                        user.signUpInBackgroundWithBlock {
                            (succeeded: Bool, error: NSError?) -> Void in
                            if let error = error {
                                let errorString = error.userInfo["error"] as? NSString
                                // Show the errorString somewhere and let the user try again.
                                let alertss = UIAlertController(title: errorString?.description, message: "", preferredStyle: UIAlertControllerStyle.Alert)
                                alertss.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alertss, animated: true, completion: nil)
                                
                                self.PasswordTextfield.text = ""
                                self.ConfirmPasswordTextfield.text = ""
                                self.EmailTextfield.text = ""
                                self.UsernameTextfield.text = ""
                                
                                
                            } else {
                                //last minute db calls to set up the user
                                let check = self.configUser(user)
                                // Hooray! Let them use the app now.
                                if(check){
                                    let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                                    let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("Tab Bar Controller") as      UIViewController
                                    self.presentViewController(vc, animated: true, completion: nil)
                                }
                                else{
                                    let alertss = UIAlertController(title: "Error Occured", message: "please try again", preferredStyle: UIAlertControllerStyle.Alert)
                                    alertss.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alertss, animated: true, completion: nil)
                                    
                                }
                            }
                        }
                    }else{
                        alert = UIAlertController(title: "Please Enter Stronger Password", message: "Criteria: 1 Uppercase 1 Number atleast 6 Characters", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.PasswordTextfield.text = ""
                        self.ConfirmPasswordTextfield.text = ""
                    }
                    
                    
                    
                    
                }
                
            }
            else {//passwords dont match
                alert = UIAlertController(title: "Passwords Don't Match", message: "Please Enter Matching Passwords", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                PasswordTextfield.text = ""
                ConfirmPasswordTextfield.text = ""
            }
        }
        else{//something missing in the form
            alert = UIAlertController(title: "Please Fill in Entire Form", message: "WHYYYY", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    lazy var playerLayer:AVPlayerLayer = {
        
        let player = AVPlayer(URL:  NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "mov")!))
        
        player.muted = true
        player.allowsExternalPlayback = false
        player.appliesMediaSelectionCriteriaAutomatically = false
        var error:NSError?
        
        // This is needed so it would not cut off users audio (if listening to music etc.
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
        } catch var error1 as NSError {
            error = error1
        } catch {
            fatalError()
        }
        if error != nil {
            print(error)
        }
        
        var playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = "AVLayerVideoGravityResizeAspectFill"
        playerLayer.backgroundColor = UIColor.blackColor().CGColor
        player.play()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NewRegisterViewController.playerDidReachEnd), name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)
        return playerLayer
    }()
    
    @IBAction func MaleButtonTapped(sender: UIButton) {
        MaleButton.layer.cornerRadius = 3;
        MaleButton.layer.borderWidth = 3;
        MaleButton.layer.borderColor = ACCENTCOLOR.CGColor
        Gender = "Male"
        FemaleButton.layer.cornerRadius = 0;
        FemaleButton.layer.borderWidth = 1;
        FemaleButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
    }
    
    @IBAction func FemaleButtonTapped(sender: UIButton) {
        FemaleButton.layer.cornerRadius = 3;
        FemaleButton.layer.borderWidth = 3;
        FemaleButton.layer.borderColor = ACCENTCOLOR.CGColor
        Gender = "Female"
        MaleButton.layer.cornerRadius = 0;
        MaleButton.layer.borderWidth = 1;
        MaleButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        UsernameTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        ConfirmTextField.resignFirstResponder()
        EmailTextField.resignFirstResponder()
        let touch = NSSet(set: touches).allObjects[0] as! UITouch
        lastTouch = touch.locationInView(self.view)
    }
    
    //Scrolling view if we need to (need to set inital touch in touchesBegan)
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (ableToMoveView) {
            testTouches(touches)
        }
    }
    
    func testTouches(touches: NSSet!) {
        // Get the first touch and its location in this view controller's view coordinate system
        let touch = touches.allObjects[0] as! UITouch
        let touchLocation = touch.locationInView(self.view)
        let touchDelta = CGPoint(x: touchLocation.x - lastTouch.x, y: touchLocation.y - lastTouch.y)
        if (contentViewTopConstriant.constant <= 0 && contentViewTopConstriant.constant > -147){
            contentViewTopConstriant.constant += touchDelta.y
        } else if (contentViewTopConstriant.constant > 0) {
            contentViewTopConstriant.constant = 0
        } else {
            contentViewTopConstriant.constant = -146.7
        }
        lastTouch = touchLocation
        UIView.animateWithDuration(0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    @IBOutlet weak var contentViewTopConstriant: NSLayoutConstraint!
    
    var TextfieldSelectedForEditingLocation: CGPoint!
    
    @IBAction func TouchDownInsideTextfield(sender: UITextField) {
        let globalPoint = sender.superview?.convertPoint(sender.frame.origin, toView: nil)
        print(globalPoint)
        TextfieldSelectedForEditingLocation = globalPoint
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let loactionOfTextfieldSelected = TextfieldSelectedForEditingLocation {
                let topOfKeyboard = (self.view.window?.frame.height)! - keyboardSize.height
                let distanceToMove = loactionOfTextfieldSelected.y - (topOfKeyboard - 85)
                if (distanceToMove > 0){
                    self.view.frame.origin.y -= distanceToMove
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y -= self.view.frame.origin.y
    }
    
}


