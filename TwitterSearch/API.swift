//
//  API.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 28/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import Foundation


class API {
    static let session : URLSession = {
        let config = URLSessionConfiguration.default
        let urlSession = URLSession.init(configuration: config)
        return urlSession
    }()
    
    
    static func sendHTTPCall(request : URLRequest , handler :@escaping (Data?,Error?) -> Void) {
            let dataTask = session.dataTask(with: request, completionHandler: {
                (data,response,error) in
                handler(data,error)
            })
            dataTask.resume()
    }

    
    static func cancelPendingTasks(handler :@escaping () -> Void) -> Void {
        session.getAllTasks(completionHandler: {
            sessionTasks in
            if sessionTasks.count > 0 {
                for task in sessionTasks {
                    task.cancel()
                }
            }
            handler()
        })
    }

}
