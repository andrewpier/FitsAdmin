//
//  CommentTableViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 2/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

class CommentTableViewController: UITableViewController {
    
    let comments:[String] = []
    let commentsEnabled = true
    var noComments = true
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if comments are enabled for the post, return the number of comments, otherwise return 1
        if(commentsEnabled){
            //check if there are actually any comments first
            if(comments.count == 0){
                return 1
            }else{
              noComments = false
              return comments.count
            }
        }else{
            return 1
        }
      
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(commentsEnabled){
            //return a special cell if there aren't any comments for the post
            if(noComments){
                let cell = tableView.dequeueReusableCellWithIdentifier("NoComments", forIndexPath: indexPath)
                cell.textLabel?.text = comments[indexPath.row]
                return cell
            } else{
                //at least 1 comment has been made
                let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath)
                cell.textLabel?.text = comments[indexPath.row]
                return cell
            }
        }else{
            //comments are disabled, so display 1 cell with that message
            let cell = tableView.dequeueReusableCellWithIdentifier("CommentsDisabled", forIndexPath: indexPath)
            cell.textLabel?.text = comments[indexPath.row]
            return cell
        }
    }
  

    
     //Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
     //Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
             //Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


////     Override to support rearranging the table view.
//    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
//
//    }



////     Override to support conditional rearranging of the table view.
//    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//  //       Return false if you do not want the item to be re-orderable.
//        return true
//    }


    // MARK: - Navigation

//     //In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//         //Get the new view controller using segue.destinationViewController.
//         //Pass the selected object to the new view controller.
//    }

}
