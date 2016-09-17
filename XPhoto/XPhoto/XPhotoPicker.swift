//
//  XPhotoPicker.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/17.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit

class XPhotoPicker: UIView,UIActionSheetDelegate {
    
    private weak var pushVC:UIViewController!
    private var block:XPhotoResultBlock?
    
    var maxNum = 9
    {
        didSet
        {
            XPhotoLibVC.maxNum = maxNum
        }
    }
    
    var allowsEditing = false
    {
        didSet
        {
                
        }
    }
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(allowsEditing:Bool)
    {
        super.init(frame: CGRectZero)
        
        self.allowsEditing = allowsEditing
        
    }
    
    func getPhoto(vc:UIViewController,result:XPhotoResultBlock)
    {
        XPhotoHandle.Share.handle()
        
        pushVC = vc
        block = result
        
        UIApplication.sharedApplication().keyWindow?.addSubview(self)
        
        let sheet=UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "取消", destructiveButtonTitle: nil)
        
        sheet.addButtonWithTitle("拍照")
        sheet.addButtonWithTitle("从手机相册选择")
        
        sheet.actionSheetStyle = UIActionSheetStyle.BlackTranslucent;
        sheet.showInView(UIApplication.sharedApplication().keyWindow!)

    }
    
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == 0
        {
            self.clean()
        }
        
        if(buttonIndex == 1)
        {
            let c = XCamera()
            c.canEdit = allowsEditing
            c.CameraImage(pushVC, block: {[weak self] (img) in
                if self == nil {return}
                
                let model = XPhotoAssetModel()
                model.image=img
                
                self?.block?([model])

                self?.clean()
                
            })
            
            
        }
        else if(buttonIndex == 2)
        {
            if self.allowsEditing
            {
                let c = XCamera()
                c.canEdit = true
                c.imagePicker.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
                c.CameraImage(pushVC, block: {[weak self] (img) in
                    if self == nil {return}
                    
                    let model = XPhotoAssetModel()
                    model.image=img
                    
                    self?.block?([model])
                    
                    self?.clean()
                    
                    })

            }
            else
            {
                let vc = XPhotoLibVC()
                vc.block = block
                let nv = UINavigationController(rootViewController: vc)
                
                pushVC.presentViewController(nv, animated: true, completion: {
                    
                })
                
                
            }
            
            
        }
        
        
        
    }
    
    func clean()
    {
        self.removeFromSuperview()
    }
    
    deinit
    {
    }

}
