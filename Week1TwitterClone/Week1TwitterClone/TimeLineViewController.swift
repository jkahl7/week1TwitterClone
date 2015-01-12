//
//  TimeLineViewController.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/8/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class TimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var userID:String!
  var tweets = [Tweet]()
  var selectedTweet:Tweet!
  var networkController:NetworkController!
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var followersCount: UILabel!
  @IBOutlet weak var statusCount: UILabel!
  @IBOutlet weak var locationLabel: UILabel!
  @IBOutlet weak var twitterHandle: UILabel!
 
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var backgroundImage: UIImageView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //sets properties for the tableview - reuses the TweetCell nib
    self.tableView.estimatedRowHeight = 144
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.dataSource = self
    self.tableView.delegate = self
    
    self.followersCount.text = "Followers:\(self.selectedTweet.followersCount)"
    self.statusCount.text = "Tweets:\(self.selectedTweet.statusesCount)"
    self.locationLabel.text = self.selectedTweet.tweeterLocation
    self.backgroundImage.image = self.selectedTweet.backgroundImage
    self.userImage.image = self.selectedTweet.image
    self.twitterHandle.text = "@" + self.selectedTweet.twitterHandle
    
    self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CELL")
    
    self.networkController.fetchTimeLineDetails(self.userID, completionHandler: { (details, errorReport) -> Void in
      if (errorReport == nil) {
        for item in details! {
          self.tweets.append(item)
        }
        self.tableView.reloadData()
      }
    })
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tweets.count//TODO: change this?
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as TweetCell
    
    cell.tweetTime.text = tweets[indexPath.row].tweetTime
    cell.tweetContent.text = tweets[indexPath.row].tweetText
    cell.userName.text = tweets[indexPath.row].tweeter
    cell.userImageButton.setImage(tweets[indexPath.row].image, forState: .Normal)
        
    //lazy loading / add initial if condition that checks if rt or reply
    /*
    if(self.tweets[indexPath.row].retweetReply != nil) {
      
    }*/
    if(self.tweets[indexPath.row].image == nil) {
      self.networkController.fetchImageForCell(self.tweets[indexPath.row], storedIndexPath: indexPath, completionHandler: { (image, storedIndexPath, errorReport) -> Void in
        if(errorReport == nil) {
          self.tableView.reloadRowsAtIndexPaths([storedIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
          cell.userImageButton.setImage(nil, forState: .Normal)
          println("image not found")
        }
      })
    }
    return cell
  }
}
