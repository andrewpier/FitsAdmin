//
//  ZoomViewControllerTests.swift
//  Fits
//
//  Created by Sophia Gebert on 4/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
//@testable import Fits
import ParseUI
import Parse
import UIKit

class ZoomViewControllerTests: XCTestCase {
    
    var zoomViewController = ZoomViewController() 
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        zoomViewController.pageImages = [UIImage()]
        zoomViewController.imageToEnlarge = UIImage()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testImageLoaded(){
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(zoomViewController.pageImages.count > 0)
    }
    
}
