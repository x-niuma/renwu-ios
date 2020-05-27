//
//  MicMeHeader.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/28.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicMeHeader: UIView {
    var vc: MicMeViewController!
    
    lazy var statusbar: UIView = {
        let view = UIView()
        // view.backgroundColor = UIColor.blue
        return view
    }()
    
    lazy var navbar: UIView = {
        let view = UIView()
        // view.backgroundColor = UIColor.green
        return view
    }()
    
    lazy var settingBtn: UIButton = {
        let btn = UIButton()
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "setting-white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.contentMode = .scaleToFill
        btn.addTarget(self, action: #selector(gotoSetting), for: .touchUpInside)
        return btn
    }()
    
    lazy var saomaBtn: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.tintColor = UIColor.white
        btn.setImage(UIImage(named: "saoma-white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        return btn
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        return label
    }()
    
    @objc func makeInitSubviews() {
        self.addSubview(statusbar)
        self.addSubview(navbar)
        navbar.addSubview(settingBtn)
        navbar.addSubview(saomaBtn)
        navbar.addSubview(titleLabel)
    }
    
    @objc func gotoSetting() {
        if (!self.vc.isLogined) {
            micro_task.login(currentVC: self.vc) { (userInfo) in
                micro_task.gotoSetting(currentVC: self.vc)
            }
        } else {
            micro_task.gotoSetting(currentVC: self.vc)
        }
    }
    
    @objc func makeInitLayout() {
        statusbar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().offset(0)
            make.height.equalTo(kStatusbarHeight)
            make.top.equalToSuperview()
        }
        navbar.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
            make.bottom.equalToSuperview()
        }
        settingBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.width.equalTo(20)
            make.height.equalTo(20)
            make.centerY.equalToSuperview()
        }
        saomaBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-42)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
            make.height.equalTo(20)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.makeInitSubviews()
        self.makeInitLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
