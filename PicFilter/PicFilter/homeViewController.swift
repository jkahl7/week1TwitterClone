//
//  homeViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit
import Social

class homeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ImageSelectionProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let alertController = UIAlertController(title: "I Should Put", message: "Something Here", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  let rootView = UIView(frame: UIScreen.mainScreen().bounds)
  let mainButton = UIButton()
  let mainImage = UIImageView()
  let collectionViewFlowLayout = UICollectionViewFlowLayout()
  let imageQueue = NSOperationQueue()
  
  var thumbnailArray = [Thumbnail]()
  var filterArray = [String]()
  
  var cancelButton:UIBarButtonItem!
  var shareButton:UIBarButtonItem!
  var doneButton:UIBarButtonItem!
  
  var originalImage:UIImage?
  var unalteredImage:UIImage? //this variable will store the selected image and save its un edited form
  var gpuContext:CIContext!
  var originalThumbnail:UIImage!
  var collectionView:UICollectionView!
  var collectionViewYConstraint:NSLayoutConstraint!
  override func loadView() {
    //basic attributes for views + subviews
    rootView.backgroundColor = UIColor.whiteColor()
    
    mainButton.backgroundColor = UIColor.blackColor()
    mainButton.setTitle("Images", forState: .Normal)
    mainButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    mainButton.addTarget(self, action: "mainButtonActivated:", forControlEvents: UIControlEvents.TouchUpInside)
    
    mainImage.backgroundColor = UIColor.clearColor()
    mainImage.contentMode = UIViewContentMode.ScaleToFill
    mainImage.layer.masksToBounds = true
    
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 85)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
    
    //add subViews to the root
    rootView.addSubview(mainButton)
    rootView.addSubview(mainImage)
    rootView.addSubview(collectionView)
    
    mainButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    mainImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
  
    
    let views = ["mainButton" : mainButton,
                  "mainImage" : mainImage,
             "collectionView" : collectionView]
    
    // disables color context for increased performance at the cost of reduced image quality
    let options = [kCIContextWorkingColorSpace:NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2) //boilerplate code from apple
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.thumbNailSetup()
    
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
 
  //MARK: viewDidLoad()
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryAlert = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = galleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    self.alertController.addAction(galleryAlert)
    
    let photoAlert = UIAlertAction(title: "Photos", style: UIAlertActionStyle.Default) { (action) -> Void in
      let photoVC = photosViewController()
      photoVC.delegate = self
      self.navigationController?.pushViewController(photoVC, animated: true)
    }
    self.alertController.addAction(photoAlert)
    
    let filterAlert = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      // allow done button to apply selected filter and hide collectionView
      self.navigationItem.rightBarButtonItem = self.doneButton
      self.collectionViewYConstraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()   // invalidates the mode of the current receiver and triggers a layout update w/ next cycle
      })
    }
    self.alertController.addAction(filterAlert)
    
    self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelFilterSelect")
    self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonSelected")
    self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonSelected")
    self.navigationItem.rightBarButtonItem = self.shareButton
  
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
      let cameraOption = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
      })
      self.alertController.addAction(cameraOption)
    }
  }

  //MARK: button actions
  func mainButtonActivated(sender: UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  func cancelFilterSelect() {
    self.collectionViewYConstraint.constant = -120
    if (self.originalImage != nil) {
      self.mainImage.image = self.originalImage
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
    self.view.layoutIfNeeded()
    })
  }

  func doneButtonSelected() {
    self.collectionViewYConstraint.constant = -120
    UIView.animateWithDuration(0.4, animations: { () -> Void in
    self.view.layoutIfNeeded()
      
    })
  }
  
  func shareButtonSelected() {
    let notSignedInAlert = UIAlertController(title: "Error", message: "You are not signed into Twitter!", preferredStyle: UIAlertControllerStyle.Alert)
    if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
      let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      composeVC.addImage(self.mainImage.image)
      self.presentViewController(composeVC, animated: true, completion: nil)
    } else {
      println("user not logged into twitter")
      let notSignedInAlert = UIAlertController(title: "Error", message: "You are not signed into Twitter!", preferredStyle: UIAlertControllerStyle.Alert)
      let twitterAlert = UIAlertAction(title: "Okay", style: UIAlertActionStyle.Destructive, handler: nil)
      notSignedInAlert.addAction(twitterAlert)
    }
  }
  
  // Tells the delegate that the user picked an image
  func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    let image = editingInfo[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(image!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerDidCancel(picker:UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func thumbNailSetup() {
    self.filterArray = ["CISepiaTone","CIPhotoEffectChrome", "CIColorPosterize",
     "CIPhotoEffectNoir","CIPhotoEffectMono", "CIPhotoEffectFade","CIPhotoEffectTransfer"]
    // loop through filterArray and initilize a Thumbnail object for each name
    for name in self.filterArray {
      let thumbnail = Thumbnail(filterName: name, imageQueue: self.imageQueue, gpuContext: self.gpuContext)
      thumbnailArray.append(thumbnail)
    }
  }
  
  func thumbNailGenerator(originalImage: UIImage) {
    var size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)      //begin drawing
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100)) //draw image in the CGRect - draws to context
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()  //pull thumbnail out
    UIGraphicsEndImageContext() // frees up the image context - if not implemented will cause a memory leak
  }
  
  func controllerDidSelectImage(image: UIImage) -> Void {
    self.mainImage.image = image
    self.unalteredImage = image
    self.thumbNailGenerator(image) // generate thumbnails here
    // reload collectionView Data here
    for thumbnail in self.thumbnailArray {
      thumbnail.originalImage = self.originalThumbnail
      thumbnail.filteredImage = nil // clears out filter
    }
    self.collectionView.reloadData()
  }
  
  //MARK: filterForMainImage()  function for generating a filtered main image    TODO: this doesn't work :|
  func filterForMainImage(indexPath:NSIndexPath!) -> UIImage {
    // this is the entire filtering process, synchronous
    let baseImage = CIImage(image: self.unalteredImage)// recipe for an image
    let filter = CIFilter(name: self.filterArray[indexPath.row])// string for filter is entered
    filter.setDefaults() // defaults are set for saftey - if failure occurs here may be an issue with the applied filter
    filter.setValue(baseImage, forKey: kCIInputImageKey) // inserts original image an extract that image w/ filter applied
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage  //output and convert the image to a CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent) // remove this - for resizing
    let filteredMainImage = UIImage(CIImage: result) // convert the CIImage to a UIImage, which can then be displayed
    return filteredMainImage!    // this is the entire filtering process, synchronous
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.mainImage.image = self.filterForMainImage(indexPath)
    self.mainImage.reloadInputViews()
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.filterArray.count
  }
  
  // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERYCELL", forIndexPath: indexPath) as GalleryCell
    let thumbnail = self.thumbnailArray[indexPath.row]
    if thumbnail.originalImage != nil && thumbnail.filteredImage == nil { //only runs if thumbnail is chosen - else wll crash
      thumbnail.generateFilteredImage()
      cell.imageView.image = thumbnail.filteredImage!
    }
    return cell
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  //TODO: set up a function that handles all of the constraints on the rootView
}
