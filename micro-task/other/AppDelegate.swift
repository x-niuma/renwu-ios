//
//  AppDelegate.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/4.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
//import TUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = MicTabbarViewController()
        // self.window?.rootViewController = JDAnimationTabBarViewController()
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        
        // AppID 1400363727
        // APPSecrity ed797587b8630eb652abda2d88950095059cadcab36382a67b12f9df17628753
//        TUIKit.sharedInstance()?.setup(withAppId: 1400363727)
        
        return true
    }
}
