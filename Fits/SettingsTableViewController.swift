//
//  SettingsTableViewController.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse

protocol SettingsTableViewControllerDelegate {
    func doneGettingSettings()
    func doneSavingNewEmail()
    func doneSavingNewPassword()
    func doneClearingSavedGallery()
    func doneClearingCommentedGallery()
    func doneChangingSwitch()
}

class SettingsTableViewController: UITableViewController, ChangeEmailDelegate, GenderTableViewDelegate, SwitchCellDelegate, ChangePasswordDelegate, ClearGalleriesCellDelegate {
    
    var queriesDelegate: SettingsTableViewControllerDelegate!
    
    var currentRow: Int = 0
    var currentSection: Int = 0
    var rowLabels = ["Change Email", "Password", "Gender", "Public Profile", "Comments On by Default", "Notification Sounds"]
    
    var currentUser: PFUser!
    var userSettingsObject: PFObject!
    
    var currentGender: String!
    var currentEmail: String!
    var currentPublicProfile: Bool = false
    var currentCommentsDefaultOn: Bool = false
    var currentNotificationsSounds: Bool = false
    
    
    var networkAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = BACKGROUNDCOLOR1
        self.tableView.bounces = false
        currentUser = PFUser.currentUser()
        getCurrentSettings()
        
