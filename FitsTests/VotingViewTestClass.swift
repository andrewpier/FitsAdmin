//
//  VotingViewTestClass.swift
//  Fits
//
//  Created by Darren Moyer on 3/6/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
//@testable import Fits
import ParseUI
import Parse
import UIKit

class VotingViewTestClass: XCTestCase {
    
    let votingViewController = VotingViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    //Testing the functions for updating our list for keeping track of 
    // the posts that the user has voted on already
    
    func testAppendElementWithPreviousCloseCheck() { //See if it changes the given array properly
        let element = (21,25)
        var array = [(1,2),(11,20)]
        votingViewController.appendElementWithPreviousCloseCheck(element, toArray: &array)
        XCTAssert(array[0].0 == 1)
        XCTAssert(array[0].1 == 2)
        XCTAssert(array[1].0 == 11)
        XCTAssert(array[1].1 == 25)
    }
    
    func testCollapseVotedOn(){ //Make sure collapseVotedOn collpases properly with entry
        //Data setup
        let votedOn = [(1,2),(11,20)]
        votingViewController.votedOn = votedOn
        let entry = (3,10)
        //Starting Testing
        votingViewController.collapseVotedOn(entry)
        let testResults = votingViewController.votedOn
        XCTAssert(testResults[0].0 == 1)
        XCTAssert(testResults[0].1 == 20)
    }
    
    func testUpdateVotedOn(){ //Make sure the added range is added to the votedOn array
        //Data Setup
        let votedOn = [(1,2),(11,20)]
        votingViewController.votedOn = votedOn
        let array = [3,4,5,6,7,8,9,10]
        //Starting Testing
        votingViewController.updateVotedOn(array)
        let testResults = votingViewController.votedOn
        XCTAssert(testResults[0].0 == 1)
        XCTAssert(testResults[0].1 == 20)
    }
    
    func testFillCardWithPlaceholderInformation(){
        let testImg = UIImage()
        
        for post in votingViewController.postStack {
            post.image = testImg
        }
        
        XCTAssert(!(votingViewController.postStack[2].image == nil))
        votingViewController.fillCardWithPlaceholderInformation(2)
        XCTAssert(votingViewController.postStack[2].image == nil)
    }
}
