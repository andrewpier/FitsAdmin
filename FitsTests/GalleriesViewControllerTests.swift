//
//  GalleriesViewControllerTests.swift
//  Fits
//
//  Created by Stephen D Tam on 3/3/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import XCTest
@testable import Fits
import ParseUI
import Parse

extension XCTestExpectation: GalleriesQueryCompletion {
    func fetchingThumbnailsDone(){
        self.fulfill()
    }
    func fetchingObjectIdsDone() {
        //nothing
    }
}

class GalleriesViewControllerTests: XCTestCase {
    
    var galleriesController: GalleriesViewController!
    
    override func setUp() {
        super.setUp()
        
        galleriesController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("GalleryView") as! GalleriesViewController
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //********* MARK: viewDidLoad and initialization tests **************//
    func testConstantsAreProperlySet() {
        XCTAssertNil(galleriesController.collectionView , "Before loading the collection view should be nil")
        //do not trigger the viewDidLoad, constants should be set before this
        XCTAssert(galleriesController.currentRow == 0)
        XCTAssert(galleriesController.cellsPerRow == 3)
        XCTAssert(galleriesController.placeHolderImage == UIImage(named: "graySquare.png"))
    }
    
    func testInitialGalleryIsSetToMineGallery() {
        //when:
        XCTAssertNil(galleriesController.collectionView , "Before loading the collection view should be nil")
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        //then: test that saved gallery is selected
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Mine)
    }
    
    func testCollectionViewDataSourceAndDelegateSetToSelf() {
        //when
        XCTAssertNil(galleriesController.collectionView , "Before loading the collection view should be nil")
        let _ = galleriesController.view //access view for first time should trigger ViewDidLoad
        // then
        XCTAssertTrue(galleriesController.collectionView != nil, "The collection view should be set")
        XCTAssert(galleriesController.collectionView.dataSource === galleriesController,
            "The collection view data source should be set to the GalleriesViewController")
        XCTAssert(galleriesController.collectionView.delegate === galleriesController, "The collection view delegate should be set to the GalleriesViewController")
    }
    
    func testCollectionViewAddedAsSubview() {
        //when
        XCTAssertNil(galleriesController.collectionView , "Before loading the collection view should be nil")
        let _ = galleriesController.view //access view for first time should trigger ViewDidLoad
        // then
        XCTAssertTrue(galleriesController.collectionView != nil, "The collection view should be set")
        XCTAssert(galleriesController.collectionView.superview == galleriesController.view)
    }
    
    func testRefreshControlAddedToCollectionView() {
        //when:
        XCTAssertNil(galleriesController.refreshControl, "Before loading the collection view should be nil")
        let _ = galleriesController.view //access view for first time should trigger ViewDidLoad
        //then:
        XCTAssertNotNil(galleriesController.refreshControl, "refresh controller should be initialized")
        XCTAssert(galleriesController.refreshControl.superview == galleriesController.collectionView, "refresh control should be added to the collectionView")
    }
    //********* END: viewDidLoad and initialization tests **************//
    
    //************* MARK: Commented Thumbnails Query Tests ****************//
    
