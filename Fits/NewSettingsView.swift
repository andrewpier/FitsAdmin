//
//  NewSettingsView.swift
//  Fits
//
//  Created by Andrew Pier on 2/15/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse
class NewSettingsView: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate{

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var ScrollWheel: UIPickerView!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var EnableSoundSwitch: UISwitch!
    @IBOutlet weak var PublicProfileSwitch: UISwitch!
    @IBOutlet weak var EnableCommentsSwitch: UISwitch!
    var source = ["Male","Female"]
    var profile = false
    var comments = false
    var sound = false
    var gender: String = "Male"
    var pickerChanged = false
    var current = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUser = PFUser.currentUser()
        user.text = currentUser?.username
        numberOfComponentsInPickerView(ScrollWheel)
        ScrollWheel.dataSource = self
        ScrollWheel.delegate = self
        saveButton.hidden = true
        
        if(PublicProfileSwitch.on){
            profile = true
        }
        if(EnableCommentsSwitch.on){
            comments = true
        }
        if(EnableSoundSwitch.on){
            sound = true
            
        }
        
                // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    @IBAction func saveSettings(sender: AnyObject) {
        
      
        print(profile.description)
        //let notifications = EnableSoundSwitch.enabled
        var genderBool = false
        if(gender == "male"){
            genderBool = true
        }
        let query = PFQuery(className:"UserSettings")
        print(PFUser.currentUser()?.objectId!)
        query.whereKey("BelongsTo", equalTo: (PFUser.currentUser())!)
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for obj in objects!{
                    obj["PublicProfile"] = self.profile
                    obj["Gender"] = genderBool
                    // userSettings["AllowNotifications"] = EnableCommentsSwitch.enabled Array???
                    obj["AllowComments"] = self.comments
                    //userSettings["AllowNotificationsSound"] = notifications Array???
                    
                    obj.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            let alert = UIAlertController(title: "Settings have been saved", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        else {
                            print("faiuiled")
                        }
                    }

                }
            }
        }

    }
    @IBAction func showSaveButton(sender: AnyObject) {
        if(profile == true && !PublicProfileSwitch.on){
             saveButton.hidden = false
            return
        }
        else if(profile == false && PublicProfileSwitch.on){
            saveButton.hidden = false
            return
        }
        else{
            if(pickerChanged){
                saveButton.hidden = true
            }
            
        }
        if(comments == true && !EnableCommentsSwitch.on){
             saveButton.hidden = false
            return
        }
        else if(comments == false && EnableCommentsSwitch.on){
            saveButton.hidden = false
            return
        }
        else{
            if(pickerChanged){
                saveButton.hidden = true
            }
        }
        if(sound == true && !EnableSoundSwitch.on){
            saveButton.hidden = false
            return
        }
        else if(sound == false && EnableSoundSwitch.on){
            saveButton.hidden = false
            return
        }
        else{
            if(pickerChanged){
                saveButton.hidden = true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func numberOfComponentsInPickerView(ScrollWheel: UIPickerView) -> Int {
        return 1
    }
    func pickerView(ScrollWheel: UIPickerView,numberOfRowsInComponent component: Int) -> Int {
        return 	2
    }
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        current = indexPath.row
        return indexPath
        
    }
    
   /* override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell" ,forIndexPath: indexPath)
        if indexPath.section == 0{
            cell.textLabel?.text = ""
        }else{
            cell.textLabel?.text = ""
            
        }
        
        return cell
    }*/

   
    func pickerView(ScrollWheel: UIPickerView,titleForRow row: Int,forComponent component: Int) -> String? {
            gender = source[row]
            return source[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        // selected value in Uipickerview in Swift
        let value=source[row]
        if(value != gender){
            saveButton.hidden = false
        }
        else{
            saveButton.hidden = true
            pickerChanged = true
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // #warning Incomplete implementation, return the number of rows
        
        return 9
    }

   
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        
    }

    @IBAction func ClearGalleryPress(sender: AnyObject) {
        let alert = UIAlertController(title: "Are You Sure?", message: "This will clear all of your entries", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: {   action in
            switch action.style{
            case .Default:
                let query = PFQuery(className:"Post")
                query.whereKey("BelongsTo", equalTo: (PFUser.currentUser())!)
                
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if let _ = objects {
                            for object in objects!{
                               object.deleteInBackground()
                            }
                        }
                    } else {
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))

        alert.addAction(UIAlertAction(title: "No ", style: UIAlertActionStyle.Cancel, handler: {   action in
            switch action.style{
            case .Default:
                print("default")
                
            case .Cancel:
                print("cancel")
                
            case .Destructive:
                print("destructive")
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
 
        
    }
    @IBAction func LogoutButtonPress(sender: AnyObject) {
        PFUser.logOut()
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginNew") as UIViewController
        self.presentViewController(vc, animated: true, completion: nil)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       NSLog("seg")
    }
}

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


