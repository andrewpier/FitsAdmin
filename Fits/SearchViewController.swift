//
//  Search View Controller.swift
//  Fits
//
//  Created by Darren Moyer on 2/5/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI
import Koloda

protocol TagQueryCompletion{
    func fetchingThumbnailsDone()
    func fetchingObjectIdsDone()
}
 var numberOfCards: UInt = 1

class SearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    //let voteObserver = Observer()
    
    //tutorial properties
    var tutorialFlag = false
    var userInfo: PFObject?
    var tutorialOverlay: SearchTutorialOverlayView!
   
    @IBOutlet weak var SearchTabItem: UITabBarItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var MyCollectionView: UICollectionView!
    
    
    var kolodaView: KolodaView!
    var searching = false
    // Card constantd for pos
    let SearchViewCardSideMargin: CGFloat = 100
    let SearchViewCardTopMargin:CGFloat = 150
    
    var moreInfoPost:UIImageView!
    var imageObjects: [PFObject]!
    var votes = Array<(String,Bool,Int)>()
    var goingToMoreInfo: Bool = false
    var votedOn = [(1,2)]
    //var didVoteOnce = false
    let numberOfPostsToGet = Int(numberOfCards)
    var votingObject: PFObject? = nil
    var postStack: Array<(PFImageView)> = Array<(PFImageView)>(arrayLiteral: PFImageView())
    var numberOfQueriesProcessed = 0
    var numberTimeSwipped = 0
    let xPos:CGFloat = 275
    let yPos:CGFloat = 450
    var mostRecentPost:Int {
        get {
            if let _  = votingObject {
                return Int(votingObject!["mostRecentPost"].intValue)
            } else {
                return 0
            }
        }
        
        set (value) {
            if let _ = votingObject {
                votingObject!["mostRecentPost"] = value
                votingObject?.pinInBackground()
            }
        }
    }
    func changeNumberOfCards(num: UInt) {
        numberOfCards = num
    }
    
    //MARK: IBActions
    @IBAction func leftButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }
    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }

    

    //****** MARK: Constants ********//
    var loadOnce = false
    let cellsPerRow: CGFloat = 3
    var currentRow = 0 //tracks the current cell selected
    //colors
    var highlightColor = UIColor(red: 0.09, green: 0.388, blue: 0.678, alpha: 1.0)
    var unselectedColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
    let placeHolderImage: UIImage! = UIImage(named: "graySquare.png") //used as place holder when thumbnails are loading in background
    //****** END: Constants *********//
    
    //****** MARK: Class Properties ********//
    var collectionView: UICollectionView! //reference to the collection view
    var thumbnailArrays: Array<Array<(pfImageView: PFImageView, objectId: String)>> = [Array<(pfImageView:PFImageView, objectId:String)>(), Array<(pfImageView:PFImageView, objectId:String)>(), Array<(pfImageView:PFImageView, objectId:String)>()]

    var QueryCompletionDelegate: TagQueryCompletion!

    //Interface outlets
    @IBOutlet weak var headerView: UIView!
    //will probably later change this to an array of images (all the ones connected with the post)
    //var moreInfoPost:UIImageView!
   // var goingToMoreInfo: Bool = false
    var searchString = ""
    var index = 0
    var needNewPosts = false

    //******** END: Class Properties **********//
    override func viewWillAppear(animated: Bool) {
        // getSearchTagThumbnails("red sweater")
    }
    
    override func viewDidLoad() {
        setupElements()
        
        for post in postStack {
            post.layer.cornerRadius = 160
            
        }
        // Make sure we get the local data first!
        getVotingItem()
        //tryME()
        //imageObjectIDs = [String]()
        
        //Make sure we get the local stored data(only need to do this once on setup), then it will call getPostsNew(what you call to get posts in the rest of the code)
        getVotingItem()
        imageObjects = [PFObject]()

        
        kolodaView = KolodaView(frame: CGRect(x: 0, y: 50, width: xPos, height: yPos))
        kolodaView.dataSource = self
        kolodaView.delegate = self
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        
        //voteObserver.react()
        //didVoteOnce.watchME = true
        super.viewDidLoad()
        
        
        searchBar.delegate = self
        searchBar.placeholder = "Ex: red sweater, blue cardigan, casual, etc,."
        //set the first thumnail to null so that it doesnt break the app

        
        //Math to determine size of cells
        let cellWidth = (view.frame.width/cellsPerRow)
        let cellHeight = cellWidth
        
        //setup layout of collection view and cell sizing and padding
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        
        //CGRect math to determine size and origin of collection
        
        let collectionY = headerView.frame.height
        let cgorigin = CGPoint(x: 0, y: collectionY)
        let cgsize = CGSize(width: view.frame.width, height: view.frame.height-collectionY)
        let cgrect = CGRect(origin: cgorigin, size: cgsize)
        
        //instantiate a collection view with CGRect from above
        collectionView = UICollectionView(frame: cgrect, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cells")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Empty")




        
        //refresh control

        collectionView.alwaysBounceVertical = true
        collectionView.scrollEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false

        getNineRandom()
        collectionView.reloadData()
        //add collection as a subview
        self.view.addSubview(collectionView)
        
        
        
        //thumbnailArrays[0] = [(pfImageView: PFImageView(), objectId: "")]
        

    }
    
    func setupElements(){
        //Setup The Tab bar item
        
        
        //Setting Text Color White
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        
        
        //Setting placeholders white
        searchBar.setImage(UIImage(named: "Light_Search.png"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal);
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
        // Force reload of table data
        //loadObjects()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(thumbnailArrays[0].count < 10 ){
            return thumbnailArrays[0].count
        }else{
            return 12
        }
    }

    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        //open more info
        currentRow = indexPath.row
        let moreInfo = self.storyboard?.instantiateViewControllerWithIdentifier("More Info") as! PagedScrollViewController

        self.moreInfoPost = thumbnailArrays[0][currentRow].pfImageView as UIImageView
        if(moreInfoPost.image == nil){
            print("captured no image")
        }else{
        
            goingToMoreInfo = true
            print(self.thumbnailArrays[0][currentRow].objectId)
            moreInfo.galleryImage = self.moreInfoPost.image
            print(self.thumbnailArrays[0][currentRow].objectId)
            moreInfo.objectID = self.thumbnailArrays[0][currentRow].objectId
            moreInfo.hideVotingBubbles = true
            self.presentViewController(moreInfo, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
       // let kWhateverHeightYouWant = 100
        if(indexPath.row == 9){
            
            return CGSizeMake(xPos, CGFloat(yPos))
            //4
        }
        else{
            return CGSizeMake(view.frame.width/cellsPerRow, view.frame.width/cellsPerRow)
        }
    }
    
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) /*as! UICollectionViewCell*/
        let cells = collectionView.dequeueReusableCellWithReuseIdentifier("Cells", forIndexPath: indexPath)
        print(indexPath.row)
        if(indexPath.row < 9 && thumbnailArrays[0][indexPath.row].pfImageView.file != nil){
            
        //set up cell border and background color
            cell.layer.borderColor = UIColor.whiteColor().CGColor
            cell.layer.borderWidth = 0.75
            cell.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
                thumbnailArrays[0][indexPath.row].pfImageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
                thumbnailArrays[0][indexPath.row ].pfImageView.userInteractionEnabled = true
                cell.contentView.addSubview(thumbnailArrays[0][indexPath.row].pfImageView)
                cell.hidden = false
        }else if indexPath.row == 9{
            if(indexPath.row  < thumbnailArrays[0].count){
                cells.contentView.addSubview(kolodaView)
                cells.hidden = false
                return cells
            }
            
            
        }
        else{
                //cell.hidden = true
                cell.hidden = false
                let empty = collectionView.dequeueReusableCellWithReuseIdentifier("Empty", forIndexPath: indexPath)

                return empty
            
            //cell.contentView.removeFromSuperview()
            //return cell
        }

        
        return cell
    }
    

    
    //gives what is in the search bar to grab from parse based on tags
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if(tutorialFlag == false) { //every startup initializes to false, so we have to run query at least once, every time app runs
            loadTutorial()
        }
        
        // Dismiss the keyboard
      //  searching = true
        numberTimeSwipped = 0
        if(searchBar.text == ""){
            getNineRandom()
        }else{
        thumbnailArrays[0] = []

        searchBar.resignFirstResponder()
        NSLog(searchBar.text!.lowercaseString)
        getSearchTagThumbnails(searchBar.text!.lowercaseString)
        searchString = searchBar.text!.lowercaseString
            collectionView.reloadData()
        }
    }
    
    func loadTutorial() {
        let query = PFQuery(className:"UserInformation")
        query.fromLocalDatastore()
        query.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
        do {
            let obj = try query.findObjects()
            if(obj.count != 0) {
                self.userInfo = obj[0]
                self.tutorialFlag = self.userInfo?["HasSearched"] as! Bool
            }
        } catch {
            self.tutorialFlag = false;
        }
        print(self.tutorialFlag)
        if self.tutorialFlag == false{
            self.tutorialOverlay = SearchTutorialOverlayView(frame: UIScreen.mainScreen().bounds)
            self.tutorialOverlay.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.setTutorialFlagOff)))
            
            //add the welcome jawns as subviews, yinz, order matters because of gesture
            self.view.addSubview(tutorialOverlay)
            self.tabBarController?.tabBar.hidden = true
        }
    }
    
    func setTutorialFlagOff() {
        print("turn HasSearched to true")
        self.tabBarController?.tabBar.hidden = false
        UIView.animateWithDuration(0.2, animations: {
            self.tutorialOverlay.alpha = CGFloat(0)
        }) { _ in
            self.tutorialOverlay.removeFromSuperview()
        }
        
        self.userInfo?["HasSearched"] = true
        tutorialFlag = true
        //leave uncommented to make testing easier
        self.userInfo?.saveInBackground()
        
        return
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        // Clear any search criteria
        searchBar.text = ""
        
        // Dismiss the keyboard
        searchBar.resignFirstResponder()
        
    }
    
    //this will grab the thumbails for the tags
    func getSearchTagThumbnails(str: String) {
        //get the object IDs of the posts that the user saved
        searching = true
        var postObjectIDs: [String] = []
        let commentedPostsObjectIDsQuery = PFQuery(className: "Tags")
        commentedPostsObjectIDsQuery.whereKey("Tag", equalTo: str)
        commentedPostsObjectIDsQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                //print("Successfully retrieved the object.")
                postObjectIDs = object?["Posts"] as! [String]
               // print(postObjectIDs)
                //now get the saved thumbnails by sending the ibjectIDs to a seperate query
                let range = Range<Int>(start: (self.numberTimeSwipped)*9, end: (self.numberTimeSwipped+1)*8 + self.numberTimeSwipped)
               // print(range.startIndex.description + " " + range.endIndex.description)
                var posts = [String]()
                var num = 0
                for _ in 0..<postObjectIDs.count{
                    if(num >= range.startIndex && num <= range.endIndex ){
                     //   print(num)
                        posts.append(postObjectIDs[num])
                    }
                    num += 1
                }
             //   print(posts.count)
                self.getSearchTagThumbnailsMatching(posts)
            }
        }
        return
    }
    
    //This function gets the thumbnails of the user's commented posts matching the given array of object Id's
    func getSearchTagThumbnailsMatching(objectIds: [String]) {
        //retrieve each of the posts with the object IDs in the passed in array
        print(objectIds)
        let commentedPostsQuery = PFQuery(className:"Post")
        commentedPostsQuery.whereKey("objectId", containedIn: objectIds)
        commentedPostsQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
           // print("getting thumbnails!")
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) post objects.")
                // Put objects into savedThumbnails
                if let objects = objects {
                    self.index = 0
                    
                    for i in 0..<self.thumbnailArrays[0].count {
                        self.thumbnailArrays[0][i].pfImageView.removeFromSuperview()
                    }
                    
                    self.thumbnailArrays[0] = []
                    for _ in 0..<3 {
                        self.thumbnailArrays[0].append((pfImageView: PFImageView(), objectId: ""))
                    }
                    
                    _ = 0
                    for object in objects {
                        //if(num <= range.endIndex && num >= range.startIndex ){
                            //print(num)
                            let pic = object["Thumbnail"] as? PFFile
                            self.thumbnailArrays[0].append((pfImageView: PFImageView(), objectId: ""))
                            self.thumbnailArrays[0][self.index].objectId = object.objectId!
                            self.thumbnailArrays[0][self.index].pfImageView.image = self.placeHolderImage
                            self.thumbnailArrays[0][self.index].pfImageView.file = pic
                            self.thumbnailArrays[0][self.index].pfImageView.loadInBackground()
                            self.index += 1
                        //}
                        //num += 1
                      
                    }
                }
                print("number in cells" + self.thumbnailArrays[0].count.description)
                self.collectionView?.reloadData()
                self.QueryCompletionDelegate?.fetchingThumbnailsDone()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    func getNineRandom() {
        //get the object IDs of the posts that the user saved
        //let postObjectIDs: [String] = []
        var numArr = [Int]()
        let query = PFQuery(className:"Post")
        var totalPosts: Int = 0
        query.orderByDescending("createdAt")
        query.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in if error != nil || object == nil {
            
            print("The getFirstObject request failed.")
        } else {
            // The find succeeded. print("Successfully retrieved the object.") 
                let num = object!["PostIDNumber"]
                totalPosts = num as! Int
                
                for _ in 0..<14{
                    let dice1 = Int(arc4random_uniform(UInt32(totalPosts)+2))
                    print(dice1)

                    numArr.append(dice1)
                    
                }
               // print(numArr)
                self.fillNineTopImages(numArr)
            }
        }
    }
    
    func fillNineTopImages(objectIds: [Int]) {
        //retrieve each of the posts with the object IDs in the passed in array
        let commentedPostsQuery = PFQuery(className:"Post")
        commentedPostsQuery.whereKey("PostIDNumber", containedIn:  objectIds)
        commentedPostsQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            //print("getting thumbnails!")
            if error == nil {
                // The find succeeded.
               // print("Successfully retrieved \(objects!.count) post objects.")
                // Put objects into savedThumbnails
                if let objects = objects {
                    self.index = 0
                    for i in 0..<self.thumbnailArrays[0].count {
                        self.thumbnailArrays[0][i].pfImageView.removeFromSuperview()
                    }
                    
                    self.thumbnailArrays[0] = []
                    for _ in 0..<3 {
                        self.thumbnailArrays[0].append((pfImageView: PFImageView(), objectId: ""))
                    }
                    

                    for object in objects {
                        let pic = object["Thumbnail"] as? PFFile
                        //add "cell" to the view
                        //print("adding more cells!!" + object.objectId!)
                        if(self.index <= 9){
                            self.thumbnailArrays[0].append((pfImageView: PFImageView(), objectId: ""))
                        
                            self.thumbnailArrays[0][self.index].objectId = object.objectId!
                            self.thumbnailArrays[0][self.index].pfImageView.image = self.placeHolderImage
                            self.thumbnailArrays[0][self.index].pfImageView.file = pic
                            self.thumbnailArrays[0][self.index].pfImageView.loadInBackground()
                            self.index += 1
                        }
                        
                    }
                }
                self.collectionView?.reloadData()
                self.QueryCompletionDelegate?.fetchingThumbnailsDone()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func refreshView(){
        for i in 0..<self.thumbnailArrays[0].count {
            self.thumbnailArrays[0][i].pfImageView.removeFromSuperview()
        }
        
        self.thumbnailArrays[0] = []
        for _ in 0..<3 {
            self.thumbnailArrays[0].append((pfImageView: PFImageView(), objectId: ""))
        }
    }
   
}

extension SearchViewController: KolodaViewDelegate {
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        //Example: loading more cards
        collectionView.setContentOffset(CGPointZero, animated:true)

        //didVoteOnce.watchME = true
        mainInstance.voteOnce = true
        if(searching){
            numberTimeSwipped = numberTimeSwipped + 1
            getSearchTagThumbnails(searchString)
        }else{
            kolodaView.removeFromSuperview()
            getNineRandom()
        }
        
        /*
         load more shit goes here and scroll to the top of the collection
         
         */

   
        collectionView.reloadData()
        
        //collectionView.reloadItemsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0),NSIndexPath(forRow: 1, inSection: 0)])

        
        
        if(direction == SwipeResultDirection.Left){
            if (Int(index) < imageObjects.count){
                let num = imageObjects[Int(index)]["PostIDNumber"]
                votes.append((imageObjects[Int(index)].objectId!, false, num as! Int))
            }
        }
        if(direction == SwipeResultDirection.Right){
            if (Int(index) < imageObjects.count){
                let num = imageObjects[Int(index)]["PostIDNumber"]
                votes.append((imageObjects[Int(index)].objectId!, true, num as! Int))
            }
        }
        
    }
    
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Reloading Images
        imageObjects.removeAll()
        
        getMostRecentPostIDNumber()
        kolodaView.resetCurrentCardNumber()
        sendPostVotes()
    }
    
    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
        //Need to load the more info view here
        // print("Card at index \(index) selected")
        let moreInfo = self.storyboard?.instantiateViewControllerWithIdentifier("More Info") as! PagedScrollViewController
        let thisCard = postStack[Int(index)]
        if(thisCard.image == nil){
            print("No image loaded for this card: Cannot open MoreInfo view")
        } else {
            goingToMoreInfo = true
            moreInfo.galleryImage = thisCard.image
            moreInfo.hideVotingBubbles = true
            moreInfo.objectID = self.imageObjects[Int(index)].objectId!
            self.presentViewController(moreInfo, animated: true, completion: nil)
        }
        
    }
    
    func koloda(koloda: KolodaView, didShowCardAtIndex index: UInt) {
        
    }
}


