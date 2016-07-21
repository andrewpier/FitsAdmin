//
//  ChangePasswordViewControllerTests.swift
//  Fits
//
//  Created by Stephen D Tam on 3/15/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits

class ChangePasswordViewControllerTests: XCTestCase {
    var changePasswordController: ChangePasswordViewController!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        changePasswordController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChangePasswordViewController") as! ChangePasswordViewController
        let _ = changePasswordController.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test__determineStateOfSaveButton__AllFieldsNonEmpty() {
        changePasswordController.currentPasswordField.text = "test"
        changePasswordController.newPasswordField.text = "test"
        changePasswordController.confirmPasswordField.text = "test"
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == true, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__AllFieldsEmpty() {
        changePasswordController.currentPasswordField.text = ""
        changePasswordController.newPasswordField.text = ""
        changePasswordController.confirmPasswordField.text = ""
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__OnlyCurrentPW() {
        changePasswordController.currentPasswordField.text = "test"
        changePasswordController.newPasswordField.text = ""
        changePasswordController.confirmPasswordField.text = ""
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__OnlyNewPW() {
        changePasswordController.currentPasswordField.text = ""
        changePasswordController.newPasswordField.text = "test"
        changePasswordController.confirmPasswordField.text = ""
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__OnlyConfirmPW() {
        changePasswordController.currentPasswordField.text = ""
        changePasswordController.newPasswordField.text = ""
        changePasswordController.confirmPasswordField.text = "test"
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__CurrentAndNew() {
        changePasswordController.currentPasswordField.text = "test"
        changePasswordController.newPasswordField.text = "test"
        changePasswordController.confirmPasswordField.text = ""
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__CurrentAndConfirm() {
        changePasswordController.currentPasswordField.text = "test"
        changePasswordController.newPasswordField.text = ""
        changePasswordController.confirmPasswordField.text = "test"
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__NewAndConfirm() {
        changePasswordController.currentPasswordField.text = ""
        changePasswordController.newPasswordField.text = "test"
        changePasswordController.confirmPasswordField.text = "test"
        changePasswordController.determineStateOfSaveButton()
        XCTAssert(self.changePasswordController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__checkIfNewAndConfirmFieldsMatch__Matching() {
        changePasswordController.newPasswordField.text = "password"
        changePasswordController.confirmPasswordField.text = "password"
        let result = changePasswordController.checkIfNewAndConfirmFieldsMatch()
        
        XCTAssert(result == true, "check for match should have returned true")
    }
    
    func test__checkIfNewAndConfirmFieldsMatch__NonMatching() {
        changePasswordController.newPasswordField.text = "password"
        changePasswordController.confirmPasswordField.text = "no_match"
        let result = changePasswordController.checkIfNewAndConfirmFieldsMatch()
        
        XCTAssert(result == false, "check for match should have returned false")
    }
    
    func test__isValidPass__ValidPW() {
        changePasswordController.newPasswordField.text = "Valid1"
        let result = changePasswordController.isValidPass(changePasswordController.newPasswordField.text!)
        
        XCTAssert(result == true, "result should have been true")
    }
    
    func test__isValidPass__InvalidPW__NoUpper() {
        changePasswordController.newPasswordField.text = "invalid1"
        let result = changePasswordController.isValidPass(changePasswordController.newPasswordField.text!)
        
        XCTAssert(result == false, "result should have been false")
    }
    
    func test__isValidPass__InvalidPW__NoNum() {
        changePasswordController.newPasswordField.text = "inValid"
        let result = changePasswordController.isValidPass(changePasswordController.newPasswordField.text!)
        
        XCTAssert(result == false, "result should have been false")
    }
    
    func test__isValidPass__InvalidPW__LessThan4() {
        changePasswordController.newPasswordField.text = "1nV"
        let result = changePasswordController.isValidPass(changePasswordController.newPasswordField.text!)
        
        XCTAssert(result == false, "result should have been false")
    }
    

}
