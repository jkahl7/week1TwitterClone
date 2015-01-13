//
//  homeViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class homeViewController: UIViewController {
  
  let alertController = UIAlertController(title: "I Should Put", message: "Something Here", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  override func loadView() {
    //instantiates the rootView VC
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    let mainButton = UIButton()
    mainButton.backgroundColor = UIColor.blackColor()
    mainButton.setTitle("Images", forState: .Normal)
    mainButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    mainButton.addTarget(self, action: "mainButtonActivated:", forControlEvents: UIControlEvents.TouchUpInside)
    
    let titleBar = UILabel()
    titleBar.backgroundColor = UIColor.blackColor()
    titleBar.textColor = UIColor.whiteColor()
    titleBar.text = "Welcome to PicFilter!"
    titleBar.textAlignment = .Center
    
    let imageView = UIView()
    imageView.backgroundColor = UIColor.blueColor()
    
    let navBar = self.navigationController!.navigationBar
    rootView.addSubview(navBar)
    rootView.addSubview(mainButton)
    rootView.addSubview(titleBar)
    rootView.addSubview(imageView)
    
    mainButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    titleBar.setTranslatesAutoresizingMaskIntoConstraints(false)
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let views = ["mainButton" : mainButton,
                  "titleBar" : titleBar,
                  "imageView" : imageView,
                  "navBar" : navBar]
    
    /*****************************
    ** constraints for mainButton
    ******************************/

    let mainButtonPositionX = NSLayoutConstraint.constraintsWithVisualFormat("V:[mainButton]-30-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainButtonPositionX)
    
    let mainButtonCenter = NSLayoutConstraint(item: mainButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(mainButtonCenter)
    
    /*****************************
    ** constraints for titleBar
    ******************************/
    
    let titleBarConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[titleBar]-20-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(titleBarConstraintHorizontal)
    
    //TODO: !! weird bug where the imageView disappears when the title bar is constrained to the navBar.... had to switch title bar back to superview top constraint for now....
    
    let titleBarConstraintVerticle = NSLayoutConstraint.constraintsWithVisualFormat("V:|-20-[titleBar]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(titleBarConstraintVerticle)
  
    /*****************************
    ** constraints for imageView
    ******************************/
    //sets a horizontal constraint for the imageViews width
    let imageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-40-[imageView]-40-|",
      options: nil, metrics: nil, views: views)
    rootView.addConstraints(imageViewConstraintHorizontal)
    
    let imageViewCenteredXandY = NSLayoutConstraint.constraintsWithVisualFormat("V:[titleBar]-40-[imageView]-40-[mainButton]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
    rootView.addConstraints(imageViewCenteredXandY)
  
    self.view = rootView
  }
  
  func mainButtonActivated(sender: UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryAlert = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = galleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true)
      println("gallery alert selected....")
    }
    self.alertController.addAction(galleryAlert)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