extension SearchViewController: KolodaViewDataSource {
    
    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return numberOfCards
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {
        return self.postStack[Int(index)]
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
    }
    
    
    // Handling the votedOn Array, Keeping track of the posts a user votes on so they never get the same post twice
    func updateVotedOn(a: Array<Int>) {
        //Get the max and min of the section of posts the user voted on
        var max = INT16_MIN
        var min = INT16_MAX
        for i in a {
            let iprime = Int32(i)
            if ( iprime > max) {
                max = iprime
            }
            if ( iprime < min){
                min = iprime
            }
        }
        if (min == INT16_MAX || max == INT16_MIN){
            print("There are no items left")
        } else {
            // Add the sector to our list of posts voted on and collapse ranges as necessary
            collapseVotedOn((Int(min),Int(max)))
        }
        //print(votedOn)
    }
    
    func collapseVotedOn(newEntry: (Int,Int)){
        var tempArray = Array<(Int,Int)>()
        var amIEntered = false
        for var votedOnSector in votedOn {
            // Insert elements until the current sector we are working with is supposed to be entered
            if(votedOnSector.1 < newEntry.0){
                tempArray.append(votedOnSector)
            }
            // Only insert the element if it is larger then our current sector's max
            if(votedOnSector.0 > newEntry.1){
                //If it is the first time entering an element larger then our sector enter our sector first
                if (!amIEntered){
                    //Before entering our sector see if we need to combine a range
                    if( (newEntry.1+1) == votedOnSector.0){
                        votedOnSector.0 = newEntry.0
                    } else {
                        appendElementWithPreviousCloseCheck(newEntry, toArray: &tempArray)
                    }
                    amIEntered = true
                }
                // Otherwise Add the element to the list making sure to combine with previous sectors when necessary
                appendElementWithPreviousCloseCheck(votedOnSector, toArray: &tempArray)
            }
        }
        // If our sector is the largest make sure we append our sector
        if (!amIEntered){
            appendElementWithPreviousCloseCheck(newEntry, toArray: &tempArray)
            amIEntered = true
        }
        
        // print(tempArray)
        votedOn = tempArray
    }
    
