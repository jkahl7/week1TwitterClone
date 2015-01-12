//
//  TweetCell.swift
//  Week1TwitterClone
//
//  Created by Josh Kahl on 1/5/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {
  
  //var networkController = NetworkController()
 // var screenName

  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var tweetContent: UITextView!
  //@IBOutlet weak var backgroundImage: UIImageView!
  @IBOutlet weak var tweetTime: UILabel!
  //@IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userImageButton: UIButton!
    override func awakeFromNib() {
      // very similar behavior to viewDidLoad()
      super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  /*
  override func layoutSubviews() {
    super.layoutSubviews()
    self.contentView.layoutIfNeeded()
  } */
}
