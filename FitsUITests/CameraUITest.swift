//
//  CameraUITest.swift
//  Fits
//
//  Created by Darren Moyer on 4/18/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
import UIKit

class FitsUITestsCamera: XCTestCase {
    
    
    var count: Int = 0
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(true)
    }
    
    func testMultipleUploads() {
        for i in 0..<25 {
            testUpload()
            print("Done #\(i)")
        }
    }
    
    func testUpload() {
        
        let app = XCUIApplication()
        app.tabBars.buttons[" "].tap()
        
        let shutterbuttonButton = app.buttons["ShutterButton"]
        shutterbuttonButton.tap()
        
        let useImageButton = app.buttons["Use Image"]
        useImageButton.tap()
        
        let topRightImage = app.images.allElementsBoundByIndex
        topRightImage[1].tap()
        shutterbuttonButton.tap()
        useImageButton.tap()
        
        let middleRightImage = app.images.allElementsBoundByIndex
        middleRightImage[2].tap()
        shutterbuttonButton.tap()
        useImageButton.tap()
        
        //Grabbing the text view
        let Something = app.textViews.allElementsBoundByIndex
        Something[0].tap()
        Something[0].typeText("UI Test #\(count)")
        
        app.staticTexts["Upload"].tap()
        
        //Need to scroll up here
        let someScrollView = app.scrollViews.allElementsBoundByIndex
        someScrollView[0].swipeUp()
        NSThread.sleepForTimeInterval(1)
        
        app.switches["0"].tap()
        
        app.buttons["Upload"].tap()
        
        NSThread.sleepForTimeInterval(90)
        count += 1
    }
    
    func testME() {
        
        let app = XCUIApplication()
        app.tabBars.buttons[" "].tap()
        app.buttons["ShutterButton"].tap()
        app.buttons["Use Image"].tap()
        let something = app.images.allElementsBoundByIndex
        print(something[4])
        something[5].tap()
        //5 bottom right
        //4 bottom middle
        //3 bottom left
        //2 middle right
        //1 top right
        
        
        
    }
}
