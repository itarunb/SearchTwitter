//
//  TweetStore.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 29/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit


class TweetStore {
    private var tweetsArray = Array<Tweet>()
    var refreshResultParams : [String : String]?
    private var currentSearch : String = ""
    private var newSearch : Bool = true
    var endReched = false
    var sortedByPopularity = false
    init(searchTerm:String) {
        currentSearch = searchTerm
        tweetsArray.removeAll()
        refreshResultParams?.removeAll()
        API.cancelPendingTasks(handler: {
            DispatchQueue.main.async {
                self.fetchPageResults()
            }
        })

    }
    
    //MARK:- Getter/Setter methods
    
    func numberOfTweets() ->Int {
        return tweetsArray.count
    }
    
    func getRetweetCountString(index: Int) -> String? {
        if index < tweetsArray.count{
            if let number = tweetsArray[index].retweetCount {
                return "\(number)"
            }
        }
        return nil
    }
    
    func getFavCountString(index: Int) -> String? {
        if index < tweetsArray.count{
            if let number = tweetsArray[index].favoriteCount {
                return "\(number)"
            }
        }
        return nil
    }
    
    func getImageCacheState(index: Int) -> ImageState {
        if index < tweetsArray.count{
            return tweetsArray[index].imageState
        }
        return .unknown
    }
    
    func setImageCacheState(state : ImageState , index: Int)  {
        if index < tweetsArray.count{
            return tweetsArray[index].imageState = state
        }
    }


    func getNameLabelString(index: Int) -> String? {
        if index < tweetsArray.count{
            if let str = tweetsArray[index].tweeter?.name {
                return str
            }
        }
        return nil
    }

    func getHandleLabelString(index: Int) -> String? {
        if index < tweetsArray.count{
            if let str = tweetsArray[index].tweeter?.handle {
                return str
            }
        }
        return nil
    }

    
    func getTweetTextString(index: Int) -> String? {
        if index < tweetsArray.count{
            if let str = tweetsArray[index].tweetText {
                return str
            }
        }
        return nil
    }

    func getImageUrl(index: Int) -> String? {
        if index < tweetsArray.count {
            return tweetsArray[index].tweeter?.imageUrl
        }
        return nil
    }
    
    func getCacheIndexingKey(index:Int) -> String {
        if index < tweetsArray.count {
            return tweetsArray[index].cacheIndexingKey
        }
        return ""
    }
    
    
    func getTweetUrl(index:Int) -> String {
        if index < tweetsArray.count {
            if let id = tweetsArray[index].tweetId {
                return "https://twitter.com/i/web/status/" + id
            }
        }
        return "https://twitter.com/"
    }
    
    
    //MARK:- Data fetching and parsing
    
     func fetchPageResults() {
        var params = ["q" : currentSearch]
        
        if let refreshParams = refreshResultParams {
            newSearch = false
            for (key,val) in refreshParams {
                params[key] = val
            }
        }

        API.sendHTTPCall(request: TwitterRequestHelper.createSearchRequest(params: params)!, handler: {
            (data,error) in
            if error == nil {
                if let validData = data {
                    DispatchQueue.main.async {
                        self.parseResults(data:validData)
                    }
                }
            }
        })
    }
    
