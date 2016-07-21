//
//  SettingsTableViewControllerTests.swift
//  Fits
//
//  Created by Stephen D Tam on 3/15/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits
import ParseUI
import Parse

extension XCTestExpectation: SettingsTableViewControllerDelegate {
    func doneGettingSettings() {
        self.fulfill()
    }
    func doneSavingNewEmail() {
        self.fulfill()
    }
    func doneSavingNewPassword() {
        self.fulfill()
    }
    func doneClearingSavedGallery() {
        self.fulfill()
    }
    func doneClearingCommentedGallery() {
        self.fulfill()
    }
    func doneChangingSwitch() {
        self.fulfill()
    }
}

class MockChangeEmailViewController: ChangeEmailViewController {
    var mockField: UITextField = UITextField()
}

class MockReachability: Reachability {
    override class func isConnectedToNetwork() -> Bool {
        return false
    }
}

class SettingsTableViewControllerTests: XCTestCase {
    
    var settingsTableController: SettingsTableViewController!
    override func setUp() {
        super.setUp()
        settingsTableController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsTableViewController") as! SettingsTableViewController
    }
    
    func test__getCurrentSettings__explicitLogin() {
        do {
            try PFUser.logInWithUsername("Stephen", password: "Herbert23")
            XCTAssert(PFUser.currentUser()!["username"] as! String == "Stephen", "Failed to login with test account")
        } catch {
            XCTFail() //issue logging in
        }
        
        //match this data to what exists in parse
        let email = "hello@s.com"
        let gender = "Male"
        let commentsOn = true
        let publicProfile = true
        let notifications = true

        let expectation = expectationWithDescription("Get Current Settings")
        settingsTableController.queriesDelegate = expectation
        
        let _ = settingsTableController.view
        settingsTableController.getCurrentSettings()
        
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.settingsTableController.currentEmail == email, "Email should be \(email)")
            XCTAssert(self.settingsTableController.currentGender == gender, "Gender should be \(gender)")
            XCTAssert(self.settingsTableController.currentCommentsDefaultOn == commentsOn, "Notifications should be \(commentsOn)")
            XCTAssert(self.settingsTableController.currentPublicProfile == publicProfile, "Public Profile should be \(publicProfile)")
            XCTAssert(self.settingsTableController.currentNotificationsSounds == notifications, "Comments should be \(notifications)")
        }
    }
    
    func test__saveNewEmail__WithConnection() {
        let mockChangeEmailVC = MockChangeEmailViewController()
        let email = "valid2@email.com"
        
        mockChangeEmailVC.mockField.text = email
        mockChangeEmailVC.emailTextField =  mockChangeEmailVC.mockField
        mockChangeEmailVC.changeEmailDelegate = settingsTableController
        
        let _ = settingsTableController.view
        
        let expectation = expectationWithDescription("Save New Email")
        settingsTableController.queriesDelegate = expectation
        
        XCTAssert(Reachability.isConnectedToNetwork(), "should be connected to network")
        settingsTableController.saveNewEmail(mockChangeEmailVC)
        
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            let query = PFQuery(className: "User")
            query.whereKey("username", equalTo: self.settingsTableController.currentUser["username"] as! String)
            do {
                let objects = try query.findObjects()
                if(objects.count > 0){
                    XCTAssert(objects[0]["email"] as! String == email, "emails should match")
                }
            } catch {
                XCTFail("somethign went wrong trying to query Parse to match the email")
            }
        }
    }
}
