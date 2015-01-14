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

class galleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  let imageCount:Int = 10 //TODO: dont forget to change this when an actually array is passed
  var collectionView : UICollectionView!
  var galleryImages = [UIImage]()
  var delegate:ImageSelectionProtocol?
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.itemSize = CGSize(width: 225, height: 185)
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 1, bottom: 5, right: 1)
      
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.backgroundColor = UIColor.whiteColor()
    self.collectionView.dataSource = self
    self.collectionView.delegate = self

    let navBar = self.navigationController!.navigationBar
    rootView.addSubview(navBar)
    
    let view = ["navBar" : navBar, "collectionViewFlowLayout" : collectionViewFlowLayout]
    
    let collectionViewConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[navBar]-10-[collectionViewFlowLayout]", options: nil, metrics: nil, views: view)
    
    self.view = rootView
  }

  override func viewDidLoad() {
      super.viewDidLoad()
    self.view.backgroundColor = UIColor.blackColor()
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
      
    for (var i = 0; i < imageCount; i++) {
      let image = UIImage(named: "image\(i).jpeg")
      galleryImages.append(image!)
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return galleryImages.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERYCELL", forIndexPath: indexPath) as GalleryCell
      
     let image = self.galleryImages[indexPath.row]
      
     cell.imageView.image = image
      
      return cell
    }
  
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
      //call the function located within the protocol - this function is defined and returns in whatever class adopts its protocol
      self.delegate?.controllerDidSelectImage(self.galleryImages[indexPath.row])
    
      self.navigationController?.popViewControllerAnimated(true)
      println("selected image at\(indexPath.row)")
    }
}
