//
//  ConfirmPasswordView.swift
//  Fits
//
//  Created by Andrew Pier on 2/17/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse
class ChangePasswordView: UIViewController {

    @IBOutlet weak var ConfirmPasswordTF: UITextField!
    @IBOutlet weak var NewPasswordTF: UITextField!
    @IBOutlet weak var PasswordTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PasswordTF.placeholder = "Current Password"
        NewPasswordTF.placeholder = "New Password"
        ConfirmPasswordTF.placeholder = "New Password, again"
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func DoneButtonPress(sender: AnyObject) {
        
        if(PasswordTF.text != nil && ConfirmPasswordTF.text != nil && NewPasswordTF != nil && NewPasswordTF.text == ConfirmPasswordTF.text && (NewPasswordTF.text != "" && ConfirmPasswordTF.text != "" && PasswordTF != "")){
            let user = PFUser.currentUser()
                if(isValidPass((NewPasswordTF?.text)!)){
            
                    user?.password = NewPasswordTF.text
                    user?.saveInBackground()
                    let alert = UIAlertController(title: "Password has been changed", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: {
                        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginNew") as UIViewController
                        self.presentViewController(vc, animated: true, completion: nil)})

                }else{//need a stronger password
                    let alert = UIAlertController(title: "Please Enter Stronger Password", message: "Criteria: 1 Uppercase 1 Number atleast 6 Characters", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.PasswordTF.text = ""
                    self.ConfirmPasswordTF.text = ""
                    self.NewPasswordTF.text = ""
                }
        }else{
            let alert = UIAlertController(title: "Please fill entire form", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.PasswordTF.text = ""
            self.ConfirmPasswordTF.text = ""
            self.NewPasswordTF.text = ""
        }
    }
    
    
    func isValidPass(testStr: String) -> Bool{
        //one upper one number at least 4 long
        let PassRegEx = "^(?=.*[A-Z][a-z])(?=.*[0-9]).{6,}$"
        
        let passTest = NSPredicate(format:"SELF MATCHES %@", PassRegEx)
        
        return passTest.evaluateWithObject(testStr)
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

