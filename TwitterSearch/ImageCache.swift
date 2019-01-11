//
//  ImageCache.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 29/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit


class ImageCache: NSObject,NSCacheDelegate {
   let cache      =  NSCache<NSString,UIImage>()
   let cacheLimit = 200
    
   override init() {
        super.init()
        cache.totalCostLimit = cacheLimit
        cache.delegate = self
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString, cost: 1)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}



extension ImageCache {
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        //print("*** Cache item being evicted Cache Size")
    }
}
