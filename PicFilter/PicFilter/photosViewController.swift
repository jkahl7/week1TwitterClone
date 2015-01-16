//
//  photosViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/14/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit
import Photos

class photosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

  var fetchAssetsResult:PHFetchResult! //A PHFetchResult object is a container for an ordered list of photo entity objects
  var assetCollection:PHAssetCollection! //object represents a collection of photo; video; moments; albums; Shared Photo Streams.
 
  var collectionView:UICollectionView!
  var destinationImageSize:CGSize!
  
  let imageSize = CGSize(width: 100, height: 100)
  
  var delegate:ImageSelectionProtocol?
  
  var imageManager = PHCachingImageManager()//This shared object provides methods for loading image or video data associated with a PHAsset object
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.itemSize = CGSize(width: 225, height: 175)
    collectionViewFlowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    
    self.collectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: collectionViewFlowLayout)
    self.collectionView.backgroundColor = UIColor.whiteColor()

    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    rootView.addSubview(collectionView)
    
    self.view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERYCELL")
    
    self.imageManager = PHCachingImageManager() // fetches or generates image data for photo or video assets. Asynchonous 
    
    self.fetchAssetsResult = PHAsset.fetchAssetsWithOptions(nil) //Retrieves all assets matching the specified options
  }

  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.fetchAssetsResult.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERYCELL", forIndexPath: indexPath) as GalleryCell
    
    let asset = self.fetchAssetsResult[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: self.imageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      cell.imageView.image = requestedImage
    }
    return cell
  }
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let assetSelected = self.fetchAssetsResult[indexPath.row] as PHAsset
    
    self.imageManager.requestImageForAsset(assetSelected, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      
      self.delegate?.controllerDidSelectImage(requestedImage)
      self.navigationController?.popToRootViewControllerAnimated(true)
    }
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
}

