//
//  TweetCell.swift
//  TwitterClonePartDeux
//
//  Created by Josh Kahl on 1/18/15.
//  Copyright (c) 2015 Josh Kahl. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

  @IBOutlet weak var screenName: UILabel!
  
  @IBOutlet weak var tweetContent: UILabel!
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
