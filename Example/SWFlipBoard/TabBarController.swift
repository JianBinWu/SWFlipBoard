//
//  TabBarController.swift
//  SWFlipBoard_Example
//
//  Created by Apple on 2022/11/14.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let arr = [
        ["className": "HomeViewController", "title": "首页", "imageName": "logo_home"],
        ["className": "CultureViewController", "title": "文化", "imageName": "logo_culture"],
        ["className": "FollowingViewController", "title": "关注", "imageName": "logo_add"],
        ["className": "LivingViewController", "title": "生活", "imageName": "logo_living"],
        ["className": "UserCenterViewController", "title": "我的", "imageName": "logo_user"]
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    func initUI() {
        //config tabBar Styple
        tabBar.tintColor = .red
        tabBar.barTintColor = .white
        //add child viewController
        addVCToTabBarVC()
    }
    
    func addVCToTabBarVC() {
        for item in arr {
            let className = item["className"]!
            let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            let cls = NSClassFromString(nameSpace + "." + className) as! UIViewController.Type
            let vc = cls.init()
            let nav = UINavigationController(rootViewController: vc)
            
            let title = item["title"]!
            nav.tabBarItem.image = UIImage(named: "\(item["imageName"]!)")?.withRenderingMode(.alwaysOriginal)
            nav.tabBarItem.selectedImage = UIImage(named: "\(item["imageName"]!)_pressed")?.withRenderingMode(.alwaysOriginal)
            if title != "关注" {
                nav.tabBarItem.title = title
            } else {
                nav.tabBarItem.image = UIImage(named: item["imageName"]!)?.withRenderingMode(.alwaysOriginal)
                nav.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            }
            addChildViewController(nav)
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        var selectItem = tabBar.items!.firstIndex(of: item)!
        if selectItem == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "flipToTop"), object: nil)
        }
    }
}
