//
//  PagedScrollViewController.swift
//  Fits
//
//  Created by Sophia Gebert on 2/1/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit
import Parse

protocol MoreInfoViewControllerDelegate {
    func doneSavingImage()
    func doneGettingComments()
    func donePostingComment()
}

class PagedScrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate {
    let center = NSNotificationCenter.defaultCenter()
    var queriesDelegate: MoreInfoViewControllerDelegate!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var commentTable: UITableView!
    @IBOutlet weak var xButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    var pageImages: [UIImage] = []
    var pageViews: [UIImageView?] = []
    var galleryImage: UIImage!
    var commentsEnabled = true
    var noComments = false
    var hideVotingBubbles: Bool! = false
    var hideStarButton: Bool! = false
    var postCommentSucessful = false
    var deviceModel:String!
    var descriptionForPost: String!
    var TextfieldSelectedForEditingLocation: CGPoint!
    
    //voting bubbles and label
    var greenBubbleImage = UIImage(named: "greenEllipse.png")
    var redBubbleImage = UIImage(named: "redEllipse.png")
    var yellowStarImage = UIImage(named: "starYellow.png")
    var grayStarImage = UIImage(named: "starGray.png")
    
    @IBOutlet var yesStatsLabel: UILabel!
    @IBOutlet var noStatsLabel: UILabel!
    @IBOutlet var yesVotingBubble: UIImageView!
    @IBOutlet var noVotingBubble: UIImageView!
    @IBOutlet var starImageView: UIImageView!
    @IBOutlet var saveImageButton: UIButton!
   
    var commentString: String!
    //var saveImageButton: UIButton!
    var alreadySavedPost: Bool = false
    var savePost = false
    //cell stuff
    var currentCell = 0
    
    //items array used for test purposes only
    var commentsOnPost: [String] = []
    
    //parse stuff 
    var objectID: String! 
    var kbHeight: CGFloat!
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PagedScrollViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PagedScrollViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
   
        //clear description string
       descriptionForPost = ""
        getDescriptionForPost()
        
        //clear photo arrays 
        pageImages = []
        pageViews = []
        
