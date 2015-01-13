//
//  galleryViewController.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class galleryViewController: UIViewController, UICollectionViewDataSource {

  let imageCount:Int = 10
  var collectionView : UICollectionView!
  var galleryImages = [UIImage]()
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    collectionViewFlowLayout.itemSize = CGSize(width: 150, height: 150)
    
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
      
      for(var i = 0; i < imageCount; i++){
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
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
      return 2
    }
}
