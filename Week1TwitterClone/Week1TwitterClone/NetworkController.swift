//
//  NetworkController.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/6/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
  init() {
  }
  var userTwitterAccount = ACAccount?()
  var imageQueueforImage = NSOperationQueue() //initiates 
  //fetchHomeTimeline func with closure
  func fetchHomeTimeline( completionHandler: (tweet:[Tweet]?, errorReport:String?) -> Void) {
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, error:NSError?) -> Void in
      if(!granted) {
        println("Access Denied! User did not allow access to account information")
        //alertAction here that lets the user know they won't be seing any tweets!
      } else {
        let accounts = accountStore.accountsWithAccountType(accountType)
        if(accounts.isEmpty) {
          println("no user account found - please add account information in settings")
          //account not found
        } else { // accounts in accounts array
          self.userTwitterAccount = accounts[0] as? ACAccount
          let fetchTwitterHomeTimeLineAPI = NSURL(string: "https://api.twitter.com/1.1/statuses/home_timeline.json")
          let requestTwitterAPIData = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: fetchTwitterHomeTimeLineAPI, parameters: nil)
          requestTwitterAPIData.account = self.userTwitterAccount
          requestTwitterAPIData.performRequestWithHandler({ (data, response, error) -> Void in
            if(error == nil){
              switch response.statusCode {
              case 200...299:
                println("FetchTwitterHome=\(response.statusCode)")
                var error:NSError?
                if let convertedAPIData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [AnyObject] {
                 // println("\(convertedAPIData)")
                  var tweets = [Tweet]()
                  for object in convertedAPIData {
                    if let objectDictionary = object as? [String:AnyObject] {
                      let tweet = Tweet(tweetDictionary: objectDictionary)
                      tweets.append(tweet)
                    } else {
                      println("no usable objects found in converted API data")
                    }
                  }
                  var errorString:String?
                  NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(tweet: tweets, errorReport: errorString)
                  })
                }
              case 300...599:
                println("\(response.statusCode)")
              default:
                println("\(response.statusCode)")
              }
            }
          })
        }
      }
    }
  }
  /*****************************************************************************
  ** function to make a second call to the twitter API, this time using the
  ** users account information saved from the first call. returns a dictionary
  ******************************************************************************
  */
  func fetchDetailForCell(tweetID:String, completionHandler: (details:[String:AnyObject]?, errorReport:String?) -> Void)
  {
    let detailAPILocation = NSURL(string: "https://api.twitter.com/1.1/statuses/show.json?id=\(tweetID)")
    let requestTwitterAPIData = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: detailAPILocation, parameters: nil)
    requestTwitterAPIData.account = self.userTwitterAccount
    requestTwitterAPIData.performRequestWithHandler { (data, response, error) -> Void in
      if(error == nil) {
        switch response.statusCode {
        case 200...299:
          println("FetchDetailForCell\(response.statusCode)")
          var error:NSError?
          if let convertedJSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [String:AnyObject] {
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
              completionHandler(details: convertedJSONData, errorReport: nil)
            })
          }
        case 300...599:
          println("\(response.statusCode)")
          completionHandler(details: nil, errorReport: "user error")
        default:
          println("default case triggered")
          completionHandler(details: nil, errorReport: "user error")
        }
      }
    }
  }
  /*****************************************************************************
  ** function that 
  ******************************************************************************
  */
  func fetchTimeLineDetails(userID:String, completionHandler: (details:[Tweet]?, errorReport:String?) -> Void) {
    let twitterTimeLineAPIUrl = NSURL(string: "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id="+userID)
    let twitterTimeLineAPIRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: twitterTimeLineAPIUrl, parameters: nil)
    twitterTimeLineAPIRequest.account = self.userTwitterAccount
    twitterTimeLineAPIRequest.performRequestWithHandler { (data, response, error) -> Void in
      if (error == nil) {
        switch response.statusCode {
        case 200...299:
          //println("FetchTimeLine:\(response.statusCode)")
          var error:NSError?
          if let timelineAPIData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [AnyObject] {
            if (error == nil) {
              //println(timelineAPIData)
              for object in timelineAPIData {
                var tweets = [Tweet]()
                if let jsonDictionary = object as? [String:AnyObject] {
                  let tweet = Tweet(tweetDictionary: jsonDictionary)
                  tweets.append(tweet)
                  NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    completionHandler(details: tweets, errorReport : nil)
                  })
                }
              }
            }
          } else {
            println("check the timelineAPIData input")
            completionHandler(details: nil, errorReport: "Error")
          }
        case 300...599:
          println("\(response.statusCode)")
            completionHandler(details: nil, errorReport: "Error")
        default:
          println("It's broke!")
          completionHandler(details: nil, errorReport: "Error")
        }
      }
    }
  }
  
  /*****************************************************************************
  ** function that achieves lazy loading for profile images, requires a valid
  ** link.
  ******************************************************************************
  */
  
  func fetchImageForCell(tweet: Tweet, storedIndexPath: NSIndexPath, completionHandler: (image: UIImage?, storedIndexPath:NSIndexPath, errorReport: String?) -> Void) {
    let url = NSURL(string: tweet.profileImageLocation)
    self.imageQueueforImage.addOperationWithBlock { () -> Void in
      if let imageData = NSData(contentsOfURL: url!) {
        let image = UIImage(data: imageData)
        tweet.updateImage(image!)
        NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
          completionHandler(image: image, storedIndexPath: storedIndexPath, errorReport: nil)
        })
      } else {
        completionHandler(image: nil, storedIndexPath: storedIndexPath, errorReport: "image not recieved")
        println("image not recieved")
      }
    }
  }
}