//
//  Tweeter.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import Foundation

class Tweeter {
    var name            : String?
    var handle          : String?
    var imageUrl        : String?
    var followersCount  : Int?
    var friendsCount    : Int?
    var totalTweets     : Int?
    var userId          : String?
    
    init(nameStr: String, handleStr: String) {
        name = nameStr
        handle = handleStr
    }
}
