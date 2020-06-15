//
//  MicLoginForm.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/28.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicLoginForm: UIView {
    lazy var accountField: MicTextField = {
        let v = MicTextField()
        v.attributedPlaceholder = NSAttributedString.init(
            string:"电子邮箱",
            attributes: [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize:13),
                NSAttributedString.Key.foregroundColor:UIColor.hex("#cccccc"),
            ]
        )
        return v
    }()
    
    lazy var passwordField: MicTextField = {
        let v = MicTextField()
        v.placeholder = "登录密码"
        v.isSecureTextEntry = true
        v.attributedPlaceholder = NSAttributedString.init(
            string:"登录密码",
            attributes: [
                NSAttributedString.Key.font:UIFont.systemFont(ofSize:13),
                NSAttributedString.Key.foregroundColor:UIColor.hex("#cccccc"),
            ]
        )
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
