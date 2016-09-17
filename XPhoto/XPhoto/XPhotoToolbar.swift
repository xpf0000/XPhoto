//
//  XPhotoToolbar.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/16.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit


class XPhotoToolbar: UIToolbar {

    let all = UIButton(type: .Custom)
    private let finishBtn = UIButton(type: .Custom)
    let cancle = UIButton(type: .Custom)
    private let num = UILabel()
    
    var singleChoose = false
    
    private var cancleBlock:XPhotoFinishBlock?
    private var finishBlock:XPhotoFinishBlock?
    private var allChooseBlock:XPhotoAllChooseBlock?
    
    func    block(allChoose:XPhotoAllChooseBlock,cancle:XPhotoFinishBlock,finish:XPhotoFinishBlock)
    {
        allChooseBlock=allChoose
        cancleBlock=cancle
        finishBlock=finish
    }
    
    
    var count = 0
    {
        didSet
        {
            finishBtn.enabled = count > 0
            num.hidden = !(count > 0)
            num.text = "\(count)"
            if(!num.hidden)
            {
                num.bounceAnimation1(0.4)
            }
            
        }
    }
    
    func initSelf()
    {
        
        all.frame = CGRectMake(0, 0, 28, 28)
        all.setImage("Checkmark-0@2x.png".image, forState: .Normal)
        all.setImage("Checkmark-1@2x.png".image, forState: .Selected)
        all.imageView?.frame = CGRectMake(0, 0, 28, 28)
        all.addTarget(self, action: #selector(click(_:)), forControlEvents: .TouchUpInside)
        let item = UIBarButtonItem(customView: all)
        let space = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        
        
        cancle.frame = CGRectMake(0, 0, 50, 26)
        cancle.titleLabel?.font = UIFont.systemFontOfSize(17.0)
        cancle.setTitle("取消", forState: .Normal)
        cancle.setTitleColor(UIColor.blackColor(), forState: .Normal)
        cancle.addTarget(self, action: #selector(click(_:)), forControlEvents: .TouchUpInside)
        let item1 = UIBarButtonItem(customView: cancle)
        
        
        let orangeColor = UIColor(red: 253.0/255.0, green: 122.0/255.0, blue: 0.0, alpha: 1.0)
        let orangeColor1 = UIColor(red: 253.0/255.0, green: 122.0/255.0, blue: 0.0, alpha: 0.5)
        
        finishBtn.frame = CGRectMake(0, 0, 60, 26)
        
        
        num.frame = CGRectMake(0, 3, 20, 20)
        num.textAlignment = .Center
        num.text = "1"
        num.font = UIFont.systemFontOfSize(13.0)
        num.textColor = UIColor.whiteColor()
        num.backgroundColor = orangeColor
        num.layer.masksToBounds=true
        num.layer.cornerRadius = 10.0
        
        finishBtn.addSubview(num)
        
        finishBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 22, 0.0, 0.0)
        
        finishBtn.setTitle("完成", forState: .Normal)
        finishBtn.titleLabel?.font = UIFont.systemFontOfSize(16.0)
        finishBtn.setTitleColor(orangeColor1, forState: .Disabled)
        finishBtn.setTitleColor(orangeColor, forState: .Normal)
        
        finishBtn.addTarget(self, action: #selector(click(_:)), forControlEvents: .TouchUpInside)
        
        
        let item2 = UIBarButtonItem(customView: finishBtn)
        
        num.hidden = true
        finishBtn.enabled = false
        
        setItems([item,space,item1,space,item2], animated: true)
        
        XPhotoHandle.Share.chooseChange { [weak self]()->Void in
            if self == nil {return}
            self?.count = XPhotoHandle.Share.chooseArr.count
        }
        
        count = XPhotoHandle.Share.chooseArr.count
        
    }
    
    func click(sender:UIButton)
    {
        if sender == all
        {
            if singleChoose && !sender.selected
            {
                if XPhotoHandle.Share.chooseArr.count == XPhotoLibVC.maxNum
                {
                    return
                }
            }
            
            sender.selected = !sender.selected
            sender.bounceAnimation(0.3)
            allChooseBlock?(sender.selected)
        }
        else if sender == cancle
        {
            cancleBlock?()
        }
        else
        {
            finishBlock?()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSelf()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initSelf()
    }
    
    deinit
    {
    }
    
}
