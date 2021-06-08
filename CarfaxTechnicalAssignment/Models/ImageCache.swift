//
//  ImageCache.swift
//  CarfaxTechnicalAssignment
//
//  Created by Andrew Huber on 6/7/21.
//

import UIKit

class ImageCache {
    private let queue = DispatchQueue(label: "ImageCache")
    private var cache = NSCache<NSString, UIImage>()
    private var cannotLoad = Set<String>()
    
    subscript(_ photo: FirstPhotos) -> UIImage? {
        get {
            return queue.sync { return self[photo.large] }
        }
    }
    
    private subscript(_ url: String) -> UIImage? {
        get {
            if cannotLoad.contains(url) {
                return nil
            }
            
            if let image = cache.object(forKey: NSString(string: url)) {
                return image
            }
            
            if let image = UIImage(fromURL: url) {
                cache.setObject(image, forKey: NSString(string: url))
                return image
            }
            
            cannotLoad.insert(url)
            return nil
        }
    }
}
