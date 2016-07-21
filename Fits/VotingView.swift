//
//  VotingViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 2/3/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation
import Koloda
import UIKit
import Parse
import ParseUI

private var numberOfCardsPlease: UInt = 1

/*
 *****WHAT IS THIS STUFF??????
class Target: NSObject {
    dynamic var watchME = false
}

let didVoteOnce = Target()

class Observer: NSObject {
    
    
    
    func react() {
        didVoteOnce.addObserver(self, forKeyPath: "watchME", options:  .New, context:  nil)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        print("Andrew Is a Big poopy face!")
    }
    
    deinit {
        didVoteOnce.removeObserver(self, forKeyPath: "watchME")
    }
}
 */

class VotingViewTemp: UIViewController {
    // var numberOfCards: UInt = 10
    
    @IBOutlet weak var kolodaView: KolodaView!
  
    
    var moreInfoPost:UIImageView!
    var imageObjects: [PFObject]!
    var votes = Array<(String,Bool,Int)>()
    var goingToMoreInfo: Bool = false
    var votedOn = [(1,2)]
    //var didVoteOnce = false
    let numberOfPostsToGet = Int(numberOfCardsPlease)
    var votingObject: PFObject? = nil
    
    var postStack: Array<(PFImageView)> = Array<(PFImageView)>(arrayLiteral: PFImageView())
    var numberOfQueriesProcessed = 0
    
    var mostRecentPost:Int {
        get {
            if let _  = votingObject {
                return Int(votingObject!["mostRecentPost"].intValue)
            } else {
                return 0
            }
        }
        
        set (value) {
            if let _ = votingObject {
                votingObject!["mostRecentPost"] = value
                votingObject?.pinInBackground()
            }
        }
    }
    func changeNumberOfCards(num: UInt) {
        numberOfCards = num
    }
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        for post in postStack {
            post.layer.cornerRadius = 160
            
        }
        // Make sure we get the local data first!
        getVotingItem()
        //tryME()
        //imageObjectIDs = [String]()
        
        //Make sure we get the local stored data(only need to do this once on setup), then it will call getPostsNew(what you call to get posts in the rest of the code)
        getVotingItem()
        imageObjects = [PFObject]()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
}

//MARK: KolodaViewDelegate
extension VotingViewTemp: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        //Example: loading more cards
        //didVoteOnce.watchME = true
        mainInstance.voteOnce = true
        if(direction == SwipeResultDirection.Left){
            if (Int(index) < imageObjects.count){
                let num = imageObjects[Int(index)]["PostIDNumber"]
                votes.append((imageObjects[Int(index)].objectId!, false, num as! Int))
            }
        }
        if(direction == SwipeResultDirection.Right){
            if (Int(index) < imageObjects.count){
                let num = imageObjects[Int(index)]["PostIDNumber"]
                votes.append((imageObjects[Int(index)].objectId!, true, num as! Int))
            }
        }
        
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Reloading Images
       // imageObjects.removeAll()
        
        getMostRecentPostIDNumber()
        //kolodaView.resetCurrentCardNumber()
        sendPostVotes()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //Need to load the more info view here
       // print("Card at index \(index) selected")
        let moreInfo = self.storyboard?.instantiateViewControllerWithIdentifier("More Info") as! PagedScrollViewController
        let thisCard = postStack[Int(index)]
        if(thisCard.image == nil){
            print("No image loaded for this card: Cannot open MoreInfo view")
        } else {
            goingToMoreInfo = true
            moreInfo.galleryImage = thisCard.image
            moreInfo.hideVotingBubbles = true
            moreInfo.objectID = self.imageObjects[Int(index)].objectId!
            self.presentViewController(moreInfo, animated: true, completion: nil)
        }
        
    }
    
    func koloda(koloda: KolodaView, didShowCardAtIndex index: UInt) {
        
    }
}

