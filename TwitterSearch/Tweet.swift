//
//  Tweet.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import Foundation

enum ImageState {
    case loading
    case loaded
    case failed
    case unknown
}

class Tweet {
    var tweetText     : String?
    var retweetCount  : Int?
    var favoriteCount : Int?
    var tweetId       : String?
    var tweeter       : Tweeter?
    var imageState    : ImageState = .unknown
    let cacheIndexingKey : String = UUID().uuidString
    var popularityMeasure : Double {
        get {
            var measure :Double = 0.0
            if let count = retweetCount  {
                measure += Double(exactly: count)!
            }
            if let count = favoriteCount {
                measure += Double(exactly: count)! * 0.0001
            }
            if let user  = tweeter ,let followers = user.followersCount {
                measure += Double(exactly: followers)! * 0.002
            }
            return measure
        }
    }
    
    init(text:String,retweet:Int,favorite:Int,id:String) {
        tweetText       = text
        retweetCount    = retweet
        favoriteCount   = favorite
        tweetId         = id
    }
}
