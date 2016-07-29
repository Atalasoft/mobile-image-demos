//
//  PhotoAlbum.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 17/05/16.
//  Copyright © 2016 Atalasoft, a Kofax Company. All rights reserved.
//

import Photos

class PhotoAlbum {
    
    static let albumName = "Mobile Image Album"
    static let sharedInstance = PhotoAlbum()
    
    var assetCollection: PHAssetCollection!
    
    init() {
        
        func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
            
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .Authorized:
                    break
                case .Restricted:
                    return
                case .Denied:
                    return
                default:
                    // place for .NotDetermined - in this callback status is already determined so should never get here
                    break
                }
            }
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollectionsWithType(.Album, subtype: .Any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject as! PHAssetCollection
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(PhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(image: UIImage, completionHandler: (result: Bool, error: NSError?) -> Void) {
        
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
        PHPhotoLibrary.sharedPhotoLibrary().performChanges(
            {
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(forAssetCollection: self.assetCollection)
                albumChangeRequest!.addAssets([assetPlaceholder!])
            }, completionHandler: completionHandler)
        }
}