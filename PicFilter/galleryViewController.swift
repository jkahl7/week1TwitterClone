//
//  galleryViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit


protocol ImageSelectionProtocol {
  /**************************************************************************************************
  ** this function will be defined in any class that adopts its protocol. this allows any object that sets
  ** a variable = to ImageSelectionProtocol to have access to the functions defined within other objects. so I can call this method in 
  ** galleryViewController passing in an image type and then utilize whatever image was passed in in the conforming class. This allows for 
  ** a more indirect association between these two objects thus avoiding any dependency which could potentially cause memory leaks/cycles
  ***************************************************************************************************/
  func controllerDidSelectImage(UIImage) -> Void
}

class galleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

  let imageCount:Int = 14 //TODO: dont forget to change this when an actually array is passed
  var collectionView : UICollectionView!
  var galleryImages = [UIImage]()
  var delegate:ImageSelectionProtocol?
  let collectionViewFlowLayout = UICollectionViewFlowLayout()
  var rootView:UIView!
  
  override func loadView() {
    self.rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.collectionViewFlowLayout.itemSize = CGSize(width: 225, height: 175)
    self.collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    self.collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: self.collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.backgroundColor = UIColor.whiteColor()
    
    self.rootView.addSubview(self.collectionView)
   
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    
    let pinchedGestureForCV = UIPinchGestureRecognizer(target: self, action: "collectionViewPinchedGesture:")
    self.collectionView.addGestureRecognizer(pinchedGestureForCV)

    self.view = rootView
  }

  override func viewDidLoad() {
      super.viewDidLoad()
    self.view.backgroundColor = UIColor.blackColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
    
    //populate the galleryImages
    for (var i = 0; i < imageCount; i++) {
      let image = UIImage(named: "image\(i).jpeg")
      
      galleryImages.append(image!)
    }
  }
  
  func collectionViewPinchedGesture(sender: UIPinchGestureRecognizer) {
    switch sender.state {
    case .Began:
      println("touch started")
    case .Changed:
      println("\(sender.velocity)")
    case .Ended:
      self.collectionView.performBatchUpdates({ () -> Void in
        if (sender.velocity > 0) {
          self.collectionViewFlowLayout.itemSize = CGSize(width: (self.collectionViewFlowLayout.itemSize.width) * 2 , height: (self.collectionViewFlowLayout.itemSize.height) * 2)
        } else if (sender.velocity < 0) {
          self.collectionViewFlowLayout.itemSize = CGSize(width: (self.collectionViewFlowLayout.itemSize.width) * 0.5, height: (self.collectionViewFlowLayout.itemSize.height) * 0.5)
        }
      }, completion: { (completed) -> Void in
        
      })
    default:
      println("this is default")
    }
  }
  
  
  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.galleryImages.count
      
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERYCELL", forIndexPath: indexPath) as GalleryCell

      cell.imageView.image = self.galleryImages[indexPath.row]
      
      return cell
    }
  
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
      //call the function located within the protocol - this function is defined and returns in whatever class adopts its protocol
      self.delegate?.controllerDidSelectImage(self.galleryImages[indexPath.row])
    
      self.navigationController?.popViewControllerAnimated(true)
    }

}
