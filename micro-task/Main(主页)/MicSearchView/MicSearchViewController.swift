//
//  MicSearchViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/17.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicSearchViewController: MicBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "搜索"
    }
}
