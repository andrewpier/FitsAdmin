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
import Koloda



class SearchViewTests: XCTestCase {
    
    var searchView: SearchViewController!
    
    override func setUp() {
        super.setUp()
        
        searchView = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SearchView") as! SearchViewController
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    //********* MARK: viewDidLoad and initialization tests **************//
    func testConstantsAreProperlySet() {
        XCTAssertNil(searchView.collectionView , "Before loading the collection view should be nil")
        //do not trigger the viewDidLoad, constants should be set before this
        XCTAssert(searchView.currentRow == 0)
        XCTAssert(searchView.cellsPerRow == 3)
        XCTAssert(searchView.placeHolderImage == UIImage(named: "graySquare.png"))
    }
    
    func initPicturesLoaded(){
        XCTAssertNil(searchView.collectionView , "Before loading the collection view should be nil")
        let _ = searchView.view //access view for first time should trigger ViewDidLoad
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssertTrue(self.searchView.thumbnailArrays[0].count == 10)
        }
    }
    func kolodaViewLoad()
    {
        XCTAssertNil(searchView.kolodaView , "Before loading the collection view should be nil")
        let _ = searchView.view //access view for first time should trigger ViewDidLoad
        XCTAssertNotNil(searchView.kolodaView)

        
    }
    
    func testCollectionViewDataSourceAndDelegateSetToSelf() {
        //when
        XCTAssertNil(searchView.collectionView , "Before loading the collection view should be nil")
        let _ = searchView.view //access view for first time should trigger ViewDidLoad
        // then
        XCTAssertTrue(searchView.collectionView != nil, "The collection view should be set")
        XCTAssert(searchView.collectionView.dataSource === searchView,
                  "The collection view data source should be set to the GalleriesViewController")
        XCTAssert(searchView.collectionView.delegate === searchView, "The collection view delegate should be set to the GalleriesViewController")
    }
    
    func testCollectionViewAddedAsSubview() {
        //when
        XCTAssertNil(searchView.collectionView , "Before loading the collection view should be nil")
        let _ = searchView.view //access view for first time should trigger ViewDidLoad
        // then
        XCTAssertTrue(searchView.collectionView != nil, "The collection view should be set")
        XCTAssert(searchView.collectionView.superview == searchView.view)
    }
    
    func testRefreshControlAddedToCollectionView() {
        //when:
        XCTAssertNil(searchView.refreshControl, "Before loading the collection view should be nil")
        let _ = searchView.view //access view for first time should trigger ViewDidLoad
        //then:
        XCTAssertNotNil(searchView.refreshControl, "refresh controller should be initialized")
        XCTAssert(searchView.refreshControl.superview == searchView.collectionView, "refresh control should be added to the collectionView")
    }
    
    func GetSearchObjectIDsBasedOnString__() {
        //given: Real object ID's of posts with thumbnails
        let searchString = "red sweater"
        let expectation = ["DM8fAS91Qm","pGuzzJV64N","tdZTeishFK"]
        searchView.getSearchTagThumbnails(searchString)
        XCTAssertTrue(searchView.postObjectIDs == expectation)
        //when: we call the query
        //then: the commentedThumbnails class scoped array should hold teh same number of items
        self.waitForExpectationsWithTimeout(30) { error in
            XCTAssertNil(error, "Something went horribly wrong")
            XCTAssert(self.searchView.thumbnailArrays[0].count == 3)
        }
    }
    
    

    }
