//
//  PhotoAlbum.swift
//  Mobile Capture Demo
//
//  Created by Michael Chernikov on 17/05/16.
//  Copyright © 2016-2017 Atalasoft. All rights reserved.
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
                case .authorized:
                    break
                case .restricted:
                    return
                case .denied:
                    return
                default:
                    // place for .NotDetermined - in this callback status is already determined so should never get here
                    break
                }
            }
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", PhotoAlbum.albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            
            if let _: AnyObject = collection.firstObject {
                return collection.firstObject as PHAssetCollection!
            }
            
            return nil
        }
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: PhotoAlbum.albumName)
        }) { success, _ in
            if success {
                self.assetCollection = fetchAssetCollectionForAlbum()
            }
        }
    }
    
    func saveImage(image: UIImage, completionHandler: @escaping (_ result: Bool, _ error: NSError?) -> Void) {
        
        if assetCollection == nil {
            return   // If there was an error upstream, skip the save.
        }
        
        PHPhotoLibrary.shared().performChanges(
            {
                let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
                albumChangeRequest!.addAssets([assetPlaceholder!] as NSArray)
        }, completionHandler: completionHandler as? (Bool, Error?) -> Void)
        }
}
