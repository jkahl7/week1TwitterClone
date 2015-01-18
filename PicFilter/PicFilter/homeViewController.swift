//
//  homeViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit
import Social

class homeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ImageSelectionProtocol, UIPopoverPresentationControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  let alertController = UIAlertController(title: NSLocalizedString("Select an option", comment: "Title for string"), message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  let rootView = UIView(frame: UIScreen.mainScreen().bounds)
  let mainButton = UIButton()
  let mainImage = UIImageView()
  let collectionViewFlowLayout = UICollectionViewFlowLayout()
  let imageQueue = NSOperationQueue()
  let defaultImage =  UIImage(named: "initimage.png")
  
  var thumbnailArray = [Thumbnail]()
  var filterArray = [String]()
  var metricsForVFL = [String:AnyObject]()
  
  var cancelButton:UIBarButtonItem!
  var shareButton:UIBarButtonItem!
  var doneButton:UIBarButtonItem!
  
  var unalteredImage:UIImage?//this variable will store the selected image and save its un edited form
 
  var gpuContext:CIContext!
  var originalThumbnail:UIImage!
  var collectionView:UICollectionView!
 
  var collectionViewYConstraint:NSLayoutConstraint!
  var mainImageResizeableConstraintFooter:NSLayoutConstraint!
  //var mainImageResizeableConstraintHorizontal:NSLayoutConstraint!  // for altering horizontal constraints

  
  override func loadView() {
    //basic attributes for views + subviews
    self.rootView.backgroundColor = UIColor.whiteColor()
    
    self.mainButton.backgroundColor = UIColor.blackColor()
    self.mainButton.setTitle(NSLocalizedString("Images", comment: "images button"), forState: .Normal)
    self.mainButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    self.mainButton.addTarget(self, action: "mainButtonActivated:", forControlEvents: UIControlEvents.TouchUpInside)
    
    self.mainImage.image = defaultImage
    self.mainImage.backgroundColor = UIColor.clearColor()
    self.mainImage.contentMode = UIViewContentMode.ScaleAspectFit
    self.mainImage.layer.masksToBounds = true
    
    self.collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 85)
    self.collectionViewFlowLayout.scrollDirection = .Horizontal
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
    
    //add subViews to the rootView
    self.rootView.addSubview(mainButton)
    self.rootView.addSubview(mainImage)
    self.rootView.addSubview(collectionView)
    
    self.mainButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.mainImage.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let views = ["mainButton" : mainButton, "mainImage" : mainImage, "collectionView" : collectionView]
    
    //dictionary that is used to set constraint spacing
    self.metricsForVFL = ["mainImageHeader": 60, "mainImageFooter": 70, "mainImageHorizontal": 5,
      "cvHeight":100 ,"cvBottom": -120,"mainButtonSize": 25]

    
    // disables color context for increased performance at the cost of reduced image quality
    let options = [kCIContextWorkingColorSpace:NSNull()]
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2) //boilerplate code from apple
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.thumbNailSetup()
    
    self.assignConstraintsForViews(rootView, metrics: self.metricsForVFL, views: views)
    
    self.view = rootView
  }
 
  /******************* MARK: viewDidLoad  *******************/
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // UIIMagePickerController
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      let cameraOption = UIAlertAction(title: NSLocalizedString("Camera", comment: "camera alert"), style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.navigationController?.presentViewController(imagePickerController, animated: true, completion: nil)
      })
    self.alertController.addAction(cameraOption)
    }
    
    //  UIAlertActoions
    let galleryAlert = UIAlertAction(title: NSLocalizedString("Gallery", comment: "gallery alert"), style: UIAlertActionStyle.Default) { (action) -> Void in
      let galleryVC = galleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
    self.alertController.addAction(galleryAlert)
    
    let photoAlert = UIAlertAction(title: NSLocalizedString("Photos", comment: "photos alert"), style: UIAlertActionStyle.Default) { (action) -> Void in
      let photoVC = photosViewController()
      photoVC.delegate = self
      photoVC.destinationImageSize = self.mainImage.frame.size
      self.navigationController?.pushViewController(photoVC, animated: true)
    }
    self.alertController.addAction(photoAlert)

    let filterAlert = UIAlertAction(title: NSLocalizedString("Filter", comment: "filter alert"), style: UIAlertActionStyle.Default) { (action) -> Void in
      // allow done button to apply selected filter and hide collectionView
      self.navigationItem.rightBarButtonItem = self.doneButton
      self.mainImageResizeableConstraintFooter.constant = self.metricsForVFL["mainImageFooter"] as CGFloat + 50
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()   // invalidates the mode of the current receiver and triggers a layout update w/ next cycle
      })
      self.collectionViewYConstraint.constant = self.metricsForVFL["cvBottom"] as CGFloat + 140
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    }
    self.alertController.addAction(filterAlert)
    
    // button creation
    self.cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancelFilterSelect")
    self.doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonSelected")
    self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "shareButtonSelected")
    self.navigationItem.rightBarButtonItem = self.shareButton
  
  }

   /******************* MARK: alert controller setup  *******************/
  
  
  func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
    popoverPresentationController.sourceView = self.mainButton
    popoverPresentationController.sourceRect = self.mainButton.bounds
  }
  
  /******************* MARK: button actions  *******************/
  func mainButtonActivated(sender: UIButton) {
    if let iPadPopController = self.alertController.popoverPresentationController {
      prepareForPopoverPresentation(iPadPopController)
      self.alertController.popoverPresentationController?.delegate = self
    }
    self.presentViewController(self.alertController, animated: true, completion: nil)
  }
  
  //TODO: add a cancel filter button???
  func cancelFilterSelect() {
    self.collectionViewYConstraint.constant = self.metricsForVFL["cvBottom"] as CGFloat
    if (self.unalteredImage != nil) {
      self.mainImage.image = self.unalteredImage
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
    self.view.layoutIfNeeded()
    })
  }
  //   doneButtonSelected
  func doneButtonSelected() {
    self.collectionViewYConstraint.constant = self.metricsForVFL["cvBottom"] as CGFloat
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    self.navigationItem.rightBarButtonItem = self.shareButton
    
    self.mainImageResizeableConstraintFooter.constant = self.metricsForVFL["mainImageFooter"] as CGFloat
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  //   shareButtonSelected
  func shareButtonSelected() {
    let error = NSLocalizedString("Error", comment: "Error message")
    let notSignedIn = NSLocalizedString("You are not signed into Twitter!", comment: "twitter warning")
    let okay = NSLocalizedString("Okay", comment: "okay message")
    let notSignedInAlert = UIAlertController(title: error, message: notSignedIn, preferredStyle: UIAlertControllerStyle.Alert)
    
    if(SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter)) {
      let composeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      composeVC.addImage(self.mainImage.image)
      self.presentViewController(composeVC, animated: true, completion: nil)
    } else {
      let twitterAlert = UIAlertAction(title: okay, style: UIAlertActionStyle.Destructive, handler: nil)
      notSignedInAlert.addAction(twitterAlert)
    }
  }
  
   /******************* MARK: imagePickerControll  *******************/
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject:AnyObject]) {
    let cameraImage = info[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(cameraImage!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
  
  func imagePickerDidCancel(picker:UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  }
   /******************* MARK: thumbNailSetup  *******************/
  func thumbNailSetup() {
    self.filterArray = ["CISepiaTone","CIPhotoEffectChrome", "CIColorPosterize","CIHatchedScreen", "CIDotScreen",
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
  
  //   controllerDidSelectImage
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

  
  //MARK: filterForMainImage()  function for generating a filtered main image
  func filterForMainImage(indexPath:NSIndexPath!) -> UIImage {
    // this is the entire filtering process, synchronous
    let baseImage = CIImage(image: self.unalteredImage)// recipe for an image
    let filter = CIFilter(name: self.filterArray[indexPath.row])// string for filter is entered
    filter.setDefaults() // defaults are set for saftey - if failure occurs here may be an issue with the applied filter
    filter.setValue(baseImage, forKey: kCIInputImageKey) // inserts original image an extract that image w/ filter applied
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage  //output and convert the image to a CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent) // remove this - for resizing
    let filteredMainImage = UIImage(CGImage: imageRef)// convert the CIImage to a UIImage, which can then be displayed
    
    return filteredMainImage!    // this is the entire filtering process, synchronous
  }
  
  /******************* MARK: collectionView setup  *******************/
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    self.mainImage.image = self.filterForMainImage(indexPath)
    
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
  
  /******************* MARK: constraints for subviews  *******************/
  func assignConstraintsForViews(rootView: UIView, metrics: [String:AnyObject], views: [String:AnyObject]) {
    
    //  mainButton
    let mainButtonPositionX = NSLayoutConstraint.constraintsWithVisualFormat("V:[mainButton(mainButtonSize)]-mainButtonSize-|", options: nil, metrics: metrics, views: views)
    rootView.addConstraints(mainButtonPositionX)
    
    let mainButtonCenter = NSLayoutConstraint(item: mainButton, attribute: .CenterX, relatedBy: .Equal, toItem: rootView, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(mainButtonCenter)
    
    // mainImage
    let mainImageConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-mainImageHorizontal-[mainImage]-mainImageHorizontal-|",
      options: nil, metrics: metrics, views: views)
    rootView.addConstraints(mainImageConstraintHorizontal)
    //self.mainImageResizeableConstraintHorizontal = mainImageConstraintHorizontal.first as NSLayoutConstraint

    let mainImageConstraintVerticle = NSLayoutConstraint.constraintsWithVisualFormat("V:|-mainImageHeader-[mainImage]", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: metrics, views: views)
    rootView.addConstraints(mainImageConstraintVerticle)
    self.mainImageResizeableConstraintFooter = mainImageConstraintVerticle.first as NSLayoutConstraint
    
    let mainIMageConstraintFooter = NSLayoutConstraint.constraintsWithVisualFormat("V:[mainImage]-mainImageFooter-|", options: nil, metrics: metrics, views: views)
    rootView.addConstraints(mainIMageConstraintFooter)
    self.mainImageResizeableConstraintFooter = mainIMageConstraintFooter.first as NSLayoutConstraint
    
    //  collectionView
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: metrics, views: views)
    rootView.addConstraints(collectionViewConstraintHorizontal)
    
    let collectionViewHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(cvHeight)]", options: nil, metrics: metrics, views: views)
    self.collectionView.addConstraints(collectionViewHeight )
    let collectionViewConstraintVerticle = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(cvBottom)-|", options: nil, metrics: metrics, views: views)
    rootView.addConstraints(collectionViewConstraintVerticle)
    self.collectionViewYConstraint = collectionViewConstraintVerticle.first as NSLayoutConstraint
    
  }
  
}

