//
//  XPhotoChooseVC.swift
//  XPhoto
//
//  Created by X on 16/9/14.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary

class XPhotoChooseVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {

    var collect:UICollectionView!
    
    var assets:[ALAsset] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5.0
        layout.minimumInteritemSpacing = 5.0
        layout.sectionInset = UIEdgeInsetsMake(0, 5.0, 0.0, 5.0)
        layout.itemSize = CGSizeMake((SW-25)/4.0, (SW-25)/4.0)
        
        collect = UICollectionView(frame: CGRectMake(0, 0, SW, SH), collectionViewLayout: layout)
        collect.backgroundColor = UIColor.whiteColor()
        
        collect.delegate = self
        collect.dataSource = self
        
        collect.frame = CGRectMake(0, 0, SW, SH)
        
        collect.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collect)

        
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
        
        print(assets.count)
        
        let asset = assets[indexPath.row]

        let cg = asset.aspectRatioThumbnail().takeRetainedValue()
        
        let image = UIImageView()
        image.frame = CGRectMake(0, 0, (SW-25)/4.0, (SW-25)/4.0)
        image.image = UIImage(CGImage: cg)
        cell.contentView.addSubview(image)
        
        return cell
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    

}
