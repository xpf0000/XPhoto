//
//  ViewController.swift
//  XPhoto
//
//  Created by X on 16/9/14.
//  Copyright © 2016年 XPhoto. All rights reserved.
//   http://kayosite.com/ios-development-and-detail-of-photo-framework.html
//  http://www.hangge.com/blog/cache/detail_763.html

import UIKit
import AssetsLibrary
import Photos
import PhotosUI

//资源库管理类


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let table = UITableView()
    
    static var maxNum = 9
    
    //保存照片集合
    //var assets = [ALAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 获取当前应用对照片的访问授权状态
        let authorizationStatus = ALAssetsLibrary.authorizationStatus()
        // 如果没有获取访问授权，或者访问授权状态已经被明确禁止，则显示提示语，引导用户开启授权
        if authorizationStatus == .Restricted || authorizationStatus == .Denied
        {
            let dic = NSBundle.mainBundle().infoDictionary
            
            var appName = ""
            
            if let str = dic?["CFBundleDisplayName"] as? String
            {
                appName = str
            }
            else
            {
                if let str = dic?["CFBundleName"] as? String
                {
                    appName = str
                }

            }

            let msg = "请在设备的\"设置-隐私-照片\"选项中，允许\(appName)访问你的手机相册"
            
            let alert = UIAlertView(title: "提示", message: msg, delegate: nil, cancelButtonTitle: "确定")
            
            alert.show()
            
            return
        }
        
        XPhotoHandle.Share.handleFinish { 
            [weak self]()->Void in
            
            self?.table.reloadData()
        }
        XPhotoHandle.Share.handle()
    
        self.automaticallyAdjustsScrollViewInsets = false
        
        table.frame = CGRectMake(0, 0, SW, SH)
        
        let header = UIView()
        header.frame = CGRectMake(0, 0, SW, 64)
        table.tableHeaderView = header
        
        table.delegate = self
        table.dataSource = self
        
        table.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.view.addSubview(table)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return XPhotoHandle.Share.assetGroups.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return 60.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        for item in cell.contentView.subviews
        {
            item.removeFromSuperview()
        }
        
        let model = XPhotoHandle.Share.assetGroups[indexPath.row]
        
        let image = UIImageView()
        image.frame = CGRectMake(15, 0, 60.0, 60.0)
        image.layer.masksToBounds = true
        image.contentMode = .ScaleAspectFill
        cell.contentView.addSubview(image)

        let label = UILabel()
        label.frame = CGRectMake(85.0, 0, SW-85.0, 60.0)
        
        model.imageBlock { 
            [weak self](img)->Void in
            if self == nil {return}
            image.image = img
            
        }
        
        image.image = model.image
        label.text = model.title
        
        cell.contentView.addSubview(label)
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = XPhotoChooseVC()
        let model = XPhotoHandle.Share.assetGroups[indexPath.row]
        vc.title = model.title
        vc.assets = XPhotoHandle.Share.assets[model.id]!
        
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }


}