        //network alert setup
        networkAlert = UIAlertController(title: "Network Issue", message: "Please try again later", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
        networkAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)) //add an OK action that just closes the alert and nothing else
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0: //disclosure cells
            return 3
        case 1: //switch cells
            return 3
        case 2: //button cells
            return 3
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case 0: //disclosure cells
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ChangeEmailCell", forIndexPath: indexPath) as! ChangeEmailCell
                cell.currentEmailLabel.text = currentEmail
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ChangePasswordCell", forIndexPath: indexPath) as! ChangePasswordCell
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("ChangeGenderCell", forIndexPath: indexPath) as! ChangeGenderCell
                cell.currentGenderLabel.text = currentGender
                return cell
            default:
                return UITableViewCell()
            }
        case 1: //switch cells
            let cell = tableView.dequeueReusableCellWithIdentifier("SwitchCell", forIndexPath: indexPath) as! SwitchCell
            cell.label.text = self.rowLabels[indexPath.row+3]
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            print("\(indexPath.row)")
            if(self.rowLabels[indexPath.row+3] == "Public Profile") { //if you change the label make sure you also adjust the switch cell delegate implementation
                cell.cellSwitch.setOn(self.currentPublicProfile, animated: false)
                cell.delegate = self
            }
            if(self.rowLabels[indexPath.row+3] == "Comments On by Default") { //if you change the label make sure you also adjust the switch cell delegate implementation
                cell.cellSwitch.setOn(self.currentCommentsDefaultOn, animated: false)
                cell.delegate = self
            }
            if(self.rowLabels[indexPath.row+3] == "Notification Sounds") { //if you change the label make sure you also adjust the switch cell delegate implementation
                cell.cellSwitch.setOn(self.currentNotificationsSounds, animated: false)
                cell.delegate = self
            }
            return cell
        case 2: //button cells
            switch(indexPath.row) {
            case 0:
                let cell = tableView.dequeueReusableCellWithIdentifier("ClearGalleriesCell", forIndexPath: indexPath) as! ClearGalleriesCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.clearGalleryButton.setTitle("Clear Saved Gallery", forState: UIControlState.Normal)
                cell.gallery = .Saved
                cell.delegate = self
                return cell
            case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("ClearGalleriesCell", forIndexPath: indexPath) as! ClearGalleriesCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                cell.clearGalleryButton.setTitle("Clear Commented Gallery", forState: UIControlState.Normal)
                cell.gallery = .Commented
                cell.delegate = self
                return cell
            case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("LogoutCell", forIndexPath: indexPath) as! LogoutCell
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                return cell
            default:
                return UITableViewCell()
            }
        default:
            return UITableViewCell()
            
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        currentRow = indexPath.row
        currentSection = indexPath.section
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(currentSection == 0) {
            if(currentRow == 0) { //going to change email controller
                let destinationController = segue.destinationViewController as! ChangeEmailViewController
                destinationController.changeEmailDelegate = self
            } else if(currentRow == 1) { //going to change password controller
                let destinationController = segue.destinationViewController as! ChangePasswordViewController
                destinationController.changePasswordDelegate = self
            }else { //going to gender table controller
                let destinationController = segue.destinationViewController as! GenderTableViewController
                for index in 0..<destinationController.genders.count { //find the currentGender in the genders array and set its selected flag to true
                    if(destinationController.genders[index].gender == currentGender) {
                        destinationController.genders[index].selected = true
                    }
                }
                destinationController.genderTableViewDelegate = self
            }
        }
    }
    //******** MARK: Parse Queries************//
    func getCurrentSettings() {
        let query = PFQuery(className:"UserSettings")
        query.fromLocalDatastore()
        query.whereKey("BelongsTo", equalTo: currentUser)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for obj in objects!{
                    self.userSettingsObject = obj
                    if(obj["Gender"] as? Bool == true) {
                        self.currentGender = "Male"
                    } else {
                        self.currentGender = "Female"
                    }
                    self.currentPublicProfile = obj["PublicProfile"] as! Bool
                    self.currentCommentsDefaultOn = obj["AllowComments"] as! Bool
                    self.currentNotificationsSounds = obj["AllowNotificationsSound"] as! Bool
                }
                self.tableView.reloadData()
                self.queriesDelegate?.doneGettingSettings()
            }
        }
        currentEmail = currentUser!["email"] as! String
    }
    
    //*********** END: Parse Queries and Saves ***********//
    
    @IBAction func logoutTap(sender: UIButton) {
        sender.enabled = false
        sender.alpha = 0.5
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginNew") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
        PFUser.logOut()
    }
    
    //************** MARK: Custom Delegate implementations and unwind functions **************//
    func saveNewEmail(changeEmailController: ChangeEmailViewController) {
        currentEmail = changeEmailController.emailTextField.text! //data is validated before delegate is called so use !
        currentUser["email"] = currentEmail
        if(Reachability.isConnectedToNetwork()) {
            currentUser.saveInBackgroundWithBlock() {
                (succeeded, error) -> Void  in
                if(succeeded) {
                    self.queriesDelegate?.doneSavingNewEmail()
                } else {
                    //TO DO: notify user?
                }
            }
            let path = NSIndexPath(forRow: currentRow, inSection: currentSection)
            self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.None)
            navigationController?.popViewControllerAnimated(true)
        } else {
            let alert = UIAlertController(title: "Network Issue", message: "Please try again later", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)) //add an OK action that just closes the alert and nothing else
            self.presentViewController(alert, animated: true, completion: nil) //present the alert
        }
    }
    
    func cancelNewEmail(changeEmailController: ChangeEmailViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func selectedNewGender(genderTVC: GenderTableViewController) {
        currentGender = genderTVC.selectedGender
        if(currentGender == "Male") {
            userSettingsObject["Gender"] = true
        } else {
             userSettingsObject["Gender"] = false
        }
        if(Reachability.isConnectedToNetwork()) {
            userSettingsObject.saveInBackground() 
            let path = NSIndexPath(forRow: currentRow, inSection: currentSection)
            self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.None)
            navigationController?.popViewControllerAnimated(true)
        } else {
            self.presentViewController(networkAlert, animated: true, completion: nil) //present the alert
        }
    }
    
    func didChangeSwitchState(sender: SwitchCell, isOn: Bool) {
        switch(sender.label.text!) {
        case "Public Profile":
            currentPublicProfile = isOn
            userSettingsObject["PublicProfile"] = currentPublicProfile
        case "Comments On by Default":
            currentCommentsDefaultOn = isOn
            userSettingsObject["AllowComments"] = currentCommentsDefaultOn
        case "Notification Sounds":
            currentNotificationsSounds = isOn
            userSettingsObject["AllowNotificationsSound"] = currentNotificationsSounds
        default:
            break
        }
        if(Reachability.isConnectedToNetwork()) {
            userSettingsObject.saveInBackgroundWithBlock {
                (succeeded, error) -> Void  in
                if(succeeded) {
                    sender.cellSwitch.onTintColor = ACCENTCOLOR.colorWithAlphaComponent(1)
                } else {
                    sender.cellSwitch.setOn(!isOn, animated: false) //set the cell switch to the opposite of what the user tried to set it to
                    sender.cellSwitch.onTintColor = ACCENTCOLOR.colorWithAlphaComponent(1)
                }
                self.queriesDelegate?.doneChangingSwitch()
            }
            let path = NSIndexPath(forRow: currentRow, inSection: currentSection)
            self.tableView.reloadRowsAtIndexPaths([path], withRowAnimation: UITableViewRowAnimation.None)
            navigationController?.popViewControllerAnimated(true)
        } else {
            self.presentViewController(networkAlert, animated: true) {
                sender.cellSwitch.setOn(!isOn, animated: false) //set the cell switch to the opposite of what the user tried to set it to
                sender.cellSwitch.onTintColor = ACCENTCOLOR.colorWithAlphaComponent(1)
            }//present the alert
        }
    }
    
    func saveNewPassword(controller: ChangePasswordViewController) {
        currentUser.password = controller.newPasswordField.text
        if(Reachability.isConnectedToNetwork()) {
            currentUser.saveInBackgroundWithBlock { (succeeded, error) -> Void in
                if succeeded {
                    let alert = UIAlertController(title: "New Password Successfully Saved", message: "", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        (alert: UIAlertAction) -> Void in
                        self.navigationController?.popViewControllerAnimated(true)
                    }) //add an OK action that just closes the alert and pops the view
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    print("Error: \(error)")
                }
            }
        } else {
            self.presentViewController(networkAlert, animated: true, completion: nil) //present the alert
        }
    }

    func cancelNewPassword(controller: ChangePasswordViewController) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func clearGallery(button: UIButton, gallery: GalleriesViewController.Gallery) {
        if(Reachability.isConnectedToNetwork()) { //if we are connected to the network
            var galleryTitle = ""
            if(gallery == .Saved) {
                galleryTitle = "Saved"
            } else {
                galleryTitle = "Commented"
            }
            let alert = UIAlertController(title: "Are You Sure?", message: "This will permanantly delete all your \(galleryTitle) outfits", preferredStyle: UIAlertControllerStyle.Alert) //create an alert object
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { //add a Yes action whos handler takes us back to settings table
                (alert: UIAlertAction!) in
                if(gallery == .Saved) {
                    let savedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
                    savedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
                    savedPostsObjectIDsQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            print("The getFirstObject request failed.")
                        } else {
                            // The find succeeded.
                            object?["SavedPosts"] = [""] //set this property to empty string
                            object?.saveInBackgroundWithBlock{ //save in the background
                                (succeeded, error) -> Void in
                                if(succeeded) { //update the saved gallery
                                    let galleriesViewController = self.tabBarController?.viewControllers![3] as! GalleriesViewController
                                    galleriesViewController.getSavedPostsThumbnails()
                                    galleriesViewController.thumbnailArrays[gallery.rawValue].removeAll()
                                    galleriesViewController.collectionView?.reloadData()
                                    button.alpha = 1
                                    button.enabled = true
                                    self.queriesDelegate?.doneClearingSavedGallery()
                                } else {
                                    button.alpha = 1
                                    button.enabled = true
                                    //TO DO: notify the user
                                }
                            }
                        }
                    }
                }else if(gallery == .Commented) {
                    let savedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
                    savedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
                    savedPostsObjectIDsQuery.getFirstObjectInBackgroundWithBlock {
                        (object: PFObject?, error: NSError?) -> Void in
                        if error != nil || object == nil {
                            print("The getFirstObject request failed.")
                        } else {
                            // The find succeeded.
                            object?["PostsCommentedOn"] = [""] //set the property to a empty string
                            object?.saveInBackgroundWithBlock{ //save the change
                                (succeeded, error) -> Void in
                                if(succeeded) { //update the commented gallery
                                    let galleriesViewController = self.tabBarController?.viewControllers![3] as! GalleriesViewController
                                    galleriesViewController.getCommentedPostsThumbnails()
                                    galleriesViewController.thumbnailArrays[gallery.rawValue].removeAll()
                                    galleriesViewController.collectionView?.reloadData()
                                    button.alpha = 1
                                    button.enabled = true
                                    self.queriesDelegate?.doneClearingSavedGallery()
                                } else {
                                    button.alpha = 1
                                    button.enabled = true
                                    //TO DO: notify the user
                                }
                            }
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction) in
                button.alpha = 1
                button.enabled = true
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            self.presentViewController(networkAlert, animated: true) {//present the alert
                button.alpha = 1
                button.enabled = true
            }
        }
    }
    //************** END: Custom Delegate implementations **************//
    

}
