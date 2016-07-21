//
//  MyTabBarController.swift
//  Fits
//
//  Created by Darren Moyer on 2/11/16.
//  Copyright © 2016 Urban Fish Studio. All rights reserved.
//

import UIKit


let ACCENTCOLOR = UIColor(red: 0.349, green: 0.749, blue: 0.6, alpha: 1.0)
let BACKGROUNDCOLOR1 = UIColor(red: 0.082, green: 0.071, blue: 0.067, alpha: 1.0)
let BACKGROUNDCOLOR2 = UIColor(red: 0.192, green: 0.204, blue: 0.208, alpha: 1.0)
let TEXTCOLOR1 = UIColor(red: 0.494, green: 0.518, blue: 0.514, alpha: 1.0)
let SELECTEDBACKGROUNDCOLOR = UIColor(red: 0.278, green: 0.278, blue: 0.278, alpha: 1.0)


class MyTabBarController: UITabBarController {

    @IBOutlet weak var myTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Change Background of the selected item
        UITabBar.appearance().selectionIndicatorImage = UIImage().makeImageWithColorAndSize(SELECTEDBACKGROUNDCOLOR, accentColor: ACCENTCOLOR, size: CGSizeMake(tabBar.frame.width/5, tabBar.frame.height))
        
        //Setup Render for Tab Bar Images
        for item in self.tabBar.items! as [UITabBarItem] {
            //Normal Image render with original colors
            if let image = item.image {
                item.image = image.imageWithRenderingMode(.AlwaysOriginal)
            }
            //Selcted Image render with original colors
            if let image = item.selectedImage {
                item.selectedImage = image.imageWithRenderingMode(.AlwaysOriginal)
            }
            //Image location
            item.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        }
        
        // Change Camera Tab Bar Item Background Color
        let itemIndex: CGFloat = 2
        let itemWidth = tabBar.frame.width / CGFloat(tabBar.items!.count)
        let bgView = UIView(frame: CGRectMake(itemWidth * itemIndex, 0, itemWidth, tabBar.frame.height))
        bgView.backgroundColor = UIColor(red: 0.494, green: 0.518, blue: 0.514, alpha: 1.0)
        tabBar.insertSubview(bgView, atIndex: 0)
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        //This method will be called when user changes tab.
        if (item == tabBar.items![2]) {
            tabBar.hidden = true
        }
    }
    
    
    @IBAction func returnToTabBarController(segue: UIStoryboardSegue){
        self.tabBar.hidden = false
        self.selectedIndex = 0
    }

}

extension UIImage {
    func makeImageWithColorAndSize(backColor: UIColor, accentColor: UIColor, size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        backColor.setFill()
        UIRectFill(CGRectMake(0, 0, size.width, size.height))
        accentColor.setFill()
        UIRectFill(CGRectMake(2, size.height-3, size.width-4, 3))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}