//
//  TwitterRequestHelper.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit

class TwitterRequestHelper {
  static private let baseURLStringAuth = "https://api.twitter.com/oauth2/token"
  static private let baseURLStringSearch = "https://api.twitter.com/1.1/search/tweets.json"
  //Consumer Key and Consumer Key Secret are generated when you create a Twitter App online
  //Use this to read more https://developer.twitter.com/en/docs/basics/apps/overview
  static private let consumerKey = "YOUR CONSUMER KEY"
  static private let consumerKeySecret = "YOUR CONSUMER KEY SECRET"
    
  static private let authQueryParams = ["grant_type" : "client_credentials"]

//These params will be overwritten by any additional params sent while making a search result API call
  static private let searchQueryParams = ["lang" : "en",
                                          "result_type" : "recent",
                                          "count" : "30"]


    static func createAuthenticationRequest() -> URLRequest? {
       guard let encodedKey = consumerKey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
        let encodedSecret = consumerKeySecret.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        
        let combinedKey = "\(encodedKey):\(encodedSecret)"

        if let data = combinedKey.data(using: .utf8) {
           let str = data.base64EncodedString(options: [])
        
            var components = URLComponents(string: baseURLStringAuth)
            var queryItems = [URLQueryItem]()
            
            for (key, value) in authQueryParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
            components?.queryItems = queryItems
            
            var request = URLRequest(url: (components?.url)!)
            
            request.setValue("Basic \(str)", forHTTPHeaderField: "Authorization")
            
            request.httpMethod = "POST"
            
            return request
        }
        return nil
    }
    
    
    static func createImageFetchRequest(strUrl : String) -> URLRequest? {
        var URL = URLComponents(string: strUrl)?.url
        
        if URL != nil {
            let req = URLRequest(url: URL!)
            return req
        }
        return nil
  }
    
    static func createSearchRequest(params : [String : String]?) -> URLRequest? {
        //If we dont have valid credentials by now lets return nil
       if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let cred = appDelegate.twitterCredential,
         let token  = cred.getAccessToken() {
            var components = URLComponents(string: baseURLStringSearch)
            var queryItems = [URLQueryItem]()
        
        
            for (key, value) in searchQueryParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        
            //Any duplicate default params in default param dictionary above will be overwritten by passed ones
            if let additionalParams  = params {
                for (key, value) in additionalParams {
                    let item = URLQueryItem(name: key, value: value)
                    queryItems.append(item)
                }
            }
            components?.queryItems = queryItems
        
            var request = URLRequest(url: (components?.url)!)
        
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
            request.httpMethod = "GET"
        
            return request

        }
       else {
            return nil
        }


    }
}
