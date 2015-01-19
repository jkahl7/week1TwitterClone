//
//  mainViewController.swift
//  TwitterClonePartDeux
//
//  Created by Josh Kahl on 1/18/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class mainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  let homeTimeLineLink = "https://api.twitter.com/1.1/statuses/home_timeline.json"
  
  var tweets = [Tweet]()
  
  var netController = NetController()
  

  @IBOutlet weak var tableView: UITableView!
  

    override func viewDidLoad() {
        super.viewDidLoad()
      println("congrats on not crashing")
      self.tableView.estimatedRowHeight = 144
      self.tableView.rowHeight = UITableViewAutomaticDimension
      
      self.tableView.delegate = self
      self.tableView.dataSource = self
      
      self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CELL")
      
      self.netController.fetchTwitterContent(homeTimeLineLink, userID: nil) { (tweets, error) -> Void in
        if (tweets != nil) {
          self.tweets = tweets!
          //call is asynchrouous need to reload data
          self.tableView.reloadData()
        }
      }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.1
    }
    
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.tweets.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as TweetCell
    let twit = self.tweets[indexPath.row]
    
    
    cell.tweetContent.text = twit.mainUserTweetContent
    cell.screenName.text = twit.mainUserScreenName
    
    
    return cell
  }

}
