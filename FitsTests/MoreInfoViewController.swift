//
//  MoreInfoViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 4/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits
import ParseUI
import Parse
import UIKit

extension XCTestExpectation: MoreInfoViewControllerDelegate {
    func doneSavingImage(){
        self.fulfill()
    }
    func doneGettingComments() {
        self.fulfill()
    }
    
    func donePostingComment(){
        self.fulfill()
    }
}

class MoreInfoViewController: XCTestCase {
    let moreInfoController = PagedScrollViewController()
   
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetComments() {
        weak var zeroFoldersExpectation=expectationWithDescription("getting comments for image")
        moreInfoController.queriesDelegate = zeroFoldersExpectation
        
        moreInfoController.objectID = "6vBoA4Gyzu"
        moreInfoController.commentTable = UITableView()
        moreInfoController.getCommentsForPost()
        self.waitForExpectationsWithTimeout(30) { (error) in
            XCTAssert(self.moreInfoController.commentsOnPost.count >= 0)
        }
        
    }
    func testPostComment(){
        weak var zeroFoldersExpectation=expectationWithDescription("posting comments for image")
        moreInfoController.queriesDelegate = zeroFoldersExpectation
        
        moreInfoController.objectID = "6vBoA4Gyzu"
        moreInfoController.commentTable = UITableView()
        moreInfoController.commentString = "testing post comment"
        
        let myObj = PFQuery(className: "PostTextItems")
        myObj.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: moreInfoController.objectID))
        myObj.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                print("Successfully found \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        object.addObject(self.moreInfoController.commentString, forKey: "Comments")
                        object.saveInBackground()
                    }
                }
                self.moreInfoController.postCommentSucessful = true
            } else {
                print("Upload Failed")
            }
            self.moreInfoController.queriesDelegate.donePostingComment()
        })
        self.waitForExpectationsWithTimeout(30) { (error) in
            XCTAssert(self.moreInfoController.postCommentSucessful == true)
        }
    }
    
    func testSaveImage() {
        // This is an example of a performance test case.
         weak var zeroFoldersExpectation=expectationWithDescription("saving test image")
        moreInfoController.queriesDelegate = zeroFoldersExpectation
        
        moreInfoController.objectID = "6vBoA4Gyzu"
        moreInfoController.yellowStarImage = UIImage()
        moreInfoController.starImageView = UIImageView()
        moreInfoController.saveImage(nil)
        self.waitForExpectationsWithTimeout(30) { (error) in
            XCTAssert(self.moreInfoController.alreadySavedPost == true)
        }
        
    }
    func testRetrieveMoreImages(){
        //initialize array.
        let testImg = UIImage()
        moreInfoController.pageImages = [testImg]
        //call the function with an image we know has more images
        moreInfoController.getOtherPostImages("6vBoA4Gyzu")
        XCTAssert(self.moreInfoController.pageImages.count >= 0)
    }
    
}
