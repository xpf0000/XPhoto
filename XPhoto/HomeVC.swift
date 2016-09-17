//
//  HomeVC.swift
//  XPhoto
//
//  Created by 徐鹏飞 on 16/9/17.
//  Copyright © 2016年 XPhoto. All rights reserved.
//

import UIKit

class HomeVC: UIViewController {

    
    @IBAction func click(sender: UIButton)
    {
        XPhotoUseVersion7 = false
        let picker = XPhotoPicker(allowsEditing: false)
        picker.maxNum = 9
        picker.getPhoto(self) { (res) in
            
            
            print(res)
            
            
        }
        
    }
    
    
    @IBAction func alClick(sender: AnyObject) {
        
        XPhotoUseVersion7 = true
        let picker = XPhotoPicker(allowsEditing: false)
        picker.maxNum = 9
        picker.getPhoto(self) { (res) in
            
            
            print(res)
            
            
        }

        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
