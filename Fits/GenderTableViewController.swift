//
//  GenderTableViewController.swift
//  Fits
//
//  Created by Stephen D Tam on 3/8/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit

protocol GenderTableViewDelegate {
    func selectedNewGender(controller: GenderTableViewController) //method should grab the selectedGender and dismiss controller
    
}

class GenderTableViewController: UITableViewController {
    var genders: [(gender: String, selected: Bool)] = [("Male", false), ("Female", false)] //gender options, parent controller sets one of these to true
    var currentRow = 0 //points to the row that the user just selected
    var selectedGender: String!
    var genderTableViewDelegate: GenderTableViewDelegate!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Gender Options"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genders.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = genders[indexPath.row].gender //get gender name for label
        cell.textLabel?.textColor = TEXTCOLOR1
        if(genders[indexPath.row].selected) { //determine which gender is selected
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        currentRow = indexPath.row
        return indexPath
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        genders[indexPath.row].selected = true //mark which gender in teh array has been selected
        selectedGender = genders[indexPath.row].gender //update selected gender property
        genderTableViewDelegate.selectedNewGender(self) //call delegate to transfer data back to settings view and dismiss controller
    }

}
