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

class NewLoginViewController: UIViewController, UITextFieldDelegate{
    
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(NewLoginViewController.playerDidReachEnd), name:AVPlayerItemDidPlayToEndTimeNotification, object:nil)
        return playerLayer
    }()
    
    @IBOutlet weak var ContentView: UIView!
    @IBOutlet weak var UsernameTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var LoginButton: UIButton!
    var LastObjectTouched: UIView!
    
    override func viewDidLoad() {
        setupView()
        super.viewDidLoad()
        LastObjectTouched = UsernameTextField
        LastObjectTouched = LoginButton
        UsernameTextField.delegate = self
        PasswordTextField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewLoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewLoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        //PFCloud.callFunctionInBackground("addTags", withParameters: ["tags": ["a","b", "c"],"num": 3, "postID": "abc"]) { (response: AnyObject?, error: NSError?) -> Void in }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        if(textField.secureTextEntry){
            //login function
            loginButtonPress(textField)
        }else{
            //textField.resignFirstResponder()
            PasswordTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func setupView(){
        self.view.layer.addSublayer(self.playerLayer)
        self.view.bringSubviewToFront(ContentView)
        UsernameTextField.attributedPlaceholder = NSAttributedString(string:"Username", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        PasswordTextField.attributedPlaceholder = NSAttributedString(string:"Password", attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
        LoginButton.layer.cornerRadius = 0;
        LoginButton.layer.borderWidth = 1;
        LoginButton.layer.borderColor = UIColor(white: 1, alpha: 0.35).CGColor
        
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(NewLoginViewController.showRegisterViewController))
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    func showRegisterViewController() {
        self.performSegueWithIdentifier("LoginSwipeToRegister", sender: self)
    }
    
    @IBAction func loginButtonPress(sender: AnyObject) {
        ////////////////////////////////////
        // Querying for data from a table //
        ////////////////////////////////////
        if((UsernameTextField.text != "" || UsernameTextField.text != nil) && PasswordTextField.text != "" || PasswordTextField.text != nil  ){
            
            PFUser.logInWithUsernameInBackground((UsernameTextField?.text)!, password: (PasswordTextField?.text!)!) {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    //grab relevant user information and settings
                    self.getUserSettings()
                    self.pinUserInformation()
                } else {
                    // The login failed. Check error to see why.
                    let alert = UIAlertController(title: "Invalid Login", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            
            
        }

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
                self.presentFirstView()
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
                self.presentFirstView()
            }
        }
    }
    
    func presentFirstView() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("VotingView") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        UsernameTextField.resignFirstResponder()
        PasswordTextField.resignFirstResponder()
        let touch = NSSet(set: touches).allObjects[0] as! UITouch
        //print("Touched At: " + String(touch.locationInView(self.view)) + " <-------")
    }
    
    override func viewDidAppear(animated: Bool) {
        print("Loaded")
        let mainStoryboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("VotingView") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)

    }
    
    
    // If orientation changes
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        playerLayer.frame = self.view.frame
    }
    
    
    func playerDidReachEnd(){
        self.playerLayer.player!.seekToTime(kCMTimeZero)
        self.playerLayer.player!.play()
        
    }
    
    
    
    
    
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
                print("Top Of Keyboard: " + String(topOfKeyboard))
                let distanceToMove = loactionOfTextfieldSelected.y - (topOfKeyboard - 85)
                if (distanceToMove > 0){
                    print(distanceToMove)
                    self.view.frame.origin.y += -distanceToMove
                    print("View Frame: " + String(self.view.frame.origin.y) + " \\\\\\")
                }
            }
            //self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        print("reset")
    }
    
    @IBAction func returnToLoginViewController(segue: UIStoryboardSegue){

    }
    
}

