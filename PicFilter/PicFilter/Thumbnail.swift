//
//  Thumbnail.swift
//  PicFilter
//
//  Created by Josh Kahl on 1/13/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class Thumbnail {
  var originalImage:UIImage?
  var filteredImage:UIImage?
  var filterName:String
  var imageQueue:NSOperationQueue
  var gpuContext:CIContext
  
  init (filterName: String, imageQueue: NSOperationQueue, gpuContext:CIContext) {
    self.filterName = filterName
    self.imageQueue = imageQueue
    self.gpuContext = gpuContext
  }
  
  func generateFilteredImage() {
    // this is the entire filtering process, synchronous
    let startImage = CIImage(image: self.originalImage) // recipe for an image
    let filter = CIFilter(name: self.filterName) // string for filter is entered
    filter.setDefaults() // for saftey - set the defaults on this filter - if failure occurs here may be an issue with the filter selected
    filter.setValue(startImage, forKey: kCIInputImageKey) // insert original image and extract that image w/ filter applied
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage // still cant display the image as it is a CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent) // used to resize the image
    self.filteredImage = UIImage(CGImage: imageRef) // convert CIImage to a UIImage, which can then be displayed
  }
}
