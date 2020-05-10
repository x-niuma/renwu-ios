//
//  MicChatViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/5.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicChatViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "聊天"
    }

    @objc func handleClick() {
        print("clicked")
    }
    
    // 状态栏是否隐藏
     override var prefersStatusBarHidden: Bool {
         return false
     }
     // 状态栏样式
     override var preferredStatusBarStyle: UIStatusBarStyle {
         return .lightContent
     }
     // 状态栏隐藏动画
     override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
         return .fade
     }
}
