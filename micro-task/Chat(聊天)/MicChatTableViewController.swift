//
//  MicChatTableViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/1.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicChatTableViewController: MicWebViewController {
    
    override func viewDidLoad() {
        self.webviewUrl = h5BaseUrl + "/chat"
        self.title = "消息"
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // self.refreshURL()
    }
}
