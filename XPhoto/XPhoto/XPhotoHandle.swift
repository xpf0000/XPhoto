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
            if #available(iOS 8.0, *)
            {
                if XPhotoUseVersion7
                {
                    version7()
                }
                else
                {
                    version8()
                }
            }
            else
            {
                version7()
            }
        }
    }
    var image:UIImage?
    
    @available(iOS 8.0, *)
    private func version8()
    {
        if let set = alasset as? PHAsset
        {
//偶尔会卡  cpu 飙升到200%左右  猜测为同一时间进行的任务太多  使用队列进行控制下
            XPhotoHandle.Share.AssetQueue.addOperationWithBlock { () -> Void in
                
                let opt = PHImageRequestOptions()
                opt.resizeMode = .Fast
                PHImageManager.defaultManager().requestImageForAsset(set, targetSize: CGSizeMake((SW-25)/4.0*SC, (SW-25)/4.0*SC), contentMode: .AspectFill, options: opt, resultHandler: { [weak self](result, info) in
                    
                    if result != nil
                    {
                        self?.image = result
                    }
                    
                    })
                
            }
            
        }
    }
    
    private func version7()
    {
        if let set = alasset as? ALAsset
        {
            image = UIImage(CGImage: set.aspectRatioThumbnail().takeUnretainedValue())
        }

    }
    
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
                if XPhotoUseVersion7
                {
                    version7()
                }
                else
                {
                    version8()
                }
            }
            else
            {
                version7()
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
    
    @available(iOS 8.0, *)
    private func version8()
    {
        if let g = group as? PHAssetCollection
        {
            id = g.localIdentifier
            let r = PHAsset.fetchAssetsInAssetCollection(g, options:nil)
            let assett:PHAsset = r.lastObject as! PHAsset
            
            let opt = PHImageRequestOptions()
            opt.resizeMode = .Fast
            PHImageManager.defaultManager().requestImageForAsset(assett, targetSize: CGSizeMake(60.0*SC, 60.0*SC), contentMode: .AspectFill, options: opt, resultHandler: { (result, info) in
               
                if result != nil
                {
                    self.image = result
                }
                
            })
            
            self.title = g.localizedTitle!
        }
    }
    
    private func version7()
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


class XPhotoHandle: NSObject {
    
    static let Share = XPhotoHandle()
    
    let AssetQueue = NSOperationQueue()
    
    
    lazy var assetGroups:[XPhotoGroupModel] = []
    lazy var assets:[String:[XPhotoAssetModel]] = [:]
    
    var chooseArr:[XPhotoAssetModel] = []
    {
        didSet
        {
            for item in chooseChangeblock
            {
                item?()
            }
        }
    }
    
    private var block:XPhotoFinishBlock?
    private var chooseChangeblock:[XPhotoFinishBlock?] = []
    
    private var running = false
    
    func handleFinish(b:XPhotoFinishBlock)
    {
        self.block = b
    }
    
    func chooseChange(b:XPhotoFinishBlock)
    {
        self.chooseChangeblock.append(b)
    }
    
    override private init() {
        //设置最大并发数
        AssetQueue.maxConcurrentOperationCount=10
    }
    
    func clean()
    {
        chooseArr.removeAll(keepCapacity: false)
        assetGroups.removeAll(keepCapacity: false)
        assets.removeAll(keepCapacity: false)
        chooseChangeblock.removeAll(keepCapacity: false)
    }
    
    func handle()
    {
        if running {return}
        running = true
        clean()
        
        if #available(iOS 8.0, *) {
            
            if XPhotoUseVersion7
            {
                self.version7()
            }
            else
            {
                self.version8()
            }
            
            
        } else {
            
            self.version7()
            
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
        running = false
        
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
                                for(key,value) in self.assets
                                {
                                    self.assets[key] = value.reverse()
                                }
                                
                                self.block?()
                                self.running = false
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
