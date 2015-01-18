//
//  Tweets.swift
//  TwitterClonePartDeux
//
//  Created by Josh Kahl on 1/18/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class Tweet {
  
  var mainUserScreenName:String
  var mainUserID:String
  var mainUserTweetContent:String
  var mainUserLocation:String
  var tweetTimeStamp:NSString
  
  var mainUserProfileImageURL:String
  var mainUserProfileImage:UIImage? // aquire asynchronously
  
  var mainUserBackgroundImageURL:String
  var mainUserBackgroundImage:UIImage? // aquire asynchronously
  
 // var retweetCount: Int
  var favoriteCount: Int?
  
  init(jsonDictionary: NSDictionary) {
    //variables on the top layer of JSON file
    self.mainUserID = jsonDictionary["id_str"] as String
    self.mainUserTweetContent = jsonDictionary["text"] as String
    self.tweetTimeStamp = jsonDictionary["created_at"] as NSString // index in at 20 to remove extra chars on backend of string
    
    //indexing a layer deeper into JSON file
    let mainUserInfo = jsonDictionary["user"] as NSDictionary
    
    self.mainUserScreenName = mainUserInfo["screen_name"] as String
    self.mainUserProfileImageURL = mainUserInfo["profile_image_url"] as String
    self.mainUserBackgroundImageURL = mainUserInfo["profile_background_image_url_https"] as String
    self.mainUserLocation = mainUserInfo["location"] as String
    
  }
  //TODO: need method for fetching images asynchrounously
}