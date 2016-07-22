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

 var numberOfCardsForThisFile: UInt = 10

class VotingViewController: UIViewController {
    var numberOfCards: UInt = 10
    @IBOutlet weak var kolodaView: KolodaView!
    var moreInfoPost: UIImageView!
    var imageObjects: [PFObject]!
    var votes = Array<(String,Bool,Int)>()
    var goingToMoreInfo: Bool = false
    let numberOfPostsToGet = Int(numberOfCardsForThisFile)
    
    var postStack: Array<(PFImageView)> = Array<(PFImageView)>(arrayLiteral: PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView(),PFImageView())
    var numberOfQueriesProcessed = 0
    
    var userInfo: PFObject?
    
    func changeNumberOfCards(num: UInt) {
        numberOfCardsForThisFile = num
    }
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPostsNew()
        
        imageObjects = [PFObject]()

        kolodaView.dataSource = self
        kolodaView.delegate = self
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
extension VotingViewController: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        //Example: loading more cards
        if(direction == SwipeResultDirection.Left){
            print("Swiped Left")

        }
        if(direction == SwipeResultDirection.Right){
            print("Swiped Right")
            PFCloud.callFunctionInBackground("goodPost", withParameters: ["objectID": 2]) { (response: AnyObject?, error: NSError?) -> Void in }
        }
        
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Reloading Images
        imageObjects.removeAll()
        getPostsNew()
        kolodaView.resetCurrentCardNumber()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //Need to load the more info view here
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
    
    func koloda(koloda: KolodaView, didShowCardAtIndex index: UInt) { }
}

//MARK: KolodaViewDataSource
extension VotingViewController: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return numberOfCardsForThisFile
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        return self.postStack[Int(index)]
    }

    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }

    //Getting post objects for the Card Stack
    func getPostsNew(){

        
        
    }
    
    func fillCardWithPlaceholderInformation(index: Int){
        //Can fill this with a placeholder image
        postStack[index].image = nil
    }
}