    private func parseResults(data : Data) {
      do {
        let jsonobject  = try JSONSerialization.jsonObject(with: data, options: [])
           guard let jsonDictionary = jsonobject as? [AnyHashable:Any],
            let tweetArray    = jsonDictionary["statuses"] as? [[String : Any]],
            let otherFields    = jsonDictionary["search_metadata"] as? [String : Any] else {
                return
            }
        
       // print("***otherfields***")
        for (key,val) in otherFields {
          //  print("\(key) : \(val)")
            if key == "refresh_url" {
                if let str = val as? String {
                    refreshResultParams = self.parseRefreshURL(string: str)
                }
            }
        }
        
        if tweetArray.count == 0 {
            endReched = true
        }
        
        //                    print("\(statusArray[0]["retweet_count"]) **** \(statusArray[0]["favorite_count"]) **** \(statusArray[0]["text"]) ***")
        //                    let user = statusArray[0]["user"] as! [String : Any]
        //                    print("**** \(user["screen_name"]) **** \(user["name"])**** \(user["profile_image_url"])**** \(user["followers_count"])**** \(user["friends_count"])**** \(user["statuses_count"])")

        var tempArray = [Tweet]()
    if(tweetArray.count != 0) {
        for i in 0...tweetArray.count-1 {
            let dict = tweetArray[i]
            guard
            
                let retweetCount  = dict["retweet_count"] as? Int,
                let tweetId       = dict["id_str"] as? String,
                let tweetText     = dict["text"] as? String,
/*                let entityDict    = dict["entities"] as? [String:Any],
                let urlArray      = entityDict["urls"] as? [[String:Any]],*/
                let userDict      = dict["user"] as? [String:Any],
                let userName      = userDict["name"] as? String,
                let userHandle    = userDict["screen_name"] as? String/*,
                let timeStamp     = dict["created_at"] as? String*/ else {
                    continue
            }
            
            var favCountOutside : Int?
            var favCountInside : Int?

            favCountOutside = dict["favorite_count"] as? Int
            
            if let statusDict = dict["retweeted_status"] as? [String:Any] {
              if let count     = statusDict["favorite_count"] as? Int  {
                    favCountInside = count
              }
            }
            
            let finalFavCount  = favCountOutside == nil ? (favCountInside == nil ? 0 : favCountInside!) : (favCountInside == nil ? favCountOutside! : max(favCountOutside!,favCountInside!))
            
//            print("*** Created at : \(timeStamp) *****")
//            print("*** TweetId : \(tweetId) *****")
            
//            print("********************")
//            print(tweetText)
//            var count = 0
//            tweetText.enumerateLines(invoking: {
//                (str,stop) in
//                   count += 1
//            })
//            print("Number of lines in tweet i : \(count)")
//            print("********************")
            
            
            let tweet = Tweet(text: tweetText, retweet: retweetCount, favorite: finalFavCount,id:tweetId)
                        
            let user  = Tweeter(nameStr: userName, handleStr: userHandle)
            
            //These are optional we can still show results without theses fields existing
            if let followersCount = userDict["followers_count"] as? Int {
                user.followersCount = followersCount
            }
            if let friendsCount   = userDict["friends_count"] as? Int {
                user.friendsCount = friendsCount
            }

            if let tweetCount   = userDict["statuses_count"] as? Int {
                user.totalTweets = tweetCount
            }
            
            if let userId   = userDict["id_str"] as? String {
                user.userId = userId
            }
            
            if let imageStr   = userDict["profile_image_url"] as? String {
                user.imageUrl = imageStr
            }

            tweet.tweeter = user
            
            tempArray.append(tweet)
        }
      }
        if(newSearch) {
            tweetsArray.append(contentsOf: tempArray)
        } else {
            tempArray.append(contentsOf: tweetsArray)
            tweetsArray = tempArray
        }
        NotificationCenter.default.post(name: Notification.Name("com.searchNews.updateTable"), object: nil)

        
        } catch let errors {

            }

    }
    
    func sortByPopularity() {
        if tweetsArray.count > 1 {
            tweetsArray.sort(by: {
                tweet1,tweet2 in
                  return tweet1.popularityMeasure > tweet2.popularityMeasure
            })
            sortedByPopularity = true
            NotificationCenter.default.post(name: Notification.Name("com.searchNews.updateTable"), object: nil)
        }
    }
    
    private func parseRefreshURL(string: String) -> [String : String]? {
        
        let range = string.index(after: string.startIndex)..<string.endIndex
        let str = string[range]
        
        let components = str.components(separatedBy: "&")
        
        var dictionary : [String : String] = [:]
        
        for component in components{
            let pair = component.components(separatedBy: "=")
            dictionary[pair[0]] = pair[1]
        }
        
        return dictionary
    }
}