//MARK: KolodaViewDataSource
extension VotingViewTemp: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return numberOfCards
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        return self.postStack[Int(index)]
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
    
    
    // Handling the votedOn Array, Keeping track of the posts a user votes on so they never get the same post twice
    func updateVotedOn(a: Array<Int>) {
        //Get the max and min of the section of posts the user voted on
        var max = INT16_MIN
        var min = INT16_MAX
        for i in a {
            let iprime = Int32(i)
            if ( iprime > max) {
                max = iprime
            }
            if ( iprime < min){
                min = iprime
            }
        }
        if (min == INT16_MAX || max == INT16_MIN){
            print("There are no items left")
        } else {
            // Add the sector to our list of posts voted on and collapse ranges as necessary
            collapseVotedOn((Int(min),Int(max)))
        }
        //print(votedOn)
    }
    
    func collapseVotedOn(newEntry: (Int,Int)){
        var tempArray = Array<(Int,Int)>()
        var amIEntered = false
        for var votedOnSector in votedOn {
            // Insert elements until the current sector we are working with is supposed to be entered
            if(votedOnSector.1 < newEntry.0){
                tempArray.append(votedOnSector)
            }
            // Only insert the element if it is larger then our current sector's max
            if(votedOnSector.0 > newEntry.1){
                //If it is the first time entering an element larger then our sector enter our sector first
                if (!amIEntered){
                    //Before entering our sector see if we need to combine a range
                    if( (newEntry.1+1) == votedOnSector.0){
                        votedOnSector.0 = newEntry.0
                    } else {
                        appendElementWithPreviousCloseCheck(newEntry, toArray: &tempArray)
                    }
                    amIEntered = true
                }
                // Otherwise Add the element to the list making sure to combine with previous sectors when necessary
                appendElementWithPreviousCloseCheck(votedOnSector, toArray: &tempArray)
            }
        }
        // If our sector is the largest make sure we append our sector
        if (!amIEntered){
            appendElementWithPreviousCloseCheck(newEntry, toArray: &tempArray)
            amIEntered = true
        }
        
       // print(tempArray)
        votedOn = tempArray
    }
    
    func appendElementWithPreviousCloseCheck(element: (Int,Int), inout toArray: Array<(Int,Int)>){
        // Check the two sectors to see if they are neighbors (the next number), if so combine otherwise append the new sector
        if(toArray[toArray.count-1].1 == (element.0-1)){
            toArray[toArray.count-1].1 = element.1
        } else {
            toArray.append(element)
        }
    }
    
    
    //Handling grabbing the post numbers so we know which posts to query for
    func getSubsectionPostUniqueNumbers(sector: Int, numberOfPostsNeeded: Int) -> Array<Int> {
        var currentSector = sector
        var results = Array<Int>()
        if (currentSector > votedOn.count) {
            print("There are no more posts to vote on at this time.")
            return Array<Int>()
        }
        var high:Int = -1
        if (currentSector < 2){
            high = mostRecentPost+1
        } else {
            high = votedOn[votedOn.count-(currentSector-1)].0
        }
        let low = votedOn[votedOn.count-currentSector].1
        // Check to see if we need to get more posts
        if (numberOfPostsNeeded > ((high-low)-1)){
            // Increaseing the sector we are looking at in the votedOn queue
            currentSector += 1
            //Adding our current post numbers to the results
            for i in (low+1)..<high {
                results.append(i)
            }
            // Recuresivly calling to get more
            results.appendContentsOf(getSubsectionPostUniqueNumbers(currentSector, numberOfPostsNeeded: numberOfPostsNeeded-((high-low)-1)))
        } else {
            // Add the proper number of posts to the results
            for i in 0..<numberOfPostsNeeded {
                results.append(high-(i+1))
            }
        }
        return results
    }
    
    //Handling grabbing the post numbers so we know which posts to query for
    func getPostUniqueNumbers() -> Array<Int> {
        var results = Array<Int>()
        // Check to see if we enough new posts to work with, otherwise explore our array of votedOn posts
        let mostRecentlyVotedOnID = votedOn[votedOn.count-1].1
        if ((mostRecentPost - mostRecentlyVotedOnID) >= numberOfPostsToGet) {
            // If we have enough new posts just return them
            for i in 0..<numberOfPostsToGet {
                results.append(mostRecentPost-i)
            }
        } else {
            results.appendContentsOf(getSubsectionPostUniqueNumbers(1, numberOfPostsNeeded: numberOfPostsToGet))
        }
        return results
    }
    
    //Getting post objects for the Card Stack
    func getPostsNew(){
        let postNumbers = getPostUniqueNumbers()
        //print(postNumbers)
        let query = PFQuery(className: "Post")
        query.whereKey("PostIDNumber", containedIn: postNumbers)
        query.orderByDescending("PostIDNumber")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
               // print("Successfully retrieved \(objects!.count) voting objects.")
                // Do something with the found objects
                if let _ = objects {
                    var index = 0
                    for object in objects!{
                        let pic = object["ThumbnailRect"] as! PFFile
                        self.imageObjects.append(object)
                        self.postStack[index].userInteractionEnabled = true
                        self.postStack[index].file = pic
                        self.postStack[index].loadInBackground()
                        index += 1
                    }
                    if (objects!.count < Int(numberOfCards)){
                        for index in 0..<(Int(numberOfCards) - objects!.count) {
                            self.fillCardWithPlaceholderInformation(objects!.count + index)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //Getting the ID so we know what the most recent post is so we can grab it if there is a new one
    func getMostRecentPostIDNumber(){
        let query = PFQuery(className:"Voting")
        query.whereKeyExists("mostRecentPost")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
              //  print("Successfully retrieved \(objects!.count) objects for MostRecentPostIDNumber.")
                if let _ = objects{
                    for obj in objects!{
                        self.mostRecentPost = obj["mostRecentPost"] as! Int
                    }
                }
                
                self.getPostsNew()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //Create the most recent item in the local storage
    func createVotingItem(){
        let gameScore = PFObject(className: "Voting")
        gameScore.objectId = "VotingObject"
        gameScore["mostRecentPost"] = self.mostRecentPost
        do {
            try gameScore.pin()
        } catch _ {
            print("Something went wrong in trying to pin the object")
        }
       // print(gameScore)
        
    }
    
    //Getting the most recent item from the local storage
    func getVotingItem() {
        let query = PFQuery(className:"Voting")
        query.fromLocalDatastore()
        query.getObjectInBackgroundWithId("VotingObject", block: { (objects: PFObject?, error: NSError?) -> Void in
            if error == nil {
                //print(objects)
                self.votingObject = objects
                self.getMostRecentPostIDNumber()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                print("----")
                print("Solving error: Creating object.")
                self.createVotingItem()
                print("Problem Solved")
                print("Trying again")
                self.getVotingItem()
                print("Finito")
            }
        })
        
    }
    
    //Record the votes
    func sendPostVotes() {
        
        var ids = Array<String>()
        var choices = Array<Bool>()
        var sectionVotedOn = Array<Int>()
        let size = votes.count
        
        for vote in votes {
            ids.append(vote.0)
            choices.append(vote.1)
            sectionVotedOn.append(vote.2)
        }
        votes.removeAll()
        
        PFCloud.callFunctionInBackground("addVotes", withParameters: ["number": size, "posts": ids,"votes": choices]) { (response: AnyObject?, error: NSError?) -> Void in }
        
        //Comment this out if you want an infinite loop of posts
        self.updateVotedOn(sectionVotedOn)
    }
    
    func fillCardWithPlaceholderInformation(index: Int){
        //postStack[index].image = UIImage().makeImageWithColorAndSize(SELECTEDBACKGROUNDCOLOR, accentColor: ACCENTCOLOR, size: CGSizeMake(postStack[index].frame.width, postStack[index].frame.height))
        postStack[index].image = nil
    }
}