    func test__getCommentedThumbnailsMatching__RealIds() {
        //given: Real object ID's of posts with thumbnails
        let realObjectIds = ["Q9XRbhc7lh","eAFhWTxLbi","kjZxgCe9tI", "6GgQs6sBaX", "jGtbRAXnVV"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.commentedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getCommentedThumbnailsMatching(realObjectIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Commented.rawValue].count == realObjectIds.count + 3)
        }
    }
    
    func test__getCommentedThumbnailsMatching__FakeIds() {
        //given: Real object ID's of posts with thumbnails
        let fakeIds = ["Idx6abcDEF","2VkjfBJC4k","6vBoA9Gabc", "uQe2LOPWvY", "L6Kabc777a"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.commentedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getCommentedThumbnailsMatching(fakeIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Commented.rawValue].count == 0 + 3)
        }
    }
    
    func test__getCommentedThumbnailsMatching__ZeroIds() {
        //given: Real object ID's of posts with thumbnails
        let objectIdsEmpty: [String] = []
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.commentedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getCommentedThumbnailsMatching(objectIdsEmpty)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Commented.rawValue].count == 0 + 3)
        }
    }
    
    func test__getCommentedThumbnailsMatching__RealAndFakeIds() {
        //given: Real object ID's of posts with thumbnails
        let objectIds: [String] = ["6vBoA9Gabc","jGtbRAXnVV","6GgQs6sBaX", "uQe2LOPWvY", "L6Kabc777a"] //[fake, real, real, fake, fake]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.commentedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getCommentedThumbnailsMatching(objectIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Commented.rawValue].count == 2 + 3)
        }
    }
    
    func test__getCommentedThumbnailsMatching__DuplicateIds() {
        //given: Real object ID's of posts with thumbnails
        let duplicateIds: [String] = ["6GgQs6sBaX","6GgQs6sBaX","6GgQs6sBaX", "jGtbRAXnVV", "jGtbRAXnVV"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.commentedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getCommentedThumbnailsMatching(duplicateIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Commented.rawValue].count == 2 + 3)
        }
    }
    
    //************* END: Commented Thumbnails Query Tests ****************//
    
    //************* MARK: Saved Thumbnails Query Tests *****************//
    func test__getSavedThumbnailsMatching__RealIds() {
        //given: Real object ID's of posts with thumbnails
        let realObjectIds = ["Q9XRbhc7lh","eAFhWTxLbi","kjZxgCe9tI", "6GgQs6sBaX", "jGtbRAXnVV"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(realObjectIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == realObjectIds.count + 3)
        }
    }
    
    func test__getSavedThumbnailsMatching__FakeIds() {
        //given: Real object ID's of posts with thumbnails
        let fakeIds = ["Idx6abcDEF","2VkjfBJC4k","6vBoA9Gabc", "uQe2LOPWvY", "L6Kabc777a"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(fakeIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == 0 + 3)
        }
    }
    
    func test__getSavedThumbnailsMatching__EmptyStrings() {
        let objectIds: [String] = ["","Q9XRbhc7lh","jGtbRAXnVV", "", String()] //[empty, real, real, empty, empty]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(objectIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == 2 + 3)
        }
    }
    
    func test__getSavedThumbnailsMatching__ZeroIds() {
        //given: Real object ID's of posts with thumbnails
        let objectIdsEmpty: [String] = []
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(objectIdsEmpty)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == 0 + 3)
        }
    }
    
    func test__getSavedThumbnailsMatching__RealAndFakeIds() {
        //given: Real object ID's of posts with thumbnails
        let objectIds: [String] = ["6vBoA9Gabc","jGtbRAXnVV","6GgQs6sBaX", "uQe2LOPWvY", "L6Kabc777a"] //[fake, real, real, fake, fake]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(objectIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == 2 + 3)
        }
    }
    
    func test__getSavedThumbnailsMatching__DuplicateIds() {
        //given: Real object ID's of posts with thumbnails
        let duplicateIds: [String] = ["6GgQs6sBaX","6GgQs6sBaX","6GgQs6sBaX", "jGtbRAXnVV", "jGtbRAXnVV"]
        let expectation = expectationWithDescription("Get Object Ids")
        galleriesController.savedQueryCompletionDelegate = expectation
        //when: we call the query
        galleriesController.getSavedThumbnailsMatching(duplicateIds)
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.galleriesController.thumbnailArrays[GalleriesViewController.Gallery.Saved.rawValue].count == 2 + 3)
        }
    }
    //************* END: Saved Thumbnails Query Tests ******************//
    
    func test__RefreshControlSpam__Mine() {
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        galleriesController.currentGallery = GalleriesViewController.Gallery.Mine
        
        for _ in 0..<100 {
            galleriesController.refreshSelectedGallery()
        }
    }
    
    func test__RefreshControlSpam__Saved() {
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        galleriesController.currentGallery = GalleriesViewController.Gallery.Saved
        
        for _ in 0..<100 {
            galleriesController.refreshSelectedGallery()
        }
    }
    
    func test__RefreshControlSpam__Commented() {
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        galleriesController.currentGallery = GalleriesViewController.Gallery.Commented
        
        for _ in 0..<100 {
            galleriesController.refreshSelectedGallery()
        }
    }
    
    func test__MineButtonPress() {
        //when:
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        galleriesController.savedButtonPress()
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Saved, "Current Gallery should be Saved")
        galleriesController.mineButtonPress()
        //then:
        XCTAssert(galleriesController.refreshControl.refreshing == false, "Refresh control should not berefreshing")
        
        XCTAssert(galleriesController.mineButton.backgroundColor == galleriesController.highlightColor, "Color should be hihglighted")
        XCTAssert(galleriesController.savedButton.backgroundColor == galleriesController.unselectedColor, "Color should be unselected")
        XCTAssert(galleriesController.commentedButton.backgroundColor == galleriesController.unselectedColor, "Color shoul dbe unselected")
        
        XCTAssert(galleriesController.commentedButton.userInteractionEnabled == true, "button should be enabled")
        XCTAssert(galleriesController.mineButton.userInteractionEnabled == false, "button should be disabled")
        XCTAssert(galleriesController.savedButton.userInteractionEnabled == true, "button should be enabled")
        
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Mine, "Current Gallery should be Mine")
    }
    
    func test__CommentedButtonPress() {
        //when:
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Mine, "Current Gallery should be Mine")
        galleriesController.commentedButtonPress()
        //then:
        XCTAssert(galleriesController.refreshControl.refreshing == false, "Refresh control should not berefreshing")
        
        XCTAssert(galleriesController.commentedButton.backgroundColor == galleriesController.highlightColor, "Color should be hihglighted")
        XCTAssert(galleriesController.savedButton.backgroundColor == galleriesController.unselectedColor, "Color should be unselected")
        XCTAssert(galleriesController.mineButton.backgroundColor == galleriesController.unselectedColor, "Color shoul dbe unselected")
        
        XCTAssert(galleriesController.commentedButton.userInteractionEnabled == false, "button should be disabled")
        XCTAssert(galleriesController.mineButton.userInteractionEnabled == true, "button should be enabled")
        XCTAssert(galleriesController.savedButton.userInteractionEnabled == true, "button should be enabled")
        
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Commented, "Current Gallery should be Commented")
    }
    
    func test__SavedButtonPress() {
        //when: load galleries view and move to a mine tab then move back to saved tab
        XCTAssertNil(galleriesController.currentGallery, "Before loading current gallery should be nil")
        let _ = galleriesController.view
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Mine, "Current Gallery should be Mine")
        galleriesController.savedButtonPress()
        
        //then:
        XCTAssert(galleriesController.refreshControl.refreshing == false, "Refresh control should not berefreshing")
        
        XCTAssert(galleriesController.savedButton.backgroundColor == galleriesController.highlightColor, "Color should be hihglighted")
        XCTAssert(galleriesController.mineButton.backgroundColor == galleriesController.unselectedColor, "Color should be unselected")
        XCTAssert(galleriesController.commentedButton.backgroundColor == galleriesController.unselectedColor, "Color shoul dbe unselected")
        
        XCTAssert(galleriesController.commentedButton.userInteractionEnabled == true, "button should be enabled")
        XCTAssert(galleriesController.mineButton.userInteractionEnabled == true, "button should be enabled")
        XCTAssert(galleriesController.savedButton.userInteractionEnabled == false, "button should be disabled")
        
        XCTAssert(galleriesController.currentGallery == GalleriesViewController.Gallery.Saved, "Current Gallery should be Saved")
    }
}
