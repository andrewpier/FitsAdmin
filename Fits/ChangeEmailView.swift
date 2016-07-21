//
//  ChangeEmailView.swift
//  Fits
//
//  Created by Andrew Pier on 2/18/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse
class ChangeEmailView: UIViewController {
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var EmailTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EmailTF.placeholder = "Enter valid email"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func SaveButtonTap(sender: AnyObject) {
        let user = PFUser.currentUser()
        if(EmailTF.text != nil){
            if(isValidEmail(EmailTF.text!)){
                user?.email = EmailTF.text
                user?.saveInBackground()
                let alert = UIAlertController(title: "Email has been changed", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                EmailTF.text = ""
                
            }else{
                let alert = UIAlertController(title: "Please enter valid email", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)

            }
        }
       
        
    }
    
    @IBAction func goBack(segue: UIStoryboardSegue, sender: AnyObject?){
        self.dismissViewControllerAnimated(true, completion: nil)
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
