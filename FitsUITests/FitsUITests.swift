//
//  FitsUITests.swift
//  FitsUITests
//
//  Created by Sophia Gebert on 1/20/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
class FitsUITests: XCTestCase {
        
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
    func loadZoomView(){
        XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.tap()
    }
    func test_successfulLogin(){
        
        let app = XCUIApplication()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Andrew")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Andrew1234")
        app.buttons["Login"].tap()
        
        
    }
    func test_loadMoreInfo(){
        XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Image).element.tap()
    }
    func test_unSuccessfulLogin(){
        
        let app = XCUIApplication()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Andrew")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Andrew12")
        app.buttons["Login"].tap()
        
        
    }
    func test_exitZoomView(){
        XCUIApplication().buttons["closeicon small"].tap()
    }
    func test_successfulRegisterMale(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("holla@holla.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Holla123")
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        confirmPasswordSecureTextField.typeText("Holla123")
        app.buttons["Male"].tap()
        app.buttons["Register"].tap()
        
    }
    func test_exitMoreInfo(){
        XCUIApplication().buttons["closeicon small"].tap()
    }
    func test_successfulRegisterFemale(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("holla@holla.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Holla123")
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        confirmPasswordSecureTextField.typeText("Holla123")
        app.buttons["Female"].tap()
        app.buttons["Register"].tap()
        
    }
    func test_pressCommentSendButton(){
        XCUIApplication().tables.buttons["Send"].tap()
    }
    func test_emailFieldEmpty(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Holla123")
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        confirmPasswordSecureTextField.typeText("Holla123")
        app.buttons["Male"].tap()
        app.buttons["Register"].tap()
        
    }
    func test_passwordFieldEmpty(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("holla@holla.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        confirmPasswordSecureTextField.typeText("Holla123")
        app.buttons["Male"].tap()
        app.buttons["Register"].tap()
        
    }
    
    func test_confirmPasswordFieldEmpty(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("holla@holla.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Holla123")
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        app.buttons["Male"].tap()
        app.buttons["Register"].tap()
        
    }
    
    func test_NoGenderSelected(){
        
        let app = XCUIApplication()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Logout"].tap()
        app.buttons["Don't have an account? Sign Up."].tap()
        
        let usernameTextField = app.textFields["Username"]
        usernameTextField.tap()
        usernameTextField.typeText("Holla")
        
        let emailAddressTextField = app.textFields["Email Address"]
        emailAddressTextField.tap()
        emailAddressTextField.typeText("holla@holla.com")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("Holla123")
        
        let confirmPasswordSecureTextField = app.secureTextFields["Confirm Password"]
        confirmPasswordSecureTextField.tap()
        app.buttons["Register"].tap()
        
    }
    
    func test_changePasswordUnSuccessful(){
        
        let app = XCUIApplication()
        app.buttons["Camera"].tap()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Change Password"].tap()
        
        let currentPasswordSecureTextField = app.secureTextFields["Current Password"]
        currentPasswordSecureTextField.tap()
        currentPasswordSecureTextField.typeText("Holla")
        
        let newPasswordSecureTextField = app.secureTextFields["New Password"]
        newPasswordSecureTextField.tap()
        newPasswordSecureTextField.tap()
        newPasswordSecureTextField.typeText("Holler123")
        
        let newPasswordAgainSecureTextField = app.secureTextFields["New Password, again"]
        newPasswordAgainSecureTextField.tap()
        newPasswordAgainSecureTextField.tap()
        newPasswordAgainSecureTextField.typeText("Holler123")
        app.buttons["Save"].tap()
        
    }
    
    func test_changePasswordSuccessful(){
        
        let app = XCUIApplication()
        app.buttons["Camera"].tap()
        app.tabBars.childrenMatchingType(.Button).elementBoundByIndex(4).tap()
        app.tables.buttons["Change Password"].tap()
        
        let currentPasswordSecureTextField = app.secureTextFields["Current Password"]
        currentPasswordSecureTextField.tap()
        currentPasswordSecureTextField.typeText("Holla123")
        
        let newPasswordSecureTextField = app.secureTextFields["New Password"]
        newPasswordSecureTextField.tap()
        newPasswordSecureTextField.tap()
        newPasswordSecureTextField.typeText("Holler123")
        
        let newPasswordAgainSecureTextField = app.secureTextFields["New Password, again"]
        newPasswordAgainSecureTextField.tap()
        newPasswordAgainSecureTextField.tap()
        newPasswordAgainSecureTextField.typeText("Holler123")
        app.buttons["Save"].tap()
        app.alerts["Password has been changed"].collectionViews.buttons["OK"].tap()
        
    }

    
    func test_changeEmail(){
        
        let app = XCUIApplication()
        app.tables.buttons["Change Email"].tap()
        
        let enterValidEmailTextField = app.textFields["Enter valid email"]
        enterValidEmailTextField.tap()
        enterValidEmailTextField.typeText("haller@holla.com")
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(9).childrenMatchingType(.Other).element.tap()
        
    }
    func test_changeEmailUnSuccessful(){
        
        let app = XCUIApplication()
        app.tables.buttons["Change Email"].tap()
        
        let enterValidEmailTextField = app.textFields["Enter valid email"]
        enterValidEmailTextField.tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).elementBoundByIndex(9).childrenMatchingType(.Other).element.tap()
        
    }
    }