    func appendElementWithPreviousCloseCheck(element: (Int,Int), inout toArray: Array<(Int,Int)>){
        // Check the two sectors to see if they are neighbors (the next number), if so combine otherwise append the new sector
        if(toArray[toArray.count-1].1 == (element.0-1)){
            toArray[toArray.count-1].1 = element.1
        } else {
            toArray.append(element)
        }
    }
    
    
    //Handling grabbing the post numbers so we know which posts to query for
    func getSubsectionPostUniqueNumbers(sector: Int, numberOfPostsNeeded: Int) -> Array<Int> {
        var currentSector = sector
        var results = Array<Int>()
        if (currentSector > votedOn.count) {
            print("There are no more posts to vote on at this time.")
            return Array<Int>()
        }
        var high:Int = -1
        if (currentSector < 2){
            high = mostRecentPost+1
        } else {
            high = votedOn[votedOn.count-(currentSector-1)].0
        }
        let low = votedOn[votedOn.count-currentSector].1
        // Check to see if we need to get more posts
        if (numberOfPostsNeeded > ((high-low)-1)){
            // Increaseing the sector we are looking at in the votedOn queue
            currentSector += 1
            //Adding our current post numbers to the results
            for i in (low+1)..<high {
                results.append(i)
            }
            // Recuresivly calling to get more
            results.appendContentsOf(getSubsectionPostUniqueNumbers(currentSector, numberOfPostsNeeded: numberOfPostsNeeded-((high-low)-1)))
        } else {
            // Add the proper number of posts to the results
            for i in 0..<numberOfPostsNeeded {
                results.append(high-(i+1))
            }
        }
        return results
    }
    
