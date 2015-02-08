//
//  DetailViewController.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/7/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController
{
  var tweet             : Tweet! // recieves an unwrapped tweet class from the TableViewController
  var networkController : NetworkController! //this will refrence the same instance of the
 
  @IBOutlet weak var backgroundImage  : UIImageView!
  @IBOutlet weak var buttonImage      : UIButton!
  @IBOutlet weak var favoritesLabel   : UILabel!
  
  // clicking the button triggers the TimeLineVC to appear
  @IBAction func buttonClicked(sender: UIButton)
  {
    let toTimeLineVC = self.storyboard?.instantiateViewControllerWithIdentifier("HOMETIMELINE") as TimeLineViewController
    navigationController?.pushViewController(toTimeLineVC, animated: true)
   
    toTimeLineVC.networkController = self.networkController
    toTimeLineVC.userID            = self.tweet.userID
    toTimeLineVC.selectedTweet     = self.tweet
  }
  
  override func viewDidLoad()
  {
    super.viewDidLoad()
    self.buttonImage.setImage(self.tweet.image, forState: .Normal)
    self.networkController.fetchDetailForCell(self.tweet.ID, completionHandler: { (details, errorReport) -> Void in
        if (errorReport == nil)
        {
          self.tweet.updateWithInfo(details!)
          self.favoritesLabel.text   = "Favorited:" + self.tweet.favoriteCount!
          self.backgroundImage.image = self.tweet.backgroundImage
        }
      })
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
  }
