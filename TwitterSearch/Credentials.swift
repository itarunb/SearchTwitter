//
//  Credentials.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import Foundation


//This will look if you have already generated an access token and saved it , otherwise it will send a call to generate one

class Credentials {
    private var accessToken : String?
    private let tokenKey  = "tokenKey"
    init() {
        if accessToken == nil {
            if let token = getStoredAccessToken() {
                accessToken = token
            }
            else{
                if let request = TwitterRequestHelper.createAuthenticationRequest() {
                API.sendHTTPCall(request: request, handler: {
                    (data,error) in
                    if let validData = data {
                        self.parseToken(data:validData)
                    }
                })
              }
            }
        }
    }
    
    
    private func parseToken(data : Data) {
        do {
            let jsonobject  = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let jsonDictionary  = jsonobject as? [AnyHashable:Any],
                let type            = jsonDictionary["token_type"] as? String,
                let token           = jsonDictionary["access_token"] as? String else {
                    return
            }

            if type == "bearer" {
                accessToken = token
                UserDefaults.standard.set(accessToken, forKey: tokenKey)
                print("******* Token was successfully parsed and stored***")
            }
            else {
                print("******* Token type wasnt bearer")
            }
            
        } catch let error {
            print("******* Error during parsing token from API Call \(error)")
        }
    }

    
    private func getStoredAccessToken() -> String? {
       return UserDefaults.standard.string(forKey:tokenKey)
    }
    
    
    public func getAccessToken() ->String? {
        return accessToken
    }
}
