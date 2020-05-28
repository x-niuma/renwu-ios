//
//  MicLoginForm.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/28.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicLoginForm: UIView {
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
        self.addSubview(passwordField)
    }

    private func makeInitLayout() {
        accountField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalToSuperview()
        }
        passwordField.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(44)
            make.top.equalTo(accountField.snp.bottom).offset(20)
        }
    }
}