    //Handling grabbing the post numbers so we know which posts to query for
    func getPostUniqueNumbers() -> Array<Int> {
        var results = Array<Int>()
        // Check to see if we enough new posts to work with, otherwise explore our array of votedOn posts
        let mostRecentlyVotedOnID = votedOn[votedOn.count-1].1
        if ((mostRecentPost - mostRecentlyVotedOnID) >= numberOfPostsToGet) {
            // If we have enough new posts just return them
            for i in 0..<numberOfPostsToGet {
                results.append(mostRecentPost-i)
            }
        } else {
            results.appendContentsOf(getSubsectionPostUniqueNumbers(1, numberOfPostsNeeded: numberOfPostsToGet))
        }
        return results
    }
    
    //Getting post objects for the Card Stack
    func getPostsNew(){
        let postNumbers = getPostUniqueNumbers()
        //print(postNumbers)
        let query = PFQuery(className: "Post")
        query.whereKey("PostIDNumber", containedIn: postNumbers)
        query.orderByDescending("PostIDNumber")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                // print("Successfully retrieved \(objects!.count) voting objects.")
                // Do something with the found objects
                if let _ = objects {
                    var index = 0
                    for object in objects!{
                        let pic = object["ThumbnailRect"] as! PFFile
                        self.imageObjects.append(object)
                        self.postStack[index].userInteractionEnabled = true
                        self.postStack[index].file = pic
                        self.postStack[index].loadInBackground()
                        index += 1
                    }
                    if (objects!.count < Int(numberOfCards)){
                        for index in 0..<(Int(numberOfCards) - objects!.count) {
                            self.fillCardWithPlaceholderInformation(objects!.count + index)
                        }
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //Getting the ID so we know what the most recent post is so we can grab it if there is a new one
    func getMostRecentPostIDNumber(){
        let query = PFQuery(className:"Voting")
        query.whereKeyExists("mostRecentPost")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                //  print("Successfully retrieved \(objects!.count) objects for MostRecentPostIDNumber.")
                if let _ = objects{
                    for obj in objects!{
                        self.mostRecentPost = obj["mostRecentPost"] as! Int
                    }
                }
                
                self.getPostsNew()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    //Create the most recent item in the local storage
    func createVotingItem(){
        let gameScore = PFObject(className: "Voting")
        gameScore.objectId = "VotingObject"
        gameScore["mostRecentPost"] = self.mostRecentPost
        do {
            try gameScore.pin()
        } catch _ {
            print("Something went wrong in trying to pin the object")
        }
        // print(gameScore)
        
    }
    
    //Getting the most recent item from the local storage
    func getVotingItem() {
        let query = PFQuery(className:"Voting")
        query.fromLocalDatastore()
        query.getObjectInBackgroundWithId("VotingObject", block: { (objects: PFObject?, error: NSError?) -> Void in
            if error == nil {
                //print(objects)
                self.votingObject = objects
                self.getMostRecentPostIDNumber()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                print("----")
                print("Solving error: Creating object.")
                self.createVotingItem()
                print("Problem Solved")
                print("Trying again")
                self.getVotingItem()
                print("Finito")
            }
        })
        
    }
    
    //Record the votes
    func sendPostVotes() {
        
        var ids = Array<String>()
        var choices = Array<Bool>()
        var sectionVotedOn = Array<Int>()
        let size = votes.count
        
        for vote in votes {
            ids.append(vote.0)
            choices.append(vote.1)
            sectionVotedOn.append(vote.2)
        }
        votes.removeAll()
        
        PFCloud.callFunctionInBackground("addVotes", withParameters: ["number": size, "posts": ids,"votes": choices]) { (response: AnyObject?, error: NSError?) -> Void in }
        
        //Comment this out if you want an infinite loop of posts
        self.updateVotedOn(sectionVotedOn)
    }
    
    func fillCardWithPlaceholderInformation(index: Int){
        //postStack[index].image = UIImage().makeImageWithColorAndSize(SELECTEDBACKGROUNDCOLOR, accentColor: ACCENTCOLOR, size: CGSizeMake(postStack[index].frame.width, postStack[index].frame.height))
        postStack[index].image = nil
    }
}




