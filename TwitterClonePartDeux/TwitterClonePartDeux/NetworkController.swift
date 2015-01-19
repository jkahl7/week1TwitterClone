//
//  NetworkController.swift
//  TwitterClonePartDeux
//
//  Created by Josh Kahl on 1/18/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetController {
  
  init(){
    
  }
  
  // store twitter account for future JSON use
  var twitterAccount:ACAccount?
 // let homeTimeLineLink = "https://api.twitter.com/1.1/statuses/home_timeline.json"
  let detailsLink = "https://api.twitter.com/1.1/statuses/show.json?id=" // !!! TODO: need to append userID!!!!!!!
  let profileTimeLineLink = "https://api.twitter.com/1.1/statuses/user_timeline.json?user_id=" // !!! TODO: need to append userID!!!!!!!
  
  //need account auth
  
  
  func fetchTwitterContent(jsonURL:String, userID:String?, completionHandler:(tweets:[Tweet]?, error:String) -> Void) {  //what input? likely need a completionHandler because it its going to be an asynchronous call / what will CH return?
    
    //need account auth
    let savedAccount = ACAccountStore()
    let accountType = savedAccount.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    savedAccount.requestAccessToAccountsWithType(accountType, options: nil/*find out what this is*/) { (granted, error) -> Void in
      if (granted) {
        // have access - proceed to use twitter information
        let accounts = savedAccount.accountsWithAccountType(accountType)
        if (!accounts.isEmpty) {
          self.twitterAccount = accounts[0] as? ACAccount
          // get JSON data
          let url = NSURL(string: jsonURL)
          let twitterFetch = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: url, parameters: nil)
          twitterFetch.account = self.twitterAccount
          twitterFetch.performRequestWithHandler({ (data, response, error) -> Void in
            if(error == nil) {
              //check for http status code errors
              switch response.statusCode {
              case 200...299:
                println("\(response.statusCode)")
                var error:NSError?
                if let jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error) as? [AnyObject] {
                  println("\(jsonDictionary)")
                  var tweets = [Tweet]()
                  for object in jsonDictionary {
                    if let objectDictionary = object as? NSDictionary {
                      let tweet = Tweet(jsonDictionary: objectDictionary)
                      tweets.append(tweet)
                    }
                    completionHandler(tweets: tweets, error: "no error here")
                  }
                }
              case 300...499:
                println("\(response.statusCode) = error on client side")
                completionHandler(tweets: nil, error: "this is not good")
              case 500...599:
                println("\(response.statusCode) = error on server side")
                completionHandler(tweets: nil, error: "this is not good")
              default:
                println("\(response.statusCode) = default case executed - check code")
                completionHandler(tweets: nil, error: "this is not good")
              }
            } else {
              // alert controller?
              println("error with twitterFetch request w/ handler")
            }
          })
        } else {
          // handle this error - add alert controller?
          println("error with getting twitter account information")
        }
        
        
      } else {
        //twitter access denied - add alert controller?
      }
    }
  }
}


