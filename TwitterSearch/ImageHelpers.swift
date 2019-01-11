//
//  ImageHelpers.swift
//  TwitterSearch
//
//  Created by Tarun Bhargava on 29/12/18.
//  Copyright © 2018 searchTwitter. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func loadImageForItem(url : String ,handler:@escaping (Data?,Error?) -> Void) {

        let request = TwitterRequestHelper.createImageFetchRequest(strUrl: url)
        if request != nil {
            API.sendHTTPCall(request: request!, handler: {
                (data,error) in
                handler(data,error)
            })
        } else {
            print("A valid request for image url \(url) couldnt be created")
        }
    }
}

extension UIImage {
    func resizeImage(targetSize : CGSize) -> UIImage? {
        //Copied from https://stackoverflow.com/questions/31314412/how-to-resize-image-in-swift
        let image = self
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width :size.width * heightRatio,height: size.height * heightRatio)
        } else {
            newSize = CGSize(width :size.width * widthRatio,height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x :0, y:0,width: newSize.width,height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in:rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
  }
}
