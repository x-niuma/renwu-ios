//
//  MicMeNavibar.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/17.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let StateBar_Height = UIApplication.shared.statusBarFrame.height
let CustomHeight : CGFloat = 44

class MicMeNavibar: UIView {
    var leftBtn: UIButton!
    var saomaBtn: UIButton!
    var titleLabel: UILabel!
    var settingBtn: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        self.backgroundColor = UIColor.red
        
        // 设置按钮
        settingBtn = UIButton()
        settingBtn.setImage(UIImage(named: "setting-white"), for: .normal)
        settingBtn.contentMode = .scaleToFill
        self.addSubview(settingBtn)
        settingBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        // 扫码按钮
        saomaBtn = UIButton()
        self.addSubview(saomaBtn)
        saomaBtn.setImage(UIImage(named: "saoma-white"), for: .normal)
        saomaBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-42)
            make.bottom.equalToSuperview().offset(-8)
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        
        // 标题
        self.titleLabel = UILabel.init(frame: CGRect.init(x: Screen_Width/2-50, y: StateBar_Height+10, width: 100, height: CustomHeight))
        // self.titleLabel.text = "测试标题"
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: 15)
        self.titleLabel.textColor = UIColor.white
        self.addSubview(self.titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
