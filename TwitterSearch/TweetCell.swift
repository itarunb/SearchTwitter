//
//  TweetCell.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 29/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit


//TweetCellReuseIdentifier
class TweetCell: UITableViewCell {
    @IBOutlet var profileImageView: UIImageView?
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var tweetTextLabel: UILabel?
    @IBOutlet var handleLabel: UILabel?
    @IBOutlet var favCountLabel: UILabel?
    @IBOutlet var favImageView: UIImageView?
    @IBOutlet var retweetCountLabel: UILabel?
    @IBOutlet var retweetImageView: UIImageView?

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.profileImageView?.layer.cornerRadius = 20
        self.profileImageView?.layer.masksToBounds = true
        
    }
}
