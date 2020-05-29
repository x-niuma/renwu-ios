//
//  MicLogin2ViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/28.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON

class MicLogin2ViewController: UIViewController {
    var loginCb:((_ userInfo: MicPerson)->Void)? // 登录回调
    var isLogin: Bool = true; // 表示是否为登录, 值为false时, 表示注册帐号
    
    lazy var loginForm: MicLoginForm = {
        return MicLoginForm()
    }()
    
    lazy var registerForm: MicRigsterForm = {
        return MicRigsterForm()
    }()
    
    lazy var submitBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitleColor(UIColor.white, for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        v.tintColor = UIColor.white
        v.backgroundColor = UIColor.hex("#615963")
        v.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return v
    }()
    
    lazy var switchBtn: UIButton = {
        let v = UIButton(type: .custom)
        v.setTitleColor(UIColor.hex("#615963"), for: .normal)
        v.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        v.addTarget(self, action: #selector(handleSwitch), for: .touchUpInside)
        return v
    }()
    
    lazy var switchTip: UILabel = {
        let v = UILabel()
        v.textColor = UIColor.hex("#cccccc")
        v.font = UIFont.systemFont(ofSize: 12)
        return v
    }()
    
    @objc func handleSubmit() {
        if (!self.loginForm.isHidden) {
            let email = self.loginForm.accountField.text
            let password = self.loginForm.passwordField.text
            if ((email != nil) && (password != nil)) {
                doLogin(email: email!, password: password!)
            }
        } else {
            let email = self.registerForm.accountField.text
            let password = self.registerForm.passwordField.text
            let code = self.registerForm.accountField.text
            if ((email != nil) && (password != nil) && (code != nil)) {
                doLogin(email: email!, password: password!, code: code!)
            }
        }
    }
    
    // 获取注册验证码
    func doGetCode(email: String) {
        class Data: HandyJSON {
            required init() {}
        }
        AF.request(getEmailCodeUrl, method: .get).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<Data>.deserialize(from: _value) {
                    if (_res.retCode == "0") {
                        print("ddddd")
                    }
                }
            }
        }
    }
    
    // 登录方法
    func doLogin(email: String, password: String, code: String = "") {
        let params = [ "email": email, "password": password, "code": code]
        let isLogin = !self.loginForm.isHidden
        
        AF.request(isLogin ? loginUrl : registerUrl, method: .post, parameters: params).responseJSON { (resJson) in
            if let resData = resJson.data {
                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(UserInfoRes.self, from: resData)
                    if (model.retCode == "0") {
                        let userInfo = MicPerson()
                        userInfo.avatar = model.data?.avatar
                        userInfo.nickname = model.data?.nickname
                        userInfo.words = model.data?.words
                        userInfo.mobile = model.data?.mobile
                        userInfo.token = model.data?.token
                        
                        let data = try NSKeyedArchiver.archivedData(withRootObject: userInfo, requiringSecureCoding: true)
                        
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(data, forKey: "userInfo")
                        userDefaults.synchronize()
                        
                        self.dismiss(animated: true, completion: nil)
                        print("登录成功")
                        self.loginCb?(userInfo)
                    } else {
                        print("登录失败: \(model)")
                    }
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func handleSwitch() {
        if (loginForm.isHidden) {
            switchLogin()
        } else {
            switchRegister()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.hex("#f5f5f5")
        makeInitSubviews()
        makeInitLayout()
        switchLogin()
    }
    
    private func makeInitSubviews() {
        view.addSubview(loginForm)
        view.addSubview(registerForm)
        view.addSubview(submitBtn)
        view.addSubview(switchBtn)
        view.addSubview(switchTip)
    }
    
    func switchLogin() {
        registerForm.isHidden = true
        loginForm.isHidden = false
        switchTip.text = "没有账户？"
        switchBtn.setTitle("注册", for: .normal)
        submitBtn.setTitle("立即登录", for: .normal)
        submitBtn.snp.removeConstraints()
        submitBtn.snp.makeConstraints { (make) in
            make.left.equalTo(loginForm.snp.left)
            make.right.equalTo(loginForm.snp.right)
            make.height.equalTo(44)
            make.top.equalTo(loginForm.snp.bottom).offset(0)
        }
    }
    
    func switchRegister() {
        registerForm.isHidden = false
        loginForm.isHidden = true
        switchTip.text = "已有账户？"
        switchBtn.setTitle("登录", for: .normal)
        submitBtn.setTitle("立即注册", for: .normal)
        submitBtn.snp.removeConstraints()
        submitBtn.snp.makeConstraints { (make) in
            make.left.equalTo(registerForm.snp.left)
            make.right.equalTo(registerForm.snp.right)
            make.height.equalTo(44)
            make.top.equalTo(registerForm.snp.bottom).offset(0)
        }
    }
    
    private func makeInitLayout() {
        loginForm.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(40)
            make.height.equalTo(128)
        }
        registerForm.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(40)
            make.height.equalTo(192)
        }
        switchBtn.snp.makeConstraints { (make) in
            make.right.equalTo(loginForm.snp.right)
            make.top.equalTo(submitBtn.snp.bottom).offset(10)
        }
        switchTip.snp.makeConstraints { (make) in
            make.right.equalTo(switchBtn.snp.left).offset(-2)
            make.centerY.equalTo(switchBtn.snp.centerY)
        }
    }
}
