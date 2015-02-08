//
//  HomeViewController.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/5/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//


import UIKit
import Accounts
import Social

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
  var tweets            = [Tweet]()
  var networkController = NetworkController()

  //outlet for the tableView
  @IBOutlet weak var tableView  : UITableView!
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    // prepares the tableView cells for automatic resizing an registers a nib object to the tableView
    self.tableView.estimatedRowHeight = 144
    self.tableView.rowHeight          = UITableViewAutomaticDimension
    self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "CELL")
    // access' the NetworkControllers closure function to populate the tweets array with Tweet objects
    self.networkController.fetchHomeTimeline { (tweets, error) -> Void in
      if (error == nil)
      {
        self.tweets = tweets!
        // reloads the tableView once the tweets array is populated
        self.tableView.reloadData()
      }
    }
  }
  
  // pushes the information about the selected row to DetailViewController -
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
  {
    let toDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("Details") as DetailViewController
    navigationController?.pushViewController(toDetailVC, animated: true)
    
    toDetailVC.networkController = self.networkController
    toDetailVC.tweet             = tweets[indexPath.row]
  }
  
  override func didReceiveMemoryWarning()
  {
    super.didReceiveMemoryWarning()
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return self.tweets.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCellWithIdentifier("CELL", forIndexPath: indexPath) as TweetCell
    
    cell.tweetTime.text    = tweets[indexPath.row].tweetTime
    cell.tweetContent.text = tweets[indexPath.row].tweetText
    cell.userName.text     = tweets[indexPath.row].tweeter
    cell.userImageButton.setImage(tweets[indexPath.row].image, forState: .Normal)

    //lazy loading
    if(self.tweets[indexPath.row].image == nil)
    {
      self.networkController.fetchImageForCell(self.tweets[indexPath.row], storedIndexPath: indexPath, completionHandler: { (image, storedIndexPath, errorReport) -> Void in
        if(errorReport == nil)
        {
          self.tableView.reloadRowsAtIndexPaths([storedIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
          cell.userImageButton.setImage(nil, forState: .Normal)
          println("image not found")
        }
      })
    }
    
    
    cell.userImageButton.image.alpha = 0
    
    return cell
  }
}

