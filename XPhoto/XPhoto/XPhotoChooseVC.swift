//
//  XPhotoChooseVC.swift
//  XPhoto
//
//  Created by X on 16/9/14.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class XPhotoChooseVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var block:XPhotoResultBlock?
    var collect:UICollectionView!
    let tool = XPhotoToolbar()
 
    var assets:[XPhotoAssetModel] = []

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "contentSize"
        {
            if collect.contentSize.height > collect.frame.size.height
            {
                collect.contentOffset.y = collect.contentSize.height-collect.frame.size.height
            }
            
            collect.removeObserver(self, forKeyPath: "contentSize")
            
        }
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
        self.view.backgroundColor = UIColor.whiteColor()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0+50.0, 5.0)
        layout.itemSize = CGSizeMake((SW-25)/4.0, (SW-25)/4.0)
        
        collect = UICollectionView(frame: CGRectMake(0, 0, SW, SH), collectionViewLayout: layout)
        
        collect.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        
        collect.backgroundColor = UIColor.whiteColor()
        
        collect.delegate = self
        collect.dataSource = self
        
        collect.frame = CGRectMake(0, 0, SW, SH)
        
        collect.registerClass(XPhotoChooseCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collect)
        
        tool.frame = CGRectMake(0, SH-50, SW, 50)
        self.view.addSubview(tool)
        
        tool.block({ [weak self,weak tool](all) in
            if tool == nil {return}
            self?.doChooseAll(all)
            }, cancle: { [weak self]()->Void in
                if self == nil {return}
                self?.dismiss()
            }) { [weak self]()->Void in
                if self == nil {return}
                self?.block?(XPhotoHandle.Share.chooseArr)
                self?.dismiss()
                
        }
        
    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:XPhotoChooseCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! XPhotoChooseCell
        
        let asset = assets[indexPath.row]
        cell.asset = asset

        cell.choose.selected = XPhotoHandle.Share.chooseArr.contains(asset )
        
        cell.doChoose {[weak self] (asset) ->Bool in
            if self == nil {return false}
            return self!.doChoose(asset)
        }
        
        return cell
        
    }
    
    func doChoose(asset:XPhotoAssetModel)->Bool
    {
    
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
    
    func doChooseAll(all:Bool)
    {
        if all
        {
            let r = XPhotoLibVC.maxNum - XPhotoHandle.Share.chooseArr.count
            var c = 0
            for asset in assets.reverse()
            {
                if c == r {break}
                
                if !XPhotoHandle.Share.chooseArr.contains(asset )
                {
                    XPhotoHandle.Share.chooseArr.append(asset )
                    
                    for item in collect.visibleCells()
                    {
                        if let cell = item as? XPhotoChooseCell
                        {
                            if cell.asset == asset 
                            {
                                cell.choose.selected = true
                                cell.choose.bounceAnimation(0.3)
                            }
                        }
                    }
                    
                    c += 1
                    
                }
                
            }

            //tool.count = XPhotoHandle.Share.chooseArr.count
        }
        else
        {
            XPhotoHandle.Share.chooseArr.removeAll(keepCapacity: false)
            
            for item in collect.visibleCells()
            {
                if let cell = item as? XPhotoChooseCell
                {
                    if cell.choose.selected
                    {
                        cell.choose.selected = false
                        cell.choose.bounceAnimation(0.3)
                    }
                }
            }
            
            //tool.count = 0
        }
    }
    
    private lazy var  tempChooseArr:[XPhotoAssetModel]  = []
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
        tempChooseArr = XPhotoHandle.Share.chooseArr

        let vc = XPhotoBrowse()
        vc.assets = assets
        vc.indexPath = indexPath
        vc.block = block
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let b = tempChooseArr.count == XPhotoHandle.Share.chooseArr.count
        
        var b1 = true
        
        for item in XPhotoHandle.Share.chooseArr {
            if !tempChooseArr.contains(item)
            {
                b1 = false
            }
        }
        
        if !b || !b1
        {
            collect.reloadData()
        }
        
        tempChooseArr.removeAll(keepCapacity: false)
        
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    deinit
    {
        assets.removeAll(keepCapacity: false)
    }
    
    
    
    
    

}
