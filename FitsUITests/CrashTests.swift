//
//  CrashTests.swift
//  Fits
//
//  Created by Andrew Pier on 4/18/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest

class CrashTests: XCTestCase {
        
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
    }
    func test_VotingCardSwipeThrough(){
        let app = XCUIApplication()
        
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        for _ in 0..<200 {
            element.swipeRight()
        }
    }
    func test_searchViewSwipeThrough(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        app.collectionViews.allElementsBoundByIndex[0].swipeUp()

        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        
        for _ in 0..<12{
            app.collectionViews.allElementsBoundByIndex[0].swipeUp()

            element.swipeRight()
        }


        

    }
    func test_goingtoMoreInfo(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()
        
        app.collectionViews.cells.elementBoundByIndex(0).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(1).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(2).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(3).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(4).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(5).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(6).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(7).tap()
        app.buttons["closeicon small"].tap()
        app.collectionViews.cells.elementBoundByIndex(8).tap()
        app.buttons["closeicon small"].tap()
    }
    
    func test_searchViewLoadBigTag(){// oh big tip
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(1).tap()

        app.searchFields["Ex: red sweater, blue cardigan, casual, etc,."].tap()
        app.searchFields["Ex: red sweater, blue cardigan, casual, etc,."].typeText("pingus")
        app.typeText("\r")
        
        app.collectionViews.allElementsBoundByIndex[0].swipeUp()
        
        let element = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element
        
        for _ in 0..<8{
            app.collectionViews.allElementsBoundByIndex[0].swipeUp()

            element.swipeRight()
        }

    }
    func test_collectionView(){
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(3).tap()
        
        let savedButton = app.buttons["Saved"]
        savedButton.tap()
        app.buttons["Commented"].tap()
        savedButton.tap()
        app.buttons["Mine"].tap()
        

        
    }
    func test_pleaseDontCrash() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
       
        
        
        XCTAssert(true)
        
    }
    func test_loadMoreInfoView() {
        XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Image).element.tap()
        
    }
    func test_leaveAComment(){
        
        
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(3).tap()
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(0)
        window.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        
        let element = window.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element
        element.childrenMatchingType(.Table).element.tap()
        app.tables.buttons["Send"].tap()
       
        
    }
    func test_loadZoomView(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(3).tap()
        
        let window = app.childrenMatchingType(.Window).elementBoundByIndex(0)
        window.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.tap()
        window.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
        
    }
   
}
