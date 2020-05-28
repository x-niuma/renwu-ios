//
//  MicRigsterForm.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/28.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicRigsterForm: UIView {
    lazy var accountField: UITextField = {
       let v = UITextField()
        v.backgroundColor = .white
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        v.placeholder = "电子邮箱"
        return v
    }()

    lazy var passwordField: UITextField = {
       let v = UITextField()
        v.backgroundColor = .white
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        v.placeholder = "登录密码"
        return v
    }()
    
    lazy var codeField: UITextField = {
        let v = UITextField()
        v.backgroundColor = .white
        v.layer.cornerRadius = 4
        v.layer.masksToBounds = true
        v.placeholder = "验证码"
        return v
    }()
    
    lazy var codeBtn: UIButton = {
        let v = UIButton()
        v.backgroundColor = .white
        v.layer.cornerRadius = 2
        v.layer.masksToBounds = true
        v.setTitle("获取验证码", for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        v.setTitleColor(UIColor.hex("#333333"), for: .normal)
        v.layer.borderColor = UIColor.hex("#333333").cgColor
        v.layer.borderWidth = 0.5
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.hex("#f5f5f5")
        self.makeInitSubviews()
        self.makeInitLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func makeInitSubviews() {
        self.addSubview(accountField)
        self.addSubview(codeField)
        self.addSubview(passwordField)
        self.addSubview(codeBtn)
    }

    private func makeInitLayout() {
        accountField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview()
        }
        codeField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(accountField.snp.bottom).offset(20)
        }
        passwordField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(codeField.snp.bottom).offset(20)
        }
        codeBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
            make.width.equalTo(68)
            make.centerY.equalTo(accountField.snp.centerY)
        }
    }
}

