//
//  MoreInfoViewControllerTest.swift
//  Fits
//
//  Created by Sophia Gebert on 3/7/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits
import ParseUI
import Parse
import UIKit


class MoreInfoViewControllerTest: XCTestCase {

    let moreInfoViewController = PagedScrollViewController()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
    }

    func grabMoreImagesIfExists() {
        //makes sure the function to get related images to the post works 
        moreInfoViewController.getOtherPostImages("L6Kzvx509a")
        XCTAssert(moreInfoViewController.pageImages.count > 0)
    }
    func grabCommentsForPostTest(){
        //checks the function that gets comments for the post
        moreInfoViewController.objectID = "L6Kzvx509a"
        moreInfoViewController.getCommentsForPost()
        XCTAssert(moreInfoViewController.commentsOnPost.count > 0)
    }
   
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
