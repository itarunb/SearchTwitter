//
//  WebViewVC.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 31/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit
import WebKit

class WebViewVC : UIViewController {
    
    lazy var webView: WKWebView = {
        
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration.init())
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        return webView
    }()
    
    lazy var spinner : UIActivityIndicatorView = {
        // print("Spinner Initialised")
        let activityView = UIActivityIndicatorView.init(style:.gray)
        return activityView
    }()
    
    
    var url : String?
    
    override func loadView() {
        super.loadView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Twitter Web"
        self.navigationItem.setRightBarButton((UIBarButtonItem.init(customView: spinner)), animated: true)
        spinner.startAnimating()
        let myURL = URL(string:url!)
        // let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            print("Estimated Progress -- \(Float(webView.estimatedProgress))%")
            if webView.estimatedProgress > 0.9 {
                spinner.stopAnimating()
            }
        }
    }
    
}
