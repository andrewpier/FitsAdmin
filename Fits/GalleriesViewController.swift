//
//  GalleriesViewController.swift
//  Fits
//
//  Created by Stephen D Tam on 2/1/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol GalleriesQueryCompletion{
    func fetchingThumbnailsDone()
    func fetchingObjectIdsDone()
}

class GalleriesViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    enum Gallery: Int {
        case Saved, Mine, Commented //order determines the order in the thmbnailsArray
    }
    //****** MARK: Constants ********//
    let cellsPerRow: CGFloat = 3
    var currentRow = 0 //tracks the current cell selected
    //colors
    var highlightColor = UIColor(red: 0.09, green: 0.388, blue: 0.678, alpha: 1.0)
    //var unselectedColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
    var unselectedColor = SELECTEDBACKGROUNDCOLOR
    let placeHolderImage: UIImage! = UIImage(named: "graySquare.png") //used as place holder when thumbnails are loading in background
    //****** END: Constants *********//
    
    //****** MARK: Class Properties ********//
    var collectionView: UICollectionView! //reference to the collection view
    var refreshControl: UIRefreshControl! //reference to to the refresh control
    var currentGallery: Gallery! //tracks what gallery is being viewed, and is used to point to the correct array in the thumbnails array
    var thumbnailArrays: Array<Array<(pfImageView: PFImageView, objectId: String, date: NSDate)>> = [Array<(pfImageView:PFImageView, objectId:String, date: NSDate)>(), Array<(pfImageView:PFImageView, objectId:String, date: NSDate)>(), Array<(pfImageView:PFImageView, objectId:String, date: NSDate)>()]
    var savedQueryCompletionDelegate: GalleriesQueryCompletion!
    var mineQueryCompletionDelegate: GalleriesQueryCompletion!
    var commentedQueryCompletionDelegate: GalleriesQueryCompletion!
    //Interface outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var commentedButton: UIButton!
    @IBOutlet weak var savedButton: UIButton!
    @IBOutlet weak var mineButton: UIButton!
    @IBOutlet weak var headerLabel: UILabel!
    //will probably later change this to an array of images (all the ones connected with the post)
    var moreInfoPost:UIImageView!
    var goingToMoreInfo: Bool = false
    //******** END: Class Properties **********//
    
    override func viewDidLoad() {
        //notification observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.refreshSavedGallery), name: "SavedPostNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.refreshCommentedGallery), name: "CommentedPostNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.refreshMineGallery), name: "UploadedPostNotification", object: nil)
        highlightColor = headerView.backgroundColor!
        
        //set default gallery, set saved as initial gallery viewed, hide trashcan, show select button
        currentGallery = Gallery.Mine
        getUserPostsThumbnails()
        getSavedPostsThumbnails()
        getCommentedPostsThumbnails()
        
        //handle color changes
        savedButton.backgroundColor = unselectedColor
        savedButton.userInteractionEnabled = true
        mineButton.backgroundColor = highlightColor
        mineButton.userInteractionEnabled = false
        commentedButton.backgroundColor = unselectedColor
        commentedButton.userInteractionEnabled = true
        
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
        let collectionY = headerView.frame.height + commentedButton.frame.height
        let cgorigin = CGPoint(x: 0, y: collectionY)
        let cgsize = CGSize(width: view.frame.width, height: view.frame.height-collectionY)
        let cgrect = CGRect(origin: cgorigin, size: cgsize)
        
        //instantiate a collection view with CGRect from above
        collectionView = UICollectionView(frame: cgrect, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Empty")

        
        //refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(GalleriesViewController.refreshSelectedGallery), forControlEvents: UIControlEvents.ValueChanged)
        collectionView.addSubview(refreshControl)
        collectionView.alwaysBounceVertical = true
        
        
        //add collection as a subview
        self.view.addSubview(collectionView)
        //collection formatting
        collectionView.backgroundColor = BACKGROUNDCOLOR1
        collectionView.reloadData()
        super.viewDidLoad()
    }
    
    //*********** MARK: COLLECTION VIEW DELEGATE METHODS *****************//
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnailArrays[currentGallery.rawValue].count
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (thumbnailArrays[currentGallery.rawValue].count-1) {
            print("we are at da bottom, yo!")
        }
        self.thumbnailArrays[currentGallery.rawValue][indexPath.row].pfImageView.loadInBackground()
        //print(collectionView.contentOffset)
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        //print(thumbnailArrays[currentGallery.rawValue][indexPath.row].objectId)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        currentRow = indexPath.row
        let moreInfo = self.storyboard?.instantiateViewControllerWithIdentifier("More Info") as! PagedScrollViewController
        self.moreInfoPost = thumbnailArrays[currentGallery.rawValue][currentRow].pfImageView as UIImageView
        if(moreInfoPost.image == nil){
            print("captured no image")
        }else{
            
            if(currentGallery != Gallery.Mine){
                moreInfo.hideVotingBubbles = true
            } else{
                moreInfo.hideVotingBubbles = false
            }
            goingToMoreInfo = true
            moreInfo.galleryImage = self.moreInfoPost.image
            moreInfo.objectID = self.thumbnailArrays[currentGallery.rawValue][currentRow].objectId
            self.presentViewController(moreInfo, animated: true, completion: nil)
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) /*as! UICollectionViewCell*/
        //set up cell border and background color
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.layer.borderWidth = 0.75
        cell.backgroundColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 1)
        
        //if the current thumbnail has a file, append the file's image to the current cell
        if(thumbnailArrays[currentGallery.rawValue][indexPath.row].pfImageView.file != nil) {
            
            thumbnailArrays[currentGallery.rawValue][indexPath.row].pfImageView.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            thumbnailArrays[currentGallery.rawValue][indexPath.row].pfImageView.userInteractionEnabled = true
            cell.contentView.addSubview(thumbnailArrays[currentGallery.rawValue][indexPath.row].pfImageView)
            cell.hidden = false
        } else {
            cell.hidden = true //for some reason the cell retains the image, despite the pgimageview being nil, so just hide it
            //let empty = collectionView.dequeueReusableCellWithReuseIdentifier("Empty", forIndexPath: indexPath) /*as! UICollectionViewCell*/
            //return empty
        }
        
        return cell
    }
    
     //*********** END: COLLECTION VIEW DELEGATE METHODS *****************//
    
    /********* MARK: Refresh Control **********/
    func refreshSelectedGallery() {
        switch (self.currentGallery as Gallery){
        case Gallery.Saved:
            
            getSavedPostsThumbnails()
        case Gallery.Mine:

            getUserPostsThumbnails()
        case Gallery.Commented:

            getCommentedPostsThumbnails()
        }
    }
    
    func refreshSavedGallery(notification: NSNotification) {
        getSavedPostsThumbnails()
        print("refreshed the saved gallery")
    }
    
    func refreshCommentedGallery(notification: NSNotification) {
        getCommentedPostsThumbnails()
        print("refreshed the commented gallery")
    }
    
    func refreshMineGallery(notification: NSNotification) {
        getUserPostsThumbnails()
        print("refreshed the mine gallery")
    }
    /********* END: Refresh Control ***********/
     
     /****** MARK: IBAction functions ********/
    @IBAction func savedButtonPress() {
        if(currentGallery != Gallery.Saved) {
            //handle color changes
            savedButton.backgroundColor = highlightColor
            savedButton.userInteractionEnabled = false
            mineButton.backgroundColor = unselectedColor
            mineButton.userInteractionEnabled = true
            commentedButton.backgroundColor = unselectedColor
            commentedButton.userInteractionEnabled = true
            
            //remove any refresh animations
            refreshControl.endRefreshing()
            
            //update the gallery
            collectionView?.reloadData()
            currentGallery = Gallery.Saved
        } else {
            //do nothing
        }
        
    }
    
    @IBAction func mineButtonPress() {
        if(currentGallery != Gallery.Mine) {
            //change tab colors
            savedButton.backgroundColor = unselectedColor
            savedButton.userInteractionEnabled = true
            mineButton.backgroundColor = highlightColor
            mineButton.userInteractionEnabled = false
            commentedButton.backgroundColor = unselectedColor
            commentedButton.userInteractionEnabled = true
            
            //remove any refresh animations
            refreshControl.endRefreshing()
            
            //update the gallery
            collectionView?.reloadData()
            currentGallery = Gallery.Mine
        } else {
            //do nothing
        }
    }
    
    @IBAction func commentedButtonPress() {
        if(currentGallery != Gallery.Commented) {
            //handle color changes
            savedButton.backgroundColor = unselectedColor
            savedButton.userInteractionEnabled = true
            mineButton.backgroundColor = unselectedColor
            mineButton.userInteractionEnabled = true
            commentedButton.backgroundColor = highlightColor
            commentedButton.userInteractionEnabled = false
            
            //remove any refresh animations
            refreshControl.endRefreshing()
            
            //update the gallery
            collectionView?.reloadData()
            currentGallery = Gallery.Commented
        } else {
            //do nothing
        }
    }
    
    /****** END: IBAction functions ********/
    
    func loadMoreInfo(gestureRecognizer: UITapGestureRecognizer){
        let moreInfo = self.storyboard?.instantiateViewControllerWithIdentifier("More Info") as! PagedScrollViewController
        self.moreInfoPost = gestureRecognizer.view! as! UIImageView
        if(moreInfoPost.image == nil){
            print("captured no image")
        }
        if(currentGallery != Gallery.Mine){
            moreInfo.hideVotingBubbles = true
        } else{
            moreInfo.hideVotingBubbles = false
        }
        goingToMoreInfo = true
        moreInfo.galleryImage = self.moreInfoPost.image
        moreInfo.objectID = ""
        moreInfo.pageImages = []
        moreInfo.pageViews = []
        print("func loadMoreInfo sets objectID to \(self.thumbnailArrays[currentGallery.rawValue][currentRow].objectId)")
        moreInfo.objectID = self.thumbnailArrays[currentGallery.rawValue][currentRow].objectId
        self.presentViewController(moreInfo, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(goingToMoreInfo) {
            let dest = segue.destinationViewController as! PagedScrollViewController
            dest.galleryImage = self.moreInfoPost.image
            print("func gallery prepare for segue sets objectID to \(self.thumbnailArrays[currentGallery.rawValue][currentRow].objectId)")
            dest.objectID = self.thumbnailArrays[currentGallery.rawValue][currentRow].objectId
        }
    }
    
    /********* MARK: PARSE QUERIES ***********/
     //This query gets the object IDs of all teh saved posts, then uses those objects IDs to make a second query
    func getSavedPostsThumbnails() {
        //get the object IDs of the posts that the user saved
        var savedPostsObjectIDs: [String] = []
        let savedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
        savedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
        savedPostsObjectIDsQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("Successfully retrieved the object.")
                savedPostsObjectIDs = object?["SavedPosts"] as! [String]
                //now get the saved thumbnails by sending the ibjectIDs to a seperate query
                self.getSavedThumbnailsMatching(savedPostsObjectIDs)
            }
        }
    }
    
    //This functions gets the thumbnails of the user's saved posts matching the given array of object id's
    func getSavedThumbnailsMatching(objectIds: [String]) {
        //retrieve each of the posts with the object IDs in the passed in array
        var index = 0
        let savedPostsQuery = PFQuery(className:"Post")
        savedPostsQuery.whereKey("objectId", containedIn: objectIds)
        savedPostsQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            print("getting thumbnails!")
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) post objects.")
                // Put objects into savedThumbnails
                if let objects = objects {
                    
                    for i in 0..<self.thumbnailArrays[Gallery.Saved.rawValue].count {
                        self.thumbnailArrays[Gallery.Saved.rawValue][i].pfImageView.removeFromSuperview()
                    }
                    
                    self.thumbnailArrays[Gallery.Saved.rawValue] = []
  
                    for object in objects {
                        let pic = object["Thumbnail"] as! PFFile
                        
                        //check if object being added can fit, append if it can't fit
                        self.thumbnailArrays[Gallery.Saved.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate()))
                        
                        self.thumbnailArrays[Gallery.Saved.rawValue][index].objectId = object.objectId!
                        self.thumbnailArrays[Gallery.Saved.rawValue][index].pfImageView.image = self.placeHolderImage
                        self.thumbnailArrays[Gallery.Saved.rawValue][index].pfImageView.file = pic
                        //self.thumbnailArrays[Gallery.Saved.rawValue][index].pfImageView.loadInBackground()
                        index += 1
                    }
                }
                
                //self.thumbnailArrays[Gallery.Saved.rawValue] = self.thumbnailArrays[Gallery.Saved.rawValue].reverse()
                for _ in 0..<3 {
                    self.thumbnailArrays[Gallery.Saved.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate(timeIntervalSince1970: 0)))
                }


                self.refreshControl?.endRefreshing()
                if(self.currentGallery == Gallery.Saved) {
                    self.collectionView?.reloadData()
                }
                self.savedQueryCompletionDelegate?.fetchingThumbnailsDone()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.refreshControl?.endRefreshing()
            }
        }
       
    }
    
    //This function gets the object IDs of all the commented posts for the user, then uses those Object IDs in a second query
    func getCommentedPostsThumbnails() {
        //get the object IDs of the posts that the user saved
        var commentedPostsObjectIDs: [String] = []
        let commentedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
        commentedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
        commentedPostsObjectIDsQuery.getFirstObjectInBackgroundWithBlock {
            (object: PFObject?, error: NSError?) -> Void in
            if error != nil || object == nil {
                print("The getFirstObject request failed.")
            } else {
                // The find succeeded.
                print("Successfully retrieved the object.")
                commentedPostsObjectIDs = object?["PostsCommentedOn"] as! [String]
                //now get the saved thumbnails by sending the ibjectIDs to a seperate query
                self.getCommentedThumbnailsMatching(commentedPostsObjectIDs)
            }
        }
        return
    }
    
    //This function gets the thumbnails of the user's commented posts matching the given array of object Id's
    func getCommentedThumbnailsMatching(objectIds: [String]) {
        //retrieve each of the posts with the object IDs in the passed in array
        let commentedPostsQuery = PFQuery(className:"Post")
        var index = 0
        commentedPostsQuery.whereKey("objectId", containedIn: objectIds)
        commentedPostsQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            print("getting thumbnails!")
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) post objects.")
                // Put objects into savedThumbnails
                if let objects = objects {
                    
                    for i in 0..<self.thumbnailArrays[Gallery.Commented.rawValue].count {
                        self.thumbnailArrays[Gallery.Commented.rawValue][i].pfImageView.removeFromSuperview()
                    }
                    
                    self.thumbnailArrays[Gallery.Commented.rawValue] = []
                    
                    index = 0
                    for object in objects {
                        let pic = object["Thumbnail"] as? PFFile
                        //check if object being added can fit, append if it can't fit
                        self.thumbnailArrays[Gallery.Commented.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate()))
                        
                        self.thumbnailArrays[Gallery.Commented.rawValue][index].objectId = object.objectId!
                        self.thumbnailArrays[Gallery.Commented.rawValue][index].pfImageView.image = self.placeHolderImage
                        self.thumbnailArrays[Gallery.Commented.rawValue][index].pfImageView.file = pic
                        self.thumbnailArrays[Gallery.Commented.rawValue][index].pfImageView.loadInBackground()
                        index += 1
                    }
                }
                
                //self.thumbnailArrays[Gallery.Commented.rawValue] = self.thumbnailArrays[Gallery.Commented.rawValue].reverse()
                for _ in 0..<3 {
                    self.thumbnailArrays[Gallery.Commented.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate(timeIntervalSince1970: 0)))
                }
               

                self.refreshControl?.endRefreshing()
                if(self.currentGallery == Gallery.Commented) {
                    self.collectionView?.reloadData()
                }
                self.commentedQueryCompletionDelegate?.fetchingThumbnailsDone()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    //This query gets all the posts that belong to the current user in one single query
    func getUserPostsThumbnails(){
        //retrieve each of the posts with the object IDs in the passed in array
        let userPostsQuery = PFQuery(className:"Post")
        var index = 0
        userPostsQuery.whereKey("BelongsTo", equalTo: (PFUser.currentUser())!)
        userPostsQuery.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            print("getting thumbnails!")
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) post objects.")
                
                if let objects = objects {
                    
                    for i in 0..<self.thumbnailArrays[Gallery.Mine.rawValue].count {
                        self.thumbnailArrays[Gallery.Mine.rawValue][i].pfImageView.removeFromSuperview()
                    }
                    
                    self.thumbnailArrays[Gallery.Mine.rawValue] = []
                    for _ in 0..<3 {
                        self.thumbnailArrays[Gallery.Mine.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate(timeIntervalSince1970: 0)))
                    }
                    index = 3
                    
                    for object in objects {
                        let pic = object["Thumbnail"] as! PFFile
                        //check if object being added can fit, append if it can't fit
                        
                        self.thumbnailArrays[Gallery.Mine.rawValue].append((pfImageView: PFImageView(), objectId: "", date: NSDate()))
                        
                        self.thumbnailArrays[Gallery.Mine.rawValue][index].objectId = object.objectId!
                        self.thumbnailArrays[Gallery.Mine.rawValue][index].pfImageView.image = self.placeHolderImage
                        self.thumbnailArrays[Gallery.Mine.rawValue][index].date = object.createdAt!
                        self.thumbnailArrays[Gallery.Mine.rawValue][index].pfImageView.file = pic
                        self.thumbnailArrays[Gallery.Mine.rawValue][index].pfImageView.loadInBackground()
                        
                        index += 1
                    }
                    
                }
               
                self.refreshControl?.endRefreshing()
                if(self.currentGallery == Gallery.Mine) {
                    self.thumbnailArrays[Gallery.Mine.rawValue].sortInPlace {
                        return $0.date.timeIntervalSince1970 > $1.date.timeIntervalSince1970
                    }
                    self.collectionView?.reloadData()
                }
                self.savedQueryCompletionDelegate?.fetchingThumbnailsDone()
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
                self.refreshControl?.endRefreshing()
            }
        }
    }
    /********* END: PARSE QUERIES ***********/
    
} //closing brace for GalleriesViewController

