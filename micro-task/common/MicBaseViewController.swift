//
//  MicBaseViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/16.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import SnapKit

class MicBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initLeftBtn()
    }
    
    /**
     * 不带文字的返回按钮
     */
    @objc func initLeftBtn() {
        let backImg = UIImage.init(named: "arrow_back")?
            .withRenderingMode(.alwaysOriginal)
        
        let customBtn = UIButton()
        customBtn.frame.size = CGSize(width: 30, height: 20)
        customBtn.setImage(backImg, for: .normal)
        customBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -24, bottom: 0, right: 0)
        customBtn.addTarget(self, action: #selector(handleClickLeftBtn), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customBtn)
    }
        
    /**
     * 带文字的返回按钮
     */
    @objc func initLeftTextBtn () {
        let backImg = UIImage.init(named: "arrow_back")?.withRenderingMode(.alwaysOriginal)
        
        let customBtn = UIButton.init(type: .custom)
        customBtn.setImage(backImg, for: .normal)
        customBtn.setTitle("返回", for: .normal)
        customBtn.setTitleColor(fontSecondColor, for: .normal)
        customBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        customBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        customBtn.addTarget(self, action: #selector(handleClickLeftBtn), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: customBtn)
    }
    
    /**
     * 返回上个界面
     */
    @objc func handleClickLeftBtn() {
        self.navigationController?.popViewController(animated: true)
    }
}
