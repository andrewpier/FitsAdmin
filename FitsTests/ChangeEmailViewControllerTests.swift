//
//  ChangeEmailViewControllerTests.swift
//  Fits
//
//  Created by Stephen D Tam on 3/15/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits
import ParseUI
import Parse

class ChangeEmailViewControllerTests: XCTestCase {
    var changeEmailController: ChangeEmailViewController!

    override func setUp() {
        super.setUp()
        changeEmailController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ChangeEmailViewController") as! ChangeEmailViewController
        let _ = changeEmailController.view
    }
    
    func test__viewDidLoad() {
        XCTAssert(changeEmailController.emailTextField.text == "" || changeEmailController.emailTextField.text == nil , "Email field should start empty")
        XCTAssert(changeEmailController.validEmail == false, "validEmail should start as fasle")
        XCTAssert(changeEmailController.saveBarButton.enabled == false, "save button should start as disabled")
    }
    
    func test__determineStateOfSaveButton__NonEmptyField() {
        let _ = changeEmailController.view //activate the view
        changeEmailController.emailTextField.text = "test"
        changeEmailController.determineStateOfSaveButton()
        XCTAssert(self.changeEmailController.saveBarButton.enabled == true, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__EmptyField() {
        let _ = changeEmailController.view //activate the view
        changeEmailController.emailTextField.text = ""
        changeEmailController.determineStateOfSaveButton()
        XCTAssert(self.changeEmailController.saveBarButton.enabled == false, "Save button should be active")
    }
    
    func test__determineStateOfSaveButton__Nil() {
        let _ = changeEmailController.view //activate the view
        changeEmailController.emailTextField.text = nil
        changeEmailController.determineStateOfSaveButton()
        XCTAssert(self.changeEmailController.saveBarButton.enabled == false, "Save button should be active")
    }
}