        //set up comment cell
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Comment")
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "NoComments")
        self.commentTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CommentsDisabled")
        commentTable.dataSource = self
        commentTable.delegate = self
        commentTable.estimatedRowHeight = 200
        commentTable.rowHeight = UITableViewAutomaticDimension
        //print("mid")
        //hide star button if needed
        if(hideStarButton == true){
            starImageView.hidden = true
            saveImageButton.hidden = true
        } else {
            if(alreadySavedPost){
                starImageView.image = yellowStarImage
                saveImageButton.hidden = false
                starImageView.hidden = false
            } else{
                starImageView.image = grayStarImage
                saveImageButton.hidden = false
                starImageView.hidden = false
            }
        }

        var pageCount = pageImages.count
        if(galleryImage != nil){
            pageImages = []
            pageViews = []
            pageImages = [galleryImage]
            getOtherPostImages(objectID)
            pageCount = pageImages.count
        }else{
            //print("error loading images")
        }
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = pageCount
        
        for _ in 0..<pageCount {
            pageViews.append(nil)
        }
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSize(width: pagesScrollViewSize.width * CGFloat(pageImages.count),
            height: pagesScrollViewSize.height)

        loadVisiblePages()
        commentTable.reloadData()
    }
    override func viewWillAppear(animated: Bool) {
        descriptionForPost = ""
        //print("willAppear")
        if(hideVotingBubbles == true){
            yesVotingBubble.hidden = true
            noVotingBubble.hidden = true
            yesStatsLabel.hidden = true
            noStatsLabel.hidden = true
            
        } else{
            yesStatsLabel.text = ""
            noStatsLabel.text = "" 
            getVotingStatistics()
            yesStatsLabel.numberOfLines = 1
            yesStatsLabel.adjustsFontSizeToFitWidth = true
            noStatsLabel.numberOfLines = 1
           // noStatsLabel.adjustsFontSizeToFitWidth = true
            getDeviceModel()
            //print("yes label size = \(yesStatsLabel.font.pointSize)")
            if(deviceModel == "iphone 5s" || deviceModel == "iphone 4s" || deviceModel == "iphone 5" && !hideVotingBubbles){
                yesStatsLabel.font = UIFont(name: (yesStatsLabel?.font.fontName)!, size: (yesStatsLabel.font?.pointSize)!-5.0)
                noStatsLabel.font = UIFont(name: (noStatsLabel?.font.fontName)!, size: (noStatsLabel.font?.pointSize)!-5.0)
               noStatsLabel.textAlignment = NSTextAlignment.Left
            }
            
        }
       
        //clear comment array before fetching comments
        if(commentsOnPost.count > 0){
            commentsOnPost.removeAll()
        }
        getDescriptionForPost()
        setCommentsEnabledFlag()
        checkIfPostSavedAlready()

    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
         NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
   
    ///////////////////////////////////////
    /////       Set up Stuff      ////////
    /////////////////////////////////////
    func getDeviceModel(){
        switch UIDevice().type {
        case .iPhone4S:
            deviceModel = "iphone 4s"
        case .iPhone5:
            deviceModel = "iphone 5"
        case .iPhone5S:
            deviceModel = "iphone 5s"
        case .iPhone6S:
            fallthrough
        case .iPhone6Splus:
            fallthrough
        case .iPhone6:
            deviceModel = "iphone 6"
        case .iPhone6plus:
            deviceModel = "iphone 6Plus"
        default:
            deviceModel = "iphone simulator"
            //print("not 5 or 4 model iphone")
        }
    }
    func getOtherPostImages(postID: String){
        //print("Grabbing additional images for post with objectID = \(objectID)")
        let retrieveOtherPostPictureQuery = PFQuery(className: "PostImages")
        retrieveOtherPostPictureQuery.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: objectID))
        retrieveOtherPostPictureQuery.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found \(objects!.count) additional images " )
                if let _ = objects {
                    for object in objects! {
                        if let pic = object["Image1"] as? PFFile {
                            pic.getDataInBackgroundWithBlock({(imageFile: NSData?, error: NSError?) -> Void in
                                if(error == nil){
                                    print("setting image1")
                                    let image = UIImage(data: imageFile!)
                                    self.pageImages.append(image!)
                                    self.pageViews.append(UIImageView(image: image!))
                                    self.pageControl.numberOfPages = self.pageImages.count
                                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.pageImages.count),
                                        height: self.scrollView.frame.size.height)
                                    self.loadVisiblePages()
                                    print("pageView size \(self.pageViews.count)")
                                }
                            })
                        }
                        if let pic = object["Image2"] as? PFFile{
                            pic.getDataInBackgroundWithBlock({(imageFile: NSData?, error: NSError?) -> Void in
                                if(error == nil){
                                    let image = UIImage(data: imageFile!)
                                    print("setting image2")
                                    self.pageImages.append(image!)
                                    self.pageViews.append(UIImageView(image: image!))
                                    self.pageControl.numberOfPages = self.pageImages.count
                                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.pageImages.count),
                                        height: self.scrollView.frame.size.height)
                                    self.loadVisiblePages()
                                }
                            })
                        }
                        if let pic = object["Image3"] as? PFFile{
                            pic.getDataInBackgroundWithBlock({(imageFile: NSData?, error: NSError?) -> Void in
                                if(error == nil){
                                    print("setting image3")
                                    let image = UIImage(data: imageFile!)
                                    self.pageImages.append(image!)
                                    self.pageViews.append(UIImageView(image: image!))
                                    self.pageControl.numberOfPages = self.pageImages.count
                                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.pageImages.count),
                                        height: self.scrollView.frame.size.height)
                                    self.loadVisiblePages()
                                }
                            })
                        }
                        if let pic = object["Image4"] as? PFFile{
                            pic.getDataInBackgroundWithBlock({(imageFile: NSData?, error: NSError?) -> Void in
                                if(error == nil){
                                    print("setting image4")
                                    let image = UIImage(data: imageFile!)
                                    self.pageImages.append(image!)
                                    self.pageViews.append(UIImageView(image: image!))
                                    self.pageControl.numberOfPages = self.pageImages.count
                                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.pageImages.count),
                                        height: self.scrollView.frame.size.height)
                                    self.loadVisiblePages()
                                }
                            })
                        }
                        if let pic = object["Image5"] as? PFFile{
                            pic.getDataInBackgroundWithBlock({(imageFile: NSData?, error: NSError?) -> Void in
                                if(error == nil){
                                    print("setting image5")
                                    let image = UIImage(data: imageFile!)
                                    self.pageImages.append(image!)
                                    self.pageViews.append(UIImageView(image: image!))
                                    self.pageControl.numberOfPages = self.pageImages.count
                                    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(self.pageImages.count),
                                        height: self.scrollView.frame.size.height)
                                    self.loadVisiblePages()
                                }
                            })
                        }
                        
                    }
                }
                
            } else {
                print("image grab failed")
            }
        })
    }
    func getCommentsForPost(){
        //retrieve all the comments related to the post.
        //set up query
        //print("Grabbing comments for post with objectID = \(objectID)")
        let myObj = PFQuery(className: "PostTextItems")
        myObj.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: objectID))
        
        
        
        myObj.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        //print("setting comment array")
                        self.commentsOnPost = object["Comments"] as! [String]
                        //get rid of any leading blank comments
                        
                        if(self.commentsOnPost.count == 0){
                            //print("no comments found for post")
                            self.noComments = true
                        }
                        self.commentTable.reloadData()
                    }
                }
                
            } else {
                //print("Getcommentsforpost failed")
            }
            //self.queriesDelegate?.doneGettingComments()
        })
    }
    
    func getDescriptionForPost(){
        let votingStatisticsPostsObjectIDsQuery = PFQuery(className: "PostTextItems")
        votingStatisticsPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: objectID))
        votingStatisticsPostsObjectIDsQuery.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found post description object  \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        //print("setting description for post")
                        let description = object["UsersPostInformation"] as! String
                        self.descriptionForPost = description
                        
                    }
                    if(objects?.count <= 0) {
                        //print("no description so clearing text")
                        self.descriptionForPost = ""
                    }
                }
            } else {
                //print("query for description for post failed")
            }
        })
    }
    
    func getVotingStatistics(){
        //save post to correct User's comment gallery
        let votingStatisticsPostsObjectIDsQuery = PFQuery(className: "PostStatistics")
        votingStatisticsPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: objectID))
        votingStatisticsPostsObjectIDsQuery.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found voting statistics object  \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        let noVoteCount = object["NegativeVotes"] as! Double
                        let yesVoteCount = object["PositiveVotes"] as! Double
                        let totalCount = noVoteCount + yesVoteCount
                        if(totalCount > 0){
                            let noPercent = (noVoteCount/totalCount)*100.0
                            self.noStatsLabel.text = String(format: "%.2f", noPercent) + "%"
                            let yesPercent = (yesVoteCount/totalCount)*100.0
                            self.yesStatsLabel.text = String(format: "%.2f", yesPercent) + "%"
                        } else {
                            self.noStatsLabel.text = "0.0"
                            self.yesStatsLabel.text = "0.0"
                        }
                    }
                    if(objects?.count <= 0) {
                        self.noStatsLabel.text = ""
                        self.yesStatsLabel.text = ""
                    }
                }
            } else {
                //print("Upload Failed")
            }
        })
    }
    
    func setCommentsEnabledFlag(){
        let myObj = PFQuery(className: "Post")
        myObj.whereKey("objectId", equalTo: objectID)
        myObj.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found enable comments query \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        self.commentsEnabled = object["AllowComments"] as! Bool
                    }
                    self.commentTable.reloadData()
                }
            } else {
                //print("Upload Failed")
            }
            if(self.commentsEnabled == true){
                self.getCommentsForPost()
            }
            self.commentTable.reloadData()
        })
        
    }

    ///////////////////////////////////////
    /////       Scroll View Stuff   //////
    /////////////////////////////////////
    func loadPage(page: Int) {
        let tapRec = UITapGestureRecognizer(target: self, action: #selector(PagedScrollViewController.loadZoomView(_:)))
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
     if let _ = pageViews[page] {
            // Do nothing. The view is already loaded.
        } else {
            var frame = scrollView.bounds
            frame.origin.x = frame.size.width * CGFloat(page)
            frame.origin.y = 0.0
       
        
        
         saveImageButton.addTarget(self, action: #selector(PagedScrollViewController.saveImage(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
            let newPageView = UIImageView(image: pageImages[page])
            newPageView.addGestureRecognizer(tapRec)
            newPageView.userInteractionEnabled = true;
            newPageView.contentMode = .ScaleAspectFit
            newPageView.frame = frame
            
            scrollView.addSubview(newPageView)
            pageViews[page] = newPageView
        }
    }
    func purgePage(page: Int) {
        if page < 0 || page >= pageImages.count {
            // If it's outside the range of what you have to display, then do nothing
            return
        }
        
        // Remove a page from the scroll view and reset the container array
        if let pageView = pageViews[page] {
            pageView.removeFromSuperview()
            pageViews[page] = nil
        }
    }
    func loadVisiblePages() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
        
        // Work out which pages you want to load
        let firstPage = page - 1
        let lastPage = page
        
        // Purge anything before the first page
        if (0 < firstPage) {
            for index in 0 ..< firstPage {
                purgePage(index)
            }
        }
        
        // Load pages in our range
        for index in firstPage...lastPage {
            loadPage(index)
        }
        
        // Purge anything after the last page
        if ( lastPage+1 < pageImages.count ) {
            for index in lastPage+1 ..< pageImages.count {
                purgePage(index)
            }
        }
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        loadVisiblePages()
    }
   
    
    
    ///////////////////////////////////////
    /////       Table View Stuff   //////
    /////////////////////////////////////
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if comments are enabled for the post, return the number of comments, otherwise return 1
        if(commentsEnabled){
            //check if there are actually any comments first
            if(commentsOnPost.count == 0){
                return 1
            }else{
                noComments = false
                return commentsOnPost.count + 1 //for the comments and the extra cell to leave another comment
            }
        }else{
            return 2
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(commentsEnabled){
            //return a special cell if there aren't any comments for the post
            if(noComments){
                if(indexPath.row == 0){
                    let cell = self.commentTable.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.contentView.frame.origin.x = cell.contentView.frame.origin.x - 40.0
                    cell.descriptionLabel.text = descriptionForPost
                    return cell
                } else {
                    let cell = self.commentTable.dequeueReusableCellWithIdentifier("LeaveComment", forIndexPath: indexPath) as! LeaveCommentCell
                    let placholderString = cell.commentTextField.placeholder!
                    cell.commentTextField.attributedPlaceholder = NSAttributedString(string: placholderString, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
                    cell.commentTextField.delegate = self
                    cell.awakeFromNib()
                    //print("made a LeaveCommentCell")
                    return cell
                }
            } else{
                //at least 1 comment has been made
                if(indexPath.row == 0){
                    let cell = self.commentTable.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                    cell.contentView.frame.origin.x = cell.contentView.frame.origin.x - 40.0
                    cell.descriptionLabel.text = descriptionForPost
                    return cell
                } else {
                    if(commentsOnPost.count != 0 && indexPath.row != commentsOnPost.count){
                        let cell = tableView.dequeueReusableCellWithIdentifier("Comment", forIndexPath: indexPath)
                        cell.textLabel!.lineBreakMode = NSLineBreakMode.ByWordWrapping
                        cell.textLabel!.numberOfLines = 0
                        cell.backgroundColor = UIColor(white: 1.0, alpha: 0.05)
                        cell.textLabel?.textColor = UIColor(white: 1.0, alpha: 0.75)
                        cell.textLabel!.preferredMaxLayoutWidth = 272
                        cell.textLabel?.text = commentsOnPost[indexPath.row]
                        cell.textLabel!.sizeToFit()
                        return cell
                    } else{
                        let cell = tableView.dequeueReusableCellWithIdentifier("LeaveComment", forIndexPath: indexPath) as! LeaveCommentCell
                        let placholderString = cell.commentTextField.placeholder!
                        cell.commentTextField.attributedPlaceholder = NSAttributedString(string: placholderString, attributes:[NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.35)])
                        cell.commentTextField.delegate = self
                        cell.commentTextField.text = ""
                        return cell
                    }
                }
            }
        }else{
            //comments are disabled, so display 1 cell with that message
            if(indexPath.row == 0){
                let cell = self.commentTable.dequeueReusableCellWithIdentifier("DescriptionCell", forIndexPath: indexPath) as! DescriptionTableViewCell
                cell.contentView.frame.origin.x = cell.contentView.frame.origin.x - 40.0
                cell.descriptionLabel.text = descriptionForPost
                return cell
            } else {
                //print("supposedly made a commentdisabled cell")
                let cell = self.commentTable.dequeueReusableCellWithIdentifier("CommentsDisable", forIndexPath: indexPath)
                cell.contentView.frame.origin.x = cell.contentView.frame.origin.x - 40.0
                return cell
            }
           
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        //print("You selected cell #\(indexPath.row)!")
        
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

        currentCell = indexPath.row
        return indexPath
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return UITableViewAutomaticDimension
    }
    
    func makeCommentCell(){
        if(commentString != nil){
            noComments = false
            commentsOnPost.append(commentString)
        }
    }
    
    ///////////////////////////////////////
    /////       TextField  Stuff   ///////
    /////////////////////////////////////
    
    func textFieldDidEndEditing(textField: UITextField) {
        //save the written comment in the textfield to a string to upload to parse
        commentString = textField.text
        //clear the entered text
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        //save the written comment in the textfield to a string to upload to parse
        commentString = textField.text
        //clear the entered text
       textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //save the written comment in the textfield to a string to upload to parse
        commentString = textField.text
        textField.resignFirstResponder()
        postComment(textField)
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        
    }
    @IBAction func TouchUpInsideField(sender: UIView) {
        let globalPoint = sender.superview?.convertPoint(sender.frame.origin, toView: nil)
        print(globalPoint)
        TextfieldSelectedForEditingLocation = globalPoint
    }
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let loactionOfTextfieldSelected = TextfieldSelectedForEditingLocation {
                let topOfKeyboard = (self.view.window?.frame.height)! - keyboardSize.height
                print("Top Of Keyboard: " + String(topOfKeyboard))
                let distanceToMove = loactionOfTextfieldSelected.y - (topOfKeyboard - 85)
                if (distanceToMove > 0){
                    print(distanceToMove)
                    self.view.frame.origin.y += keyboardSize.height
                }
            }
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y -= self.view.frame.origin.y
    }
    
    ///////////////////////////////////////
    /////   Parse Calls Post/Save  ///////
    /////////////////////////////////////
    
    @IBAction func postComment(sender: AnyObject!) {
        //dismiss keyboard
        
        self.view.endEditing(true)
        postCommentSucessful = false
        makeCommentCell()
        if(commentString != "" && commentString != nil){
            //save comment to database
            //print("tried posting a comment")
            let myObj = PFQuery(className: "PostTextItems")
            myObj.whereKey("BelongsTo", equalTo: PFObject(outDataWithClassName: "Post", objectId: objectID))
            myObj.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                // Handle success or failure here ...
                if error == nil {
                    //print("Successfully found \(objects!.count) " )
                    if let _ = objects {
                        for object in objects! {
                           object.addObject(self.commentString, forKey: "Comments")
                           object.saveInBackground()
                        }
                    }
                    self.postCommentSucessful = true
                    self.commentString = ""
                } else {
                    //print("Upload Failed")
                }
                //self.queriesDelegate.donePostingComment()
            })
            commentTable.reloadData()
            connectPostToCommentGallery(objectID)
        }
    }
    
    func connectPostToCommentGallery(postID: String){
        //save post to correct User's comment gallery
        let commentedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
        commentedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
        commentedPostsObjectIDsQuery.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found object to connect to comment gallery \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        object.addObject(self.objectID, forKey: "PostsCommentedOn")
                        object.saveInBackgroundWithBlock{ //save the change
                            (succeeded, error) -> Void in
                            if(succeeded) {
                                self.center.postNotificationName("CommentedPostNotification", object: nil)
                            } else {
                                //don't post a notification
                            }
                        }
                    }
                }
            } else {
                //print("Upload Failed")
            }
        })
    }
    
    func checkIfPostSavedAlready(){
        //save post to correct User's comment gallery
        let savedPostsCheckObjectIDsQuery = PFQuery(className: "UserInformation")
        savedPostsCheckObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
        savedPostsCheckObjectIDsQuery.findObjectsInBackgroundWithBlock({
            (objects: [PFObject]?, error: NSError?) -> Void in
            // Handle success or failure here ...
            if error == nil {
                //print("Successfully found object to connect to saved gallery \(objects!.count) " )
                if let _ = objects {
                    for object in objects! {
                        for savedPost in object["SavedPosts"] as! [String] {
                            if(savedPost == self.objectID){
                                self.alreadySavedPost = true
                                self.starImageView.image = self.yellowStarImage
                                //self.saveImageButton.setImage(self.yellowStarImage, forState: .Normal)
                                //self.scrollView.reloadInputViews()
                            }
                        }
                    }
                }
            } else {
                //print("Upload Failed")
            }
        })
    }
    func postSave(){
        if(!alreadySavedPost && savePost){
            //save post to correct User's comment gallery
            let savedPostsObjectIDsQuery = PFQuery(className: "UserInformation")
            savedPostsObjectIDsQuery.whereKey("BelongsTo", equalTo: PFUser.currentUser()!)
            savedPostsObjectIDsQuery.findObjectsInBackgroundWithBlock({
                (objects: [PFObject]?, error: NSError?) -> Void in
                // Handle success or failure here ...
                if error == nil {
                    //print("Successfully found object to connect to saved gallery \(objects!.count) " )
                    if let _ = objects {
                        for object in objects! {
                            object.addObject(self.objectID, forKey: "SavedPosts")
                            object.saveInBackgroundWithBlock{ //save the change
                                (succeeded, error) -> Void in
                                if(succeeded) {
                                    self.center.postNotificationName("SavedPostNotification", object: nil)
                                } else {
                                    //don't post a notification
                                }
                            }
                        }
                    }
                    //change button image to the filled in one
                    self.starImageView.image = self.yellowStarImage
                    //self.saveImageButton.setImage(self.yellowStarImage, forState: .Normal)
                    self.alreadySavedPost = true
                    //self.queriesDelegate?.doneSavingImage()
                } else {
                    //print("Upload Failed")
                }
            })
        }
    }
    
    func saveImage(sender: AnyObject!){
        //print("tring to save image")
        if(starImageView.image != yellowStarImage){
            starImageView.image = yellowStarImage
            savePost = true
            
        } else {
            starImageView.image = grayStarImage
            savePost = false
        }
        
    }
    
    func uploadReportedImage(reason: String!) {
        let postObject = PFObject(className: "Moderator")
        postObject["username"] = PFUser.currentUser()?.username
        postObject["reason"] = reason
        postObject["reportedImage"] = self.objectID
        postObject.saveInBackgroundWithBlock({
            (succeeded: Bool, error: NSError?) -> Void in
            // Handle success or failure here ...
            if succeeded{
                print("image successfully flagged")
            }
        })
    }
 
    
    ///////////////////////////////////////
    /////     IBActions            ///////
    /////////////////////////////////////
    
    @IBAction func reportImage(sender:UIButton!) {
        
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let inapproriateAction = UIAlertAction(title: "Inappropriate", style: .Default, handler: {
            (alert: UIAlertAction!) in
            print("File Deleted")
            self.uploadReportedImage("inappropriate")
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })
        let notClothingAction = UIAlertAction(title: "Not clothing", style: .Default, handler: {(alert: UIAlertAction!) in
            self.uploadReportedImage("Not clothing")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let spamAction = UIAlertAction(title: "Spam", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadReportedImage("Spam")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
        //
        let otherAction = UIAlertAction(title: "Other", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.uploadReportedImage("Other")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("cancelled")
        })
        
        
        // 4
        optionMenu.addAction(inapproriateAction)
        optionMenu.addAction(notClothingAction)
        optionMenu.addAction(spamAction)
        optionMenu.addAction(otherAction)
        optionMenu.addAction(cancelAction)
        
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
        
    }


    ///////////////////////////////////////
    /////      Segue functions     ///////
    /////////////////////////////////////
    @IBAction func goBack(sender: AnyObject) {
        print("going back")
        postSave()
       self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loadZoomView(gestureRecognize: UITapGestureRecognizer){
        let zoomView = self.storyboard?.instantiateViewControllerWithIdentifier("ZoomView") as! ZoomViewController
        let imageTapped = gestureRecognize.view as! UIImageView
        zoomView.imageToEnlarge = imageTapped.image
        self.presentViewController(zoomView, animated: true, completion: nil)
    }
    
    @IBAction func exit(segue: UIStoryboardSegue){
        // //print("got rid of zoom view")
        postSave()
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("saving post if necessary")
        postSave()
    }
    
}