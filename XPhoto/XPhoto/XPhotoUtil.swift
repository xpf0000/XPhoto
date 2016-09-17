//
//  XPhotoUtil.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/16.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit
import AssetsLibrary

typealias XPhotoResultBlock = ([XPhotoAssetModel])->Void
typealias XPhotoChooseAssetBlock = (XPhotoAssetModel)->Bool
typealias XPhotoImageBlock = (UIImage?)->Void
typealias XPhotoFinishBlock = ()->Void
typealias XPhotoAllChooseBlock = (Bool)->Void

var XPhotoUseVersion7 = false



extension String{
    
    func fileExistsInBundle()->Bool
    {
        let filePath=NSBundle.mainBundle().pathForResource(self, ofType:"")
        if(filePath == nil)
        {
            return false
        }
        
        let fileManager=NSFileManager.defaultManager()
        if(fileManager.fileExistsAtPath(filePath!))
        {
            return true
        }
        else
        {
            return false
        }
        
    }
    
    func fileExistsInPath()->Bool
    {
        let fileManager=NSFileManager.defaultManager()
        if(fileManager.fileExistsAtPath(self))
        {
            return true
        }
        else
        {
            return false
        }
        
    }
    
    var data:NSData?
    {
        return self.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    var path:String
    {
        var str:String?
        str=NSBundle.mainBundle().pathForResource(self, ofType: nil)
        str=(str==nil) ? "" : str
        return str!
    }
    
    var image:UIImage?
    {
        var image:UIImage?
        image = UIImage(contentsOfFile: self.path)
        
        if(image != nil)
        {
            return image
        }
        
        image = UIImage(contentsOfFile: self)
        
        if(image != nil)
        {
            return image
        }
        
        return image
    }
    
}



extension UIView
{
    
    func bounceAnimation(dur:NSTimeInterval)
    {
        let  animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.duration = dur;
        
        animation.removedOnCompletion = false;
        
        animation.fillMode = kCAFillModeForwards;
        
        var values : Array<AnyObject> = []
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(1.26, 1.26, 1.26)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(0.9, 0.9, 0.9)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animation.values = values;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //animation.delegate = delegate
        self.layer.addAnimation(animation, forKey: nil)
        
    }
    
    
    func bounceAnimation1(dur:NSTimeInterval)
    {
        let  animation = CAKeyframeAnimation(keyPath: "transform")
        
        animation.duration = dur;
        
        animation.removedOnCompletion = false;
        
        animation.fillMode = kCAFillModeForwards;
        
        var values : Array<AnyObject> = []
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(0.4, 0.4, 0.4)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(1.26, 1.26, 1.26)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(0.8, 0.8, 0.8)))
        values.append(NSValue(CATransform3D: CATransform3DMakeScale(1.0, 1.0, 1.0)))
        animation.values = values;
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        //animation.delegate = delegate
        self.layer.addAnimation(animation, forKey: nil)
        
    }
    
}



extension UIColor
{
    var image:UIImage{
        
        let rect=CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, self.CGColor);
        CGContextFillRect(context, rect);
        let theImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return theImage
        
    }
}

