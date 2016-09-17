//
//  XPhotoHandle.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/16.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class XPhotoAssetModel: NSObject {
    
    var alasset:NSObject?
    {
        didSet
        {
  
            if #available(iOS 8.0, *) {
                if let set = alasset as? PHAsset
                {
                    
                    let opt = PHImageRequestOptions()
                    
                    PHImageManager.defaultManager().requestImageForAsset(set, targetSize: CGSizeMake((SW-25)/4.0*SC, (SW-25)/4.0*SC), contentMode: .AspectFill, options: opt, resultHandler: { [weak self](result, info) in
                        
                        self?.image = result
                        
                        })
                    
                }
            } else {
               
                if let set = alasset as? ALAsset
                {
                    image = UIImage(CGImage: set.aspectRatioThumbnail().takeUnretainedValue())
                }
                
            }
        }
    }
    var image:UIImage?
    
}


class XPhotoGroupModel: NSObject {
    
    private var block:XPhotoImageBlock?
    
    func imageBlock(b:XPhotoImageBlock)
    {
        block = b
    }
    
    var group:NSObject?
    {
        didSet
        {
            
            if #available(iOS 8.0, *)
            {
                if let g = group as? PHAssetCollection
                {
                    id = g.localIdentifier
                    let r = PHAsset.fetchKeyAssetsInAssetCollection(g, options:nil)
                    let assett:PHAsset = r?.lastObject as! PHAsset
                    
                    let opt = PHImageRequestOptions()
                    
                    PHImageManager.defaultManager().requestImageForAsset(assett, targetSize: CGSizeMake(60.0*SC, 60.0*SC), contentMode: .AspectFill, options: opt, resultHandler: { (result, info) in
                         self.image = result
                    })
                    
                    self.title = g.localizedTitle!
                }
            }
            else
            {
                if let g = group as? ALAssetsGroup
                {
                    let cg = g.posterImage().takeUnretainedValue()
                    image = UIImage(CGImage: cg)
                    title = XPhotoHandle.getGroupName(g)
                    id = XPhotoHandle.getGroupID(g)
                }

            }
        }
        
    }
    
    var title = ""
    var image:UIImage?
    {
        didSet
        {
            block?(image)
        }
    }
    var id = ""
    
}


class XPhotoHandle: NSObject {
    
    static let Share = XPhotoHandle()
    
    lazy var assetGroups:[XPhotoGroupModel] = []
    lazy var assets:[String:[XPhotoAssetModel]] = [:]
    
    private var block:XPhotoFinishBlock?
    
    func handleFinish(b:XPhotoFinishBlock)
    {
        self.block = b
    }
    
    override private init() {
        
    }
    
    func clean()
    {
        assetGroups.removeAll(keepCapacity: false)
        assets.removeAll(keepCapacity: false)
    }
    
    func handle()
    {
        if #available(iOS 8.0, *) {
            
            version8()
            
        } else {
            
            version7()
            
        }

    }
    
    @available(iOS 8.0, *)
    func version8()
    {
        //系统相册
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum, subtype: PHAssetCollectionSubtype.AlbumRegular, options: nil)
        
        for i in 0..<smartAlbums.count
        {
            let collection = smartAlbums[i]
            
            if let c = collection as? PHAssetCollection
            {
                if c.assetCollectionSubtype.rawValue == 209 || c.assetCollectionSubtype.rawValue == 206 || c.assetCollectionSubtype.rawValue == 211 || c.assetCollectionSubtype.rawValue == 210
                {
                    let model = XPhotoGroupModel()
                    model.group = c
                    assetGroups.append(model)
                    
                    let id = c.localIdentifier
                    
                    assets[id] = []
                    
                    let fetchResult:PHFetchResult = PHAsset.fetchAssetsInAssetCollection(c, options: nil)
                    if fetchResult.count != 0
                    {
                        for j in 0..<fetchResult.count
                        {
                            let asset:PHAsset = fetchResult[j] as! PHAsset
                            let model = XPhotoAssetModel()
                            model.alasset = asset
                            assets[id]?.append(model)
                            
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
        block?()
        
    }
    
    func version7()
    {
        let assetsLibrary =  ALAssetsLibrary()
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, stop) in
            
            if(group != nil)
            {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                
                if group.numberOfAssets() > 0
                {
                    let model = XPhotoGroupModel()
                    model.group = group
                    self.assetGroups.append(model)
                    let id = group.valueForProperty(ALAssetsGroupPropertyPersistentID) as! String
                    self.assets[id] = []
                }
                
            }
            else
            {
                if (self.assetGroups.count > 0) {
                    // 把所有的相册储存完毕，可以展示相册列表
                    
                    for item in self.assetGroups
                    {
                        (item.group as! ALAssetsGroup).enumerateAssetsWithOptions(.Reverse, usingBlock: { (result, index, stop) in
                            
                            if result != nil
                            {
                                let id = XPhotoHandle.getGroupID(item.group as! ALAssetsGroup)
                                
                                let model = XPhotoAssetModel()
                                model.alasset = result
                                self.assets[id]?.append(model)
                                
                            }
                            else
                            {
                                print("group遍历完毕 !!!!!!")
                                
                                self.block?()
                            }
                            
                        })
                        
                        
                    }
                    
                } else {
                    // 没有任何有资源的相册，输出提示
                }
            }
            
            
            
            
        }) { (error) in
            
            print("error: \(error)")
        }
        
    }
    
    class func getGroupID(g:ALAssetsGroup)->String
    {
        return g.valueForProperty(ALAssetsGroupPropertyPersistentID) as! String
    }
    
    class func getGroupName(g:ALAssetsGroup)->String
    {
        return g.valueForProperty(ALAssetsGroupPropertyName) as! String
    }

}
