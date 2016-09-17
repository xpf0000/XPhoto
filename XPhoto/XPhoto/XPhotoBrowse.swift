//
//  XPhotoBrowse.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/17.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class XPhotoBrowse: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,XZoomImageViewDelegate {

    var block:XPhotoResultBlock?
    var collection:UICollectionView!
    let tool = XPhotoToolbar()
    let color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.7)
    var nowRow = 0
    {
        didSet
        {
            checkChoosed()
        }
    }
    
    var assets:[XPhotoAssetModel] = []
    
    var imgArr:[NSIndexPath:UIImage] = [:]
    
    var indexPath:NSIndexPath!
    {
        didSet
        {
            nowRow = indexPath.row
        }
    }
    
    func checkChoosed()
    {
        tool.all.selected = XPhotoHandle.Share.chooseArr.contains(assets[nowRow])
    }
    
    func dismiss()
    {
        self.dismissViewControllerAnimated(true) {
            self.block = nil
            XPhotoHandle.Share.clean()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blackColor()
        self.automaticallyAdjustsScrollViewInsets = false
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.itemSize = CGSizeMake(SW, SH)
        
        collection = UICollectionView(frame: CGRectMake(0, 0, SW, SH), collectionViewLayout: layout)
        collection.showsVerticalScrollIndicator = false
        collection.showsHorizontalScrollIndicator = false
        collection.pagingEnabled = true
        collection.delegate = self
        collection.dataSource = self
        
        collection.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collection)

        tool.singleChoose = true
        tool.frame = CGRectMake(0, SH-50, SW, 50)
        tool.layer.masksToBounds = true
        tool.layer.shadowColor = UIColor.clearColor().CGColor
        tool.cancle.hidden = true
        tool.translucent = true
        tool.backgroundColor = color
        tool.setBackgroundImage(color.image, forToolbarPosition: .Top, barMetrics: .Compact)
        self.view.addSubview(tool)
        
        tool.block({ [weak self,weak tool](all) in
            if self == nil || tool == nil {return}
            self?.doChoose()
            }, cancle: { [weak self]()->Void in
                if self == nil {return}
        }) { [weak self]()->Void in
            if self == nil {return}
            self?.block?(XPhotoHandle.Share.chooseArr)
            self?.dismiss()
            
        }
        
        getRawImage(indexPath)
        collection.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath)
        
       for item in cell.contentView.subviews
       {
            item.removeFromSuperview()
        }
        
        let asset = assets[indexPath.row]
        
        let imgView = XZoomImageView()
        imgView.frame = CGRectMake(0, 0, SW, SH)
        imgView.tapDelegate = self
        if let img = imgArr[indexPath]
        {
            imgView.image = img
        }
        else
        {
            imgView.image = asset.image
        }
        
        cell.contentView.addSubview(imgView)
        
        return cell
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if let nvBar = self.navigationController?.navigationBar
        {
            nvBar.hidden = !nvBar.hidden
        }
        
        tool.hidden = !tool.hidden
        
    }
    
    func XZoomImageViewTapClick() {
    
        if let nvBar = self.navigationController?.navigationBar
        {
            nvBar.hidden = !nvBar.hidden
        }
        
        tool.hidden = !tool.hidden

    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
        let currentPage : Int = Int(floor((scrollView.contentOffset.x - SW/2)/SW))+1;
        
        nowRow = currentPage
        
        let index = NSIndexPath(forRow: currentPage, inSection: 0)
        
        if  imgArr[index] == nil
        {
           getRawImage(index)
        }

    }
    
    
    
    func doChoose()->Bool
    {
        
        let asset = assets[nowRow]
        
        if let index = XPhotoHandle.Share.chooseArr.indexOf(asset)
        {
            XPhotoHandle.Share.chooseArr.removeAtIndex(index)
        }
        else
        {
            if XPhotoHandle.Share.chooseArr.count == XPhotoLibVC.maxNum{return false}
            XPhotoHandle.Share.chooseArr.append(asset)
        }
        
        //tool.count = XPhotoHandle.Share.chooseArr.count
        
        return true
        
    }
    
    
    func getRawImage(index:NSIndexPath)
    {
        
        
        let ass = assets[index.row].alasset
        
        if #available(iOS 8.0, *)
        {
            if let phasset = ass as? PHAsset
            {
                let opt = PHImageRequestOptions()
                opt.resizeMode = .Fast
                PHImageManager.defaultManager().requestImageForAsset(phasset, targetSize: CGSizeMake(SW*SC, SH*SC), contentMode: .AspectFill, options: opt, resultHandler: { [weak self](result, info) in
                    if self == nil {return}
                    if result != nil
                    {
                        if let cell = self?.collection.cellForItemAtIndexPath(index)
                        {
                            let imgV = cell.contentView.subviews[0] as! XZoomImageView
                            imgV.image = result
                        }
                        
                        self?.imgArr[index] = result
                    }
                    
                    
                    })
            }
        }
        else
        {
            if let asset = ass as? ALAsset
            {
                let  image = UIImage(CGImage: asset.defaultRepresentation().fullScreenImage().takeUnretainedValue())
                if let cell = self.collection.cellForItemAtIndexPath(index)
                {
                    let imgV = cell.contentView.subviews[0] as! XZoomImageView
                    imgV.image = image
                }
                self.imgArr[index] = image
            }
            
        }
        
        
        
       
    }

    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = true
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
        
        if let nvBar = self.navigationController?.navigationBar
        {
            let image = color.image
            nvBar.setBackgroundImage(image, forBarMetrics:.Default)
            nvBar.tintColor = UIColor.whiteColor()
            nvBar.shadowImage = UIColor.clearColor().image
        }
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        if let nvBar = self.navigationController?.navigationBar
        {
            nvBar.setBackgroundImage(nil, forBarMetrics:.Default)
            nvBar.tintColor = nil
            nvBar.shadowImage = nil
        }

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.imgArr.removeAll(keepCapacity: false)
        
    }
    

    
}
