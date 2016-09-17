//
//  XPhotoChooseCell.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/16.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary
import Photos

class XPhotoChooseCell: UICollectionViewCell {
    
    let choose = UIButton(type: .Custom)
    let img = UIImageView()
    
    weak var asset:XPhotoAssetModel!
    {
        didSet
        {
            show()
        }
    }
    
    private var  cellW:CGFloat = (SW-25)/4.0
    private var block:XPhotoChooseAssetBlock?
    
    func doChoose(b:XPhotoChooseAssetBlock)
    {
        block = b
    }


    private func show()
    {
        
        for item in contentView.subviews
        {
            item.removeFromSuperview()
        }

        choose.selected = false
        
        img.contentMode = .ScaleAspectFill
        img.frame = CGRectMake(0, 0, cellW,cellW)
        img.layer.masksToBounds=true
        img.image = asset.image

        contentView.addSubview(img)
        
        choose.frame = CGRectMake(cellW-26-4, cellW-26-4, 26, 26)
        choose.setImage("AGIPC-Checkmark-0@2x.png".image, forState: .Normal)
        choose.setImage("AGIPC-Checkmark-1@2x.png".image, forState: .Selected)
        choose.imageView?.frame = CGRectMake(0, 0, 26, 26)
        choose.addTarget(self, action: #selector(click(_:)), forControlEvents: .TouchUpInside)
        
        contentView.addSubview(choose)
        
    }
    
    func click(sender:UIButton)
    {
        if block?(self.asset) == false {return}
        
        sender.selected = !sender.selected
        sender.bounceAnimation(0.3)
        
    }
    
    deinit
    {
        print("XPhotoChooseCell deinit!!!!!!!!!")
    }
    
}
