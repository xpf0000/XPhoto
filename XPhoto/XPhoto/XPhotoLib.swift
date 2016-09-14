//
//  XPhotoLib.swift
//  chengshi
//
//  Created by X on 15/11/27.
//  Copyright © 2015年 XSwiftTemplate. All rights reserved.
//

import UIKit

class XPhotoLib: NSObject,AGImagePickerControllerDelegate {

    weak var vc:UIViewController?
    var block:AnyBlock?
    var ipc:AGImagePickerController?
    var maxNum:UInt=9

    var selectAll:AGIPCToolbarItem?
    var cancelItem:AGIPCToolbarItem?
    var finishItem:AGIPCToolbarItem?
    
    let allButton:UIButton = UIButton(type: UIButtonType.Custom)
    let finishButton:UIButton = UIButton(type: UIButtonType.Custom)
    
    let flexible:AGIPCToolbarItem = AGIPCToolbarItem(barButtonItem: UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil), andSelectionBlock: nil)
    weak var delegate:XPhotoDelegate?
    
    class func Share() ->XPhotoLib! {
        
        struct Once {
            static var token:dispatch_once_t = 0
            static var dataCenterObj:XPhotoLib! = nil
        }
        dispatch_once(&Once.token, {
            Once.dataCenterObj = XPhotoLib()
        })
        return Once.dataCenterObj
    }
    
    func allChoose(button:UIButton)
    {
        button.selected = !button.selected
        ipc!.selectAll = button.selected
    }
    
    func cancel()
    {
        ipc!.didFailBlock(nil)
    }
    
    func finish()
    {
        ipc!.finished = true
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if(keyPath == "selectCount")
        {
            finishButton.enabled = ipc!.selectCount>0
        }
        
        if(keyPath == "selectAll")
        {
            allButton.selected = ipc!.selectAll
        }

        
    }

    override init()
    {
        super.init()

        allButton.frame = CGRectMake(10.0, 8.0, 28.0, 28.0)
        allButton.setImageWithAnimation("AGImagePickerController.bundle/AGIPC-Checkmark-0@2x.png".image, forState: UIControlState.Normal)
        allButton.setImageWithAnimation("AGImagePickerController.bundle/AGIPC-Checkmark-1@2x.png".image, forState: UIControlState.Selected)
        
        allButton.addTarget(self, action: #selector(allChoose(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
         selectAll = AGIPCToolbarItem(barButtonItem: UIBarButtonItem(customView: allButton), andSelectionBlock: nil)
        
        
        let cancelButton:UIButton = UIButton(type: UIButtonType.Custom)
        cancelButton.frame = CGRectMake(10.0, 8.0, 40, 28.0)
        cancelButton.setTitle("取消", forState: UIControlState.Normal)
        cancelButton.setTitleColor(blackTXT, forState: UIControlState.Normal)
        
        cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        
        cancelItem = AGIPCToolbarItem(barButtonItem: UIBarButtonItem(customView: cancelButton), andSelectionBlock: nil)
        
        
        finishButton.frame = CGRectMake(10.0, 8.0, 40, 28.0)
        finishButton.setTitle("完成", forState: UIControlState.Normal)
        finishButton.setTitleColor(blackTXT, forState: UIControlState.Normal)
        finishButton.setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Disabled)
        
        finishButton.addTarget(self, action: "finish", forControlEvents: UIControlEvents.TouchUpInside)
        finishButton.enabled = false
        finishItem = AGIPCToolbarItem(barButtonItem: UIBarButtonItem(customView: finishButton), andSelectionBlock: nil)

        
        ipc=AGImagePickerController.sharedInstance(self)
        ipc!.shouldShowSavedPhotosOnTop = false;
        ipc!.shouldChangeStatusBarStyle = true;
        ipc!.maximumNumberOfPhotosToBeSelected = maxNum;
        
        ipc!.navigationBar.setBackgroundImage(UIColor(red: 31.0/255.0, green: 172.0/255.0, blue: 252.0/255.0, alpha: 1.0).image, forBarMetrics:.Default)
        ipc!.navigationBar.titleTextAttributes=[NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0)]
        ipc!.navigationBar.translucent = false
        
        ipc!.addObserver(self, forKeyPath: "selectCount", options: .New, context: nil)
        ipc!.addObserver(self, forKeyPath: "selectAll", options: .New, context: nil)
        
    }
    
    func getPhoto()
    {
        ipc!.maximumNumberOfPhotosToBeSelected = maxNum;
        if(maxNum>1)
        {
            ipc!.toolbarItemsForManagingTheSelection=[selectAll!,flexible,finishItem!,flexible,cancelItem!]
        }
        else
        {
            ipc!.toolbarItemsForManagingTheSelection=[flexible,finishItem!,flexible,cancelItem!]
        }
        
        ipc!.showFirstAssetsController()
        
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: true)
        
        vc?.presentViewController(ipc!, animated: true, completion: { () -> Void in
            
            XPhotoChoose.Share().removeFromSuperview()
            
        })
        
        ipc!.didFailBlock =
            {
                (o)->Void in
                
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
                
                self.vc?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.clean()
                })
        
        }
        
        ipc!.didFinishBlock =
            {
                (o)->Void in
                self.block?(o)
                self.delegate?.XPhotoResult!(o)
                
                UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.Default, animated: true)
                
                self.vc?.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                    self.block?(nil)
                    self.delegate?.XPhotoResult!(nil)
                    
                    self.clean()
                })
                
                
        }
    }
    
    func getPhoto(block:AnyBlock)
    {
        self.block=block
        
        self.getPhoto()
    }
    
    func getPhoto(maxNum:UInt,block:AnyBlock)
    {
        self.block=block
        self.maxNum = maxNum
        
        self.getPhoto()
    }
    
    func agImagePickerController(picker: AGImagePickerController!, didFail error: NSError!) {
        
    }
    
    func agImagePickerController(picker: AGImagePickerController!, didFinishPickingMediaWithInfo info: [AnyObject]!) {
        
    }
    
    func agImagePickerController(picker: AGImagePickerController!, numberOfItemsPerRowForDevice deviceType: AGDeviceType, andInterfaceOrientation interfaceOrientation: UIInterfaceOrientation) -> UInt {
        
        if (deviceType == AGDeviceType.TypeiPad)
        {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation))
            {
                return 11;
            }
            else
            {
                return 8;
            }
        } else {
            if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
                if (480 == swidth) {
                    return 6;
                }
                return 7;
            } else
            {
                return 4;
            }
        }
        
    }
    
    func agImagePickerController(picker: AGImagePickerController!, shouldDisplaySelectionInformationInSelectionMode selectionMode: AGImagePickerControllerSelectionMode) -> Bool {
        
        return (selectionMode == AGImagePickerControllerSelectionMode.Single ? false : true);
    }
    
    func agImagePickerController(picker: AGImagePickerController!, shouldShowToolbarForManagingTheSelectionInSelectionMode selectionMode: AGImagePickerControllerSelectionMode) -> Bool {
        
        
        return true;
        //return (selectionMode == AGImagePickerControllerSelectionMode.Single ? false : true);
        
    }
    
    func selectionBehaviorInSingleSelectionModeForAGImagePickerController(picker: AGImagePickerController!) -> AGImagePickerControllerSelectionBehaviorType {
        
        return AGImagePickerControllerSelectionBehaviorType.Radio
    }
    
    func clean()
    {
        self.delegate = nil
        self.vc = nil
        self.block = nil
        maxNum=9
        ipc!.shouldShowSavedPhotosOnTop = false;
        ipc!.shouldChangeStatusBarStyle = true;
        ipc!.maximumNumberOfPhotosToBeSelected = maxNum;
        ipc!.finished = false
        allButton.selected = false
    }
    
}
