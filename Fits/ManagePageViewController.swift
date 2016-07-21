////
////  ManagePageViewController.swift
////  Fits
////
////  Created by Sophia Gebert on 4/2/16.
////  Copyright © 2016 Urban Fish Studio. All rights reserved.
////
//
//import UIKit
//
//class ManagePageViewController: UIPageViewController {
//    var photos = ["photo1", "photo2", "photo3", "photo4", "photo5"]
//    var currentIndex: Int!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        dataSource = self
//        
//        // 1
//        if let viewController = viewPhotoCommentController(currentIndex ?? 0) {
//            let viewControllers = [viewController]
//            // 2
//            setViewControllers(
//                viewControllers,
//                direction: .Forward,
//                animated: false,
//                completion: nil
//            )
//        }
//    }
//    
//    func viewPhotoCommentController(index: Int) -> PhotoCommentViewController? {
//        if let storyboard = storyboard,
//            page = storyboard.instantiateViewControllerWithIdentifier("PhotoCommentViewController")
//                as? PhotoCommentViewController {
//            page.photoName = photos[index]
//            page.photoIndex = index
//            return page
//        }
//        return nil
//    }
//}
////MARK: implementation of UIPageViewControllerDataSource
//extension ManagePageViewController: UIPageViewControllerDataSource {
//    // 1
//    func pageViewController(pageViewController: UIPageViewController,
//                            viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
//        
//        if let viewController = viewController as? PhotoCommentViewController {
//            var index = viewController.photoIndex
//            guard index != NSNotFound && index != 0 else { return nil }
//            index = index - 1
//            return viewPhotoCommentController(index)
//        }
//        return nil
//    }
//    
//    // 2
//    func pageViewController(pageViewController: UIPageViewController,
//                            viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
//        
//        if let viewController = viewController as? PhotoCommentViewController {
//            var index = viewController.photoIndex
//            guard index != NSNotFound else { return nil }
//            index = index + 1
//            guard index != photos.count else {return nil}
//            return viewPhotoCommentController(index)
//        }
//        return nil
//    }
//}