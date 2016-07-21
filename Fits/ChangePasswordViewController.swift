//
//  ChangePasswordViewController.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse
protocol ChangePasswordDelegate {
    func saveNewPassword(controller: ChangePasswordViewController)
    func cancelNewPassword(controller: ChangePasswordViewController)
}

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    var saveBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    
    @IBOutlet weak var confirmPasswordField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var currentPasswordField: UITextField!
    
    var changePasswordDelegate: ChangePasswordDelegate!
    var validNewPassword: Bool!
    var matchingPasswords: Bool!
    var currentPasswordMatch: Bool!
    var networkAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Password"
        
        //network alert setup
        networkAlert = UIAlertController(title: "Network Issue", message: "Please try again later", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
        networkAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)) //add an OK action that just closes the alert and nothing else
        
        //textfield design
        confirmPasswordField.attributedPlaceholder = NSAttributedString(string: confirmPasswordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.15)])
        newPasswordField.attributedPlaceholder = NSAttributedString(string: newPasswordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.15)])
        currentPasswordField.attributedPlaceholder = NSAttributedString(string: currentPasswordField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.15)])
        
        //set keyboard type
        confirmPasswordField.returnKeyType = .Done
        newPasswordField.returnKeyType = .Done
        currentPasswordField.returnKeyType = .Done
        
        confirmPasswordField.delegate = self
        newPasswordField.delegate = self
        currentPasswordField.delegate = self
        
        
        //make sure fields are empty
        confirmPasswordField.text = ""
        newPasswordField.text = ""
        currentPasswordField.text = ""
        
        //initialize validizations to false
        validNewPassword = false
        matchingPasswords = false
        currentPasswordMatch = false
        
        //add nav bar buttons
        saveBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(ChangePasswordViewController.saveTap))
        saveBarButton.enabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(ChangePasswordViewController.cancelTap))
        navigationItem.rightBarButtonItem = saveBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.leftItemsSupplementBackButton = false //explicilty state back button should not appear
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        confirmPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        currentPasswordField.resignFirstResponder()
        return false
    }
    
    func saveTap() {
        //diable cancel button and the fields while save is working
        cancelBarButton.enabled = false
        currentPasswordField.userInteractionEnabled = false
        newPasswordField.userInteractionEnabled = false
        confirmPasswordField.userInteractionEnabled = false
        
        if(Reachability.isConnectedToNetwork()) { //check for connectivity
            PFUser.logInWithUsernameInBackground((PFUser.currentUser()?.username)!, password: (currentPasswordField.text!)) {
                (user: PFUser?, error: NSError?) -> Void in
                //set up skeleton of an alert
                let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)) //add an OK action that just closes the alert and nothing else
                
                if user != nil { //if user is not nil then password matched so check the new password fields
                    self.currentPasswordMatch = true
                    self.matchingPasswords = self.checkIfNewAndConfirmFieldsMatch()
                    self.validNewPassword = self.isValidPass(self.newPasswordField.text!)
                } else {
                    self.currentPasswordMatch = false
                }
                
                //now that checks are done determine if we can save the new password or alert the user to an error
                if(self.currentPasswordMatch == true && self.matchingPasswords == true && self.validNewPassword == true) { //save it cuz its good!
                    self.changePasswordDelegate.saveNewPassword(self) //pass control to the delegate to clean up
                } else if(self.currentPasswordMatch == false) { //wrong current pasword
                    alert.title = "Incorrect Password"
                    alert.message = "Password entered was not recognized"
                    self.presentViewController(alert, animated: true, completion: nil) //present the alert
                } else if(self.validNewPassword == false) { //invalid new password
                    alert.title = "Invalid New Password"
                    alert.message = "Password be 6 characters long and contain at least 1 upper case letter, 1 lower case letter, and 1 number"
                    self.presentViewController(alert, animated: true, completion: nil) //present the alert
                } else if(self.matchingPasswords == false) { //password does not match
                    alert.title = "New Password, Again Does Not Match"
                    alert.message = "New Password and New Password, Again fields must match"
                    self.presentViewController(alert, animated: true, completion: nil) //present the alert
                }
                
                //re-enable all the fields and the cancel button
                self.cancelBarButton.enabled = true
                self.currentPasswordField.userInteractionEnabled = true
                self.newPasswordField.userInteractionEnabled = true
                self.confirmPasswordField.userInteractionEnabled = true
            }
        } else { //no network connection
            self.presentViewController(networkAlert, animated: true, completion: nil) //present the alert
            
            //re-enable all the fields and the cancel button
            self.cancelBarButton.enabled = true
            self.currentPasswordField.userInteractionEnabled = true
            self.newPasswordField.userInteractionEnabled = true
            self.confirmPasswordField.userInteractionEnabled = true
        }
    }
    
    func cancelTap() {
        changePasswordDelegate.cancelNewPassword(self)
    }
    
    func checkIfNewAndConfirmFieldsMatch() -> Bool {
        return (newPasswordField.text == confirmPasswordField.text)
    }
    
    //copy and pasted from RegisterNew.swift
    func isValidPass(testStr: String) -> Bool!{
        //one upper one number at least 6 long
        let PassRegEx = "^(?=.*[A-Z][a-z])(?=.*[0-9]).{6,}$"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", PassRegEx)
        
        return passTest.evaluateWithObject(testStr)
    }
    
    func determineStateOfSaveButton() {
        print("checking state of fields")
        if(currentPasswordField.text != "" && newPasswordField.text != "" && confirmPasswordField.text != "") {
            saveBarButton.enabled = true
        } else {
            saveBarButton.enabled = false
        }
    }
    
    //function hides keyboard when the view background is pressed
    @IBAction func uiControlTap() {
        confirmPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
        currentPasswordField.resignFirstResponder()
    }
    
    @IBAction func textFieldEditingDidEnd() {
        determineStateOfSaveButton()
    }
    
    @IBAction func textFieldEditingDidChange() {
        determineStateOfSaveButton()
    }
    
    @IBAction func textFieldEditingDidBegin() {
        determineStateOfSaveButton()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
