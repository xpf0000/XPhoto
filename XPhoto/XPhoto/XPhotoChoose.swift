//
//  XPhotoChoose.swift
//  chengshi
//
//  Created by X on 15/11/26.
//  Copyright © 2015年 XSwiftTemplate. All rights reserved.
//

import UIKit

@objc protocol XPhotoDelegate:NSObjectProtocol{
    //回调方法
    
    optional func XPhotoResult(o:AnyObject?)
    
}

enum XPhotoChooseType: NSInteger{
    case Camera=0
    case PhotoLib=1
}

class XPhotoChoose: UIView,UIGestureRecognizerDelegate {
    
    @IBOutlet var button1: UIButton!
    
    @IBOutlet var button2: UIButton!
    
    @IBOutlet var button3: UIButton!
    
    @IBOutlet var chooseView: UIView!
    
    @IBOutlet var bottom: NSLayoutConstraint!
    
    var block:AnyBlock?  /// 回传 0 拍照 1 选照片
    
    weak var vc:UIViewController?
    var showed=false
    var allowsEdit = false
    var maxNum:UInt = 9
    weak var delegate:XPhotoDelegate?
    
    @IBAction func takePhoto(sender: AnyObject) {
        
        self.removeFromSuperview()
        
        if(!allowsEdit)
        {
            XCamera.Share().delegate = self.delegate
            XCamera.Share().vc = self.vc
            XCamera.Share().block = block
            XCamera.Share().CameraImage()
            
        }
        else
        {
            XCamera.Share().delegate = self.delegate
            XCamera.Share().vc = self.vc
            XCamera.Share().block = block
            XCamera.Share().imagePicker.allowsEditing = true
            XCamera.Share().CameraImage()
        }

        
    }
    
    @IBAction func choose(sender: AnyObject) {
        
        self.removeFromSuperview()
        
        if(!allowsEdit)
        {
            XPhotoLib.Share().delegate = self.delegate
            XPhotoLib.Share().vc = self.vc
            XPhotoLib.Share().block = block
            XPhotoLib.Share().maxNum = maxNum
            XPhotoLib.Share().getPhoto()
        }
        else
        {
            XCamera.Share().vc = self.vc
            XCamera.Share().delegate = self.delegate
            XCamera.Share().block = block
            XCamera.Share().imagePicker.allowsEditing = true
            XCamera.Share().imagePicker.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
            XCamera.Share().CameraImage()
        }
        
    }
    
    @IBAction func cancel(sender: AnyObject) {
        
        self.hide()
        
    }
    
    class func Share() ->XPhotoChoose! {
        
        struct Once {
            static var token:dispatch_once_t = 0
            static var dataCenterObj:XPhotoChoose! = nil
        }
        dispatch_once(&Once.token, {
            Once.dataCenterObj = XPhotoChoose(frame: CGRectMake(0, 0, swidth, sheight))
        })
        return Once.dataCenterObj
    }
    
    
    func initSelf()
    {
        let containerView:UIView=("XPhotoChoose".Nib.instantiateWithOwner(self, options: nil))[0] as! UIView
        
        let newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
        containerView.frame = newFrame
        self.addSubview(containerView)
        
        self.userInteractionEnabled = true
        
        for view in self.chooseView.subviews
        {
            if(view is UIButton)
            {
                view.layer.cornerRadius = 4.0
                view.layer.borderColor = "#D2D2D2".color?.CGColor
                view.layer.borderWidth = 0.5
                view.layer.masksToBounds = true
            }
        }
        
        let recognizer = UITapGestureRecognizer(target: self, action: "hide")
        recognizer.delegate = self
        recognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(recognizer)
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if(touch.view == self.chooseView)
        {
            return false
        }
        
        return true
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initSelf()
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initSelf()
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        super.willMoveToSuperview(newSuperview)
        
        if(newSuperview != nil)
        {
            if(self.showed)
            {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    
                    self.bottom.constant = 0.0
                    
                    self.chooseView.layoutIfNeeded()
                    
                })
            }
            
        }
        else
        {
            self.bottom.constant = -195.0
            self.chooseView.layoutIfNeeded()
        }
    }
    
    override func didMoveToSuperview() {
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.chooseView.layoutIfNeeded()
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.bottom.constant = 0.0
            self.chooseView.layoutIfNeeded()
            
            }) { (finish) -> Void in
                
                self.showed = true
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    
    }
    
    func hide()
    {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            
            self.bottom.constant = -195.0
            
            self.chooseView.layoutIfNeeded()
            
            }) { (finish) -> Void in
                
                self.removeFromSuperview()
                
        }
    }
    

}
