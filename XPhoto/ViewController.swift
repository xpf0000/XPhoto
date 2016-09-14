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

//资源库管理类
let assetsLibrary =  ALAssetsLibrary()
var assetGroups:[ALAssetsGroup] = []
var assets:[String:[ALAsset]] = [:]

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let table = UITableView()
    
    
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
        
        
        assetsLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (group, stop) in
            
            print("group: \(group) | stop: \(stop)")
            
            
            if(group != nil)
            {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                
                if group.numberOfAssets() > 0
                {
                    assetGroups.append(group)
                    
                    let name = group.valueForProperty(ALAssetsGroupPropertyName)
                    let url = group.valueForProperty(ALAssetsGroupPropertyURL)
                    let type = group.valueForProperty(ALAssetsGroupPropertyType)
                    let id = group.valueForProperty(ALAssetsGroupPropertyPersistentID) as! String
                    
                    if assets[id] == nil
                    {
                        assets[id] = []
                    }
                    
                    print("name: \(name) | url: \(url) | type: \(type) | id: \(id)")
                    
                }
                
            }
            else
            {
                if (assetGroups.count > 0) {
                    // 把所有的相册储存完毕，可以展示相册列表
                    
                    self.table.reloadData()
                    
                    for item in assetGroups
                    {
                        item.enumerateAssetsWithOptions(.Reverse, usingBlock: { (result, index, stop) in
                            
                            if result != nil
                            {
                            assets[self.getGroupID(item)]?.append(result)
                            }
                            else
                            {
                                print("group遍历完毕 !!!!!!")
                            }
                            
                        })
                    }
                    
                    
                    
                    
                } else {
                    // 没有任何有资源的相册，输出提示
                }
            }
            
            
            
            
            }) { (error) in
                
                print("error: \(error)")
        }
        
        
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
        
        return assetGroups.count
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
        
        let group = assetGroups[indexPath.row]
        
        print(group.posterImage().takeUnretainedValue())
        
        let cg = group.posterImage().takeUnretainedValue() 
        
        let image = UIImageView()
        image.frame = CGRectMake(15, 0, 60.0, 60.0)
        image.image = UIImage(CGImage: cg)
        cell.contentView.addSubview(image)
        
        
        let label = UILabel()
        label.frame = CGRectMake(85.0, 0, SW-85.0, 60.0)
        label.text = getGroupName(assetGroups[indexPath.row])
        cell.contentView.addSubview(label)
        
        cell.accessoryType = .DisclosureIndicator
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let vc = XPhotoChooseVC()
        
        let group = assetGroups[indexPath.row]
        let id = getGroupID(group)
        let title = getGroupName(group)
        
        vc.assets = assets[id]!
        vc.title = title
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    
    func getGroupID(g:ALAssetsGroup)->String
    {
        return g.valueForProperty(ALAssetsGroupPropertyPersistentID) as! String
    }
    
    func getGroupName(g:ALAssetsGroup)->String
    {
        return g.valueForProperty(ALAssetsGroupPropertyName) as! String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        
        
    }


}

