//
//  GalleryCell.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/12/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
  //let rootView = UIView(frame: UIScreen.mainScreen().bounds)
  
  let imageView = UIImageView()

  override init(frame: CGRect){
    super.init(frame: frame)
      self.addSubview(self.imageView)
      self.backgroundColor = UIColor.whiteColor()
      imageView.frame = self.bounds
      imageView.contentMode =  UIViewContentMode.ScaleAspectFill
      imageView.layer.masksToBounds = true
      imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    let views = ["cell":imageView]
    
      let cellConstraintY = NSLayoutConstraint.constraintsWithVisualFormat("V:|[cell]|", options: nil, metrics: nil, views: views)
      self.addConstraints(cellConstraintY)
      
      let cellConstraintX = NSLayoutConstraint.constraintsWithVisualFormat("H:|[cell]|", options: nil, metrics: nil, views: views)
      self.addConstraints(cellConstraintX)
  }
    
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
