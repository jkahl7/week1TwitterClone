//
//  TweetClass.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/5/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import Foundation
import UIKit

class Tweet {
  //variables for the initial API call, and the thrid API call for TimeLineVC
  var tweetText:String
  var tweeter:String
  var user:[String:AnyObject]
  var tweeterLocation:String
  var tweetTimeLong:NSString // variable to store full value returned from ceated_at
  var tweetTime:NSString
  var ID:String
  var userID:String // stores the users ID and uses it to directly access a users detail info
  var profileImageLocation:String
  var image:UIImage?
  var statusesCount:Int
  var followersCount:Int
  var twitterHandle:String
  //detail info for the second API call, using user ID
  var favoriteCount:String?
  var backgroundImage:UIImage?
  var backgroundImageLocation:String
  
  var retweetStatus:String?
  
  init(tweetDictionary: [String:AnyObject]) {
    self.tweetText = tweetDictionary["text"] as String
    self.user = tweetDictionary["user"] as Dictionary
    self.ID = tweetDictionary["id_str"] as String
    self.twitterHandle = user["screen_name"] as String
    self.userID = user["id_str"] as String
    self.tweeter = user["name"] as String
    self.tweeterLocation = user["location"] as String
    self.tweetTimeLong = tweetDictionary["created_at"] as NSString
    self.tweetTime = self.tweetTimeLong.substringToIndex(20)
    self.backgroundImageLocation = user["profile_background_image_url_https"] as String
    self.profileImageLocation = user["profile_image_url"] as String
    self.statusesCount = user["statuses_count"] as Int
    self.followersCount = user["followers_count"] as Int
    self.retweetStatus = tweetDictionary["retweeted_status"] as? String
    
    if (retweetStatus != nil) {
      //tweet is a retweet
      let tempAttempt = tweetDictionary["retweeted_status"] as [String:AnyObject]
      let retweetDict = tempAttempt["user"] as [String:AnyObject]
      self.profileImageLocation = retweetDict["profile_image_url"] as String
      self.userID = retweetDict["id_str"] as String
    }
  }
  // function updates tweet details after second call
  func updateWithInfo(tweetDictionary: [String:AnyObject]) {
    let favoriteNumber = tweetDictionary["favorite_count"] as Int
    self.favoriteCount = "\(favoriteNumber)"
    
    if let backgroundImageData = NSData(contentsOfURL: NSURL(string: self.backgroundImageLocation)!) {
      self.backgroundImage = UIImage(data: backgroundImageData)
    }
  }
  //adds an image - called from the lazy loading function fetchImageForCell
  func updateImage(image:UIImage){
    self.image = image as UIImage
  }
}

