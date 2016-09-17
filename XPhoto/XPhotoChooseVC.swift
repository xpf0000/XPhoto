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

    var collect:UICollectionView!
    let tool = XPhotoToolbar()
 
    var assets:[XPhotoAssetModel] = []
    
    var chooseArr:[XPhotoAssetModel] = []

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
                print("点击了取消 !!!!!!")
                
            }) { [weak self]()->Void in
                if self == nil {return}
               print("点击了确定 !!!!!!")
                
        }
        
    

    }

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell:XPhotoChooseCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! XPhotoChooseCell
        
        let asset = assets[indexPath.row]
        cell.asset = asset

        cell.choose.selected = chooseArr.contains(asset )
        
        cell.doChoose {[weak self] (asset) ->Bool in
            if self == nil {return false}
            return self!.doChoose(asset)
        }
        
        return cell
        
    }
    
    func doChoose(asset:XPhotoAssetModel)->Bool
    {
    
        if let index = chooseArr.indexOf(asset)
        {
            chooseArr.removeAtIndex(index)
        }
        else
        {
            if chooseArr.count == ViewController.maxNum{return false}
            chooseArr.append(asset)
        }
        
        tool.count = chooseArr.count
        
        return true
        
    }
    
    func doChooseAll(all:Bool)
    {
        if all
        {
            let r = ViewController.maxNum - chooseArr.count
            var c = 0
            for asset in assets.reverse()
            {
                if !chooseArr.contains(asset )
                {
                    chooseArr.append(asset )
                    
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
                    if c == r {break}
                }
                
            }

            tool.count = chooseArr.count
        }
        else
        {
            chooseArr.removeAll(keepCapacity: false)
            
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
            
            tool.count = 0
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    deinit
    {
        print("XPhotoChooseVC deinit!!!!!!!!!")
    }
    

}
