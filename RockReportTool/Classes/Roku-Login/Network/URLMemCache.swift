//
//  URLMemCache.swift
//

import UIKit


public protocol URLMemCache {
    func store<T>(key: String, object: T)
    func retrieve<T>(_ key: String) -> T?
}


@objc public protocol URLMemCacheObjC {
    func storeImage(key: String, object: UIImage)
    func retrieveImage(_ key: String) -> UIImage?
}

@objc public class URLImageCache: NSObject, URLMemCache, URLMemCacheObjC {

    @objc public static let shared = URLImageCache()

    fileprivate let cache : NSCache<AnyObject, AnyObject> = {
        let c = NSCache<AnyObject, AnyObject>()
        // Adding cache constraints due to a memory crash on older phones (MOBIOS-2536).
        // As an example, 110 images from the TRC homepage yielded about 50 MB.
        // Setting totalCostLimit to 20 MB still allowed the page to scroll
        //    pretty well.
        c.countLimit = 125           // 125 total images cached
        c.totalCostLimit = 40000000  // 40 MB
        return c
    }()
    fileprivate var count = 0
    fileprivate var cost = 0

    @objc public func storeImage(key: String, object: UIImage) {
        cache.setObject(object as AnyObject, forKey: key as AnyObject)
    }

    @objc public func retrieveImage(_ key: String) -> UIImage? {
        return cache.object(forKey: key as AnyObject) as? UIImage
    }

    public func store<T>(key: String, object: T) {
        
        #if DEBUG
        if retrieve(key) == nil {
            count += 1
        }
        #endif
                
        if let image = object as? UIImage, let cgimage = image.cgImage {
            let accurateCost = cgimage.height * cgimage.bytesPerRow
            NSLog("cost \(accurateCost)")
            cost += accurateCost
            cache.setObject(object as AnyObject, forKey: key as AnyObject, cost: accurateCost)
        }
        else {
            cache.setObject(object as AnyObject, forKey: key as AnyObject)
        }
    }

    public func retrieve<T>(_ key: String) -> T? {
        return cache.object(forKey: key as AnyObject) as? T
    }

    public func removeObject(_ key: String) {
        #if DEBUG
        if retrieve(key) != nil {
            count -= 1
        }
        #endif
        cache.removeObject(forKey: key as AnyObject)
    }
    
    @objc public func removeAllObjects() {
        #if DEBUG
        NSLog("URLImageCache.removingAllObjects: \(count) objects, cost = \(cost)")
        #endif
        count = 0
        cost = 0
        cache.removeAllObjects()
    }
    
}
