//
//  homeViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class homeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ImageSelectionProtocol {
  
  let alertController = UIAlertController(title: "I Should Put", message: "Something Here", preferredStyle: UIAlertControllerStyle.ActionSheet)
  let rootView = UIView(frame: UIScreen.mainScreen().bounds)
  let mainButton = UIButton()
  let mainImage = UIImageView()
  let collectionViewFlowLayout = UICollectionViewFlowLayout()
  let imageQueue = NSOperationQueue()
  
  var thumbnailArray = [Thumbnail]()
  var filterArray = [String]()
  
  var filteredMainImage:UIImage? //this variable will store the selected image / for use with filter setting
  var gpuContext:CIContext!
  var originalThumbnail:UIImage!
  var collectionViewYConstraint:NSLayoutConstraint!
  var collectionView:UICollectionView!
  
  override func loadView() {
    //basic attributes for views + subviews
    rootView.backgroundColor = UIColor.whiteColor()
    
    mainButton.backgroundColor = UIColor.blackColor()
    mainButton.setTitle("Images", forState: .Normal)
    mainButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    mainButton.addTarget(self, action: "mainButtonActivated:", forControlEvents: UIControlEvents.TouchUpInside)
    
    mainImage.backgroundColor = UIColor.clearColor()
    mainImage.contentMode = UIViewContentMode.ScaleAspectFit
    mainImage.layer.masksToBounds = true
    
  
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 85)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    self.collectionView.dataSource = self
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
    
    let navBar = self.navigationController!.navigationBar
    
    // add subViews to the root
    rootView.addSubview(mainButton)
    rootView.addSubview(mainImage)
    rootView.addSubview(navBar)
    rootView.addSubview(collectionView)
    
    mainButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    mainImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
  
    
    let views = ["mainButton" : mainButton,
                  "mainImage" : mainImage,
                     "navBar" : navBar,
             "collectionView" : collectionView]
    
    // disables color context for increased performance at the cost of reduced image quality
    let options = [kCIContextWorkingColorSpace:NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2) //boilerplate code from apple
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.thumbNailSetup()
    //TODO: generate thumbnails here
    
    /*****************************
    ** constraints for mainButton
    ******************************/

    let mainButtonPositionX = NSLayoutConstraint.constraintsWithVisualFormat("V:[mainButton]-30-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainButtonPositionX)
    
    let mainButtonCenter = NSLayoutConstraint(item: mainButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(mainButtonCenter)
    
    /*****************************
    ** constraints for imageView
    ******************************/
    
    //sets a horizontal constraint for the imageViews width
    let mainImageConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-10-[mainImage]-10-|",
      options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageConstraintHorizontal)
    
    let mainImageCenteredXandY = NSLayoutConstraint.constraintsWithVisualFormat("V:|-50-[mainImage]-20-[mainButton]", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: views)
    rootView.addConstraints(mainImageCenteredXandY)
    
    /**********************************
    ** constraints for collectionView
    **********************************/
    
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintHorizontal)
    
    let collectionViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewHeight )
    let collectionViewConstraintVerticle = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintVerticle)
    self.collectionViewYConstraint = collectionViewConstraintVerticle.first as NSLayoutConstraint
    
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryAlert = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = galleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    self.alertController.addAction(galleryAlert)
    
    
    let filterAlert = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      // allow done button to apply selected filter and hide collectionView
      self.collectionViewYConstraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()   // invalidates the mode of the current receiver and triggers a layout update w/ next cycle
      })
    }
    self.alertController.addAction(filterAlert)
  }

  func mainButtonActivated(sender: UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func thumbNailSetup() {
    self.filterArray = ["CISepiaTone","CIPhotoEffectChrome", "CIColorPosterize",
      "CIPhotoEffectNoir","CIPhotoEffectMono", "CIPhotoEffectFade","CIPhotoEffectTransfer"]
    // loop through filterArray and initilize a Thumbnail object
    for name in self.filterArray {
      let thumbnail = Thumbnail(filterName: name, imageQueue: self.imageQueue, gpuContext: self.gpuContext)
      thumbnailArray.append(thumbnail)
    }
  }
  
  func thumbNailGenerator(originalImage: UIImage) {
    var size = CGSize(width: 100, height: 100)
    //begin drawing
    UIGraphicsBeginImageContext(size)
    //draw image in the CGRect - draws to context
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    //pull thumbnail out
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
  }
  
  
  func controllerDidSelectImage(image: UIImage) -> Void {
    println("image selected")
    self.mainImage.image = image
    // generate thumbnails here
    self.thumbNailGenerator(image)
    // reload collectionView Data here
    for thumbnail in self.thumbnailArray {
      thumbnail.originalImage = self.originalThumbnail
    }
    self.collectionView.reloadData()
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filterArray.count
  }
  
  /*function for generating a filtered main image    TODO: this doesn't work :|
  func filterForMainImage(indexPath:NSIndexPath!) {
    let baseImage = self.mainImage.image
    let filter = CIFilter(name: self.filterArray[indexPath.row])
    filter.setDefaults()
    filter.setValue(baseImage, forKey: kCIInputImageKey)
    let result = filter.valueForKey(kCIInputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    self.filteredMainImage = UIImage(CGImage: imageRef)
  } */
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    //filterForMainImage(indexPath)
    //self.mainImage.reloadInputViews()
    println("\(indexPath.row) selected")
    // when row selected > get index path of row > find out what filter is at that indexpath
    //call filterForMainImage using that filter
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERYCELL", forIndexPath: indexPath) as GalleryCell
    let thumbnail = self.thumbnailArray[indexPath.row]
    if thumbnail.originalImage != nil && thumbnail.filteredImage == nil {
      thumbnail.generateFilteredImage()
      cell.imageView.image = thumbnail.filteredImage!
    }
    return cell
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

