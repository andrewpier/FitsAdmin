//
//  ChangeEmailViewController.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

protocol ChangeEmailDelegate {
    func cancelNewEmail(changeEmailController: ChangeEmailViewController)
    func saveNewEmail(changeEmailController: ChangeEmailViewController)
}

class ChangeEmailViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    var saveBarButton: UIBarButtonItem!
    var cancelBarButton: UIBarButtonItem!
    
    var validEmail: Bool!
    var changeEmailDelegate: ChangeEmailDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Change Email"
        
        emailTextField.attributedPlaceholder = NSAttributedString(string: emailTextField.placeholder!, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.15)])
        
        emailTextField.text = ""
        validEmail = false
        saveBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: #selector(ChangeEmailViewController.saveTap))
        saveBarButton.enabled = false
        cancelBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(ChangeEmailViewController.cancelTap))
        navigationItem.rightBarButtonItem = saveBarButton
        navigationItem.leftBarButtonItem = cancelBarButton
        navigationItem.leftItemsSupplementBackButton = false //explicilty state back button should not appear
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func uiControlTap() {
        emailTextField.resignFirstResponder()
    }
    
    func saveTap() {
        print("save tapped")
        let newEmail = emailTextField.text
        if(newEmail != ""){
            validEmail = isValidEmail(newEmail!)
        }
        if(validEmail!) {
            print("saving new email to parse")
            changeEmailDelegate.saveNewEmail(self)
        } else {
            let alert = UIAlertController(title: "Invalid Email", message: "Please enter a valid email address", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)) //add an OK action that just closes the alert and nothing else
            self.presentViewController(alert, animated: true, completion: nil) //present the alert
        }
    }
    
    func cancelTap() {
        if(saveBarButton.enabled) { //if saved is enabled then there are cahnges that could be saved
            let changeEmailController = self
            let alert = UIAlertController(title: "Unsaved Changes", message: "Continue without saving changes?", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { //add a Yes action whos handler takes us back to settings table
                (alert: UIAlertAction!) in changeEmailController.changeEmailDelegate.cancelNewEmail(changeEmailController)
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: nil)) //add a no action that closes the alert and keeps us on the change email view
            self.presentViewController(alert, animated: true, completion: nil) //present the alert
        } else { //pop the view controller
            changeEmailDelegate.cancelNewEmail(self)
        }
    }
    
    func determineStateOfSaveButton() {
        if(emailTextField.text != "") {
            saveBarButton.enabled = true
        } else {
            saveBarButton.enabled = false
        }
    }
    
    //function is copy and pasted from RegisterNew.swift
    func isValidEmail(testStr: String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?).*[a-z]$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}
