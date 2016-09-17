//
//  MRZoomScrollView.swift
//  swiftTest
//
//  Created by X on 15/3/16.
//  Copyright (c) 2015年 swiftTest. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@objc protocol XZoomImageViewDelegate:NSObjectProtocol{
    //回调方法
    optional func XZoomImageViewTapClick()
}

class XZoomImageView:UIScrollView,UIScrollViewDelegate
{
    private var imageView:UIImageView?
    private var scroll:CGFloat?
    private var wh:CGFloat=0.0
    weak var tapDelegate:XZoomImageViewDelegate?
    
    var image:UIImage?
    {
        didSet
        {
            imageView?.image = image
            
            self.fixImage()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initSelf()
        
    }
    
    func singleTap()
    {
        tapDelegate?.XZoomImageViewTapClick?()
    }
    
    func initSelf()
    {
        self.delegate=self
        self.maximumZoomScale = 2.0;
        self.minimumZoomScale = 1.0;
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.userInteractionEnabled=true;
        self.scrollEnabled = false
        
        let singleTapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(singleTap))
        singleTapGestureRecognizer.numberOfTapsRequired=1
        self.addGestureRecognizer(singleTapGestureRecognizer)
        
        let doubleTapGesture=UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired=2
        self.addGestureRecognizer(doubleTapGesture)
        
        singleTapGestureRecognizer.requireGestureRecognizerToFail(doubleTapGesture)
        
        scroll=0.0
        
        imageView=UIImageView(frame: CGRectZero)
        imageView!.clipsToBounds = true
        imageView!.layer.masksToBounds = true
        imageView!.frame=CGRectMake(0, 0, SW,SW*0.75)
        imageView!.center = CGPointMake(SW/2, SH/2);
        imageView!.contentMode = .ScaleAspectFit
        
        self.addSubview(imageView!)

    }
    
    func handleDoubleTap(gesture:UIGestureRecognizer)
    {
        scroll=scroll==0.0 ? 2.0 : 0.0
        self.setZoomScale(scroll!, animated: true)
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func fixImage()
    {
        wh = imageView!.image!.size.height / imageView!.image!.size.width
        
        let image = imageView!.image
        let rect = AVMakeRectWithAspectRatioInsideRect(imageView!.image!.size, CGRectMake(0, 0, SW, SH))
        
        imageView!.image = nil
        imageView!.frame=rect
        imageView!.center = CGPointMake(SW/2, SH/2);
        imageView!.contentMode = .ScaleToFill
        
        imageView!.image = image
    }
    
    func scrollViewDidZoom(scrollView: UIScrollView)
    {
        if(wh<1)
        {
            imageView?.center.y = SH/2
        }
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat)
    {
        if scale > 1.0
        {
            self.scrollEnabled = true
        }
        else
        {
            self.scrollEnabled = false
        }

    }
    
    deinit
    {
        imageView=nil
        self.delegate=nil
        self.scroll=nil
    }
    
}
