//
//  MicTabbarViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/4.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

let primaryColor: UIColor = UIColor.init(red: 156/255.0, green: 39/255.0, blue: 176/255.0, alpha: 1);


class MicTabbarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
        addChildControllers(childVc: MicHomeViewController(), title: "首页", image: "home-o", selectedImage: "home")
        addChildControllers(childVc: MicChatTableViewController(), title: "消息", image: "message-o", selectedImage: "message")
        addChildControllers(childVc: MicNiurenViewController(), title: "榜单", image: "niuren-o", selectedImage: "niuren")
        addChildControllers(childVc: MicMeViewController(), title: "我的", image: "user-o", selectedImage: "user")
        
        // 设置激活色
        self.tabBar.tintColor = rgbaColor(r: 19, g: 34, b: 122)
    }
    
    func addWelcome() {
        addChildControllers(childVc: MicHomeViewController(), title: "首页", image: "home-o", selectedImage: "home")
    }
    
    func addChildControllers(childVc: UIViewController, title: String, image: String, selectedImage: String) {
        let rootVC = MicNavigationViewController(rootViewController: childVc)
        rootVC.navigationItem.title = title
        rootVC.tabBarItem.title = title
        rootVC.tabBarItem.image = UIImage(named: image)?.withRenderingMode(.alwaysOriginal)
        rootVC.tabBarItem.selectedImage = UIImage(named: selectedImage)?.withRenderingMode(.alwaysOriginal)
        self.addChild(rootVC)
    }
}


extension MicTabbarViewController: UITabBarControllerDelegate {
    // 可以拿到当前的控制器
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        viewController.tabBarItem.badgeValue = nil;
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            //             print(index)
        }
    }
}
