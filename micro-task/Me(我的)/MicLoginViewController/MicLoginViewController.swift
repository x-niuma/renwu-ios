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

class MicLoginViewController: UIViewController {
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
    
    @objc func validateCommon(email: String, password: String, code: String? = nil) -> Bool {
        if (email.count == 0) {
            showTip(message: "请填写邮箱", view: view)
            return false
        }
        if (!validateEmail(email: email)) {
            showTip(message: "邮箱格式不正确", view: view)
            return false
        }
        if (code != nil) {
            if (code!.count == 0) {
                showTip(message: "请填写验证码", view: view)
                return false
            }
            print(code!)
            if (!validateCode(code: code!)) {
                showTip(message: "验证码格式不正确", view: view)
                return false
            }
        }
        if (password.count == 0) {
            showTip(message: "请填写密码", view: view)
            return false
        }
        if (!validatePwd(password: password)) {
            showTip(message: "密码格式不正确", view: view)
            return false
        }
        return true
    }
    
    @objc func handleSubmit() {
        let email = self.loginForm.accountField.text!
        let password = self.loginForm.passwordField.text!
        if (!self.loginForm.isHidden) {
            if (validateCommon(email: email, password: password)) {
                doLogin(email: email, password: password)
            }
        } else {
            let email = self.registerForm.accountField.text!
            let password = self.registerForm.passwordField.text!
            let code = self.registerForm.codeField.text!
            if (validateCommon(email: email, password: password, code: code)) {
                doLogin(email: email, password: password, code: code)
            }
        }
    }
    
    // 验证码匹配
    func validateCode(code: String) -> Bool {
        if code.count == 0 {
            return false
        }
        let regexp = "^[0-9]{4}$"
        let tester:NSPredicate = NSPredicate(format: "SELF MATCHES %@", regexp)
        return tester.evaluate(with: code)
    }
    
    // 邮箱匹配
    func validateEmail(email: String) -> Bool {
        if email.count == 0 {
            return false
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest:NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    // 密码匹配
    func validatePwd(password: String) -> Bool {
        if password.count == 0 {
            return false
        }
        let regexp = "^[A-Za-z0-9_]{6,10}$"
        let tester:NSPredicate = NSPredicate(format: "SELF MATCHES %@", regexp)
        return tester.evaluate(with: password)
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
    
    // 登录成功
    func onLoginSuccess(micUser: MicUser) {
        let userInfo = MicPerson()
        userInfo.avatar = micUser.avatar
        userInfo.nickname = micUser.nickname
        userInfo.words = micUser.words
        userInfo.mobile = micUser.mobile
        userInfo.token = micUser.token
        userInfo.email = micUser.email
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: userInfo, requiringSecureCoding: true)
            let userDefaults = UserDefaults.standard
            userDefaults.set(data, forKey: "userInfo")
            userDefaults.synchronize()
            self.dismiss(animated: true, completion: nil)
            self.loginCb?(userInfo)
        } catch {
            micro_task.showTip(message: "登录失败", view: self.view)
            print("登录失败:", error)
        }
    }
    
    // 登录方法
    func doLogin(email: String, password: String, code: String = "") {
        let params = [ "email": email, "password": password, "code": code]
        let isLogin = !self.loginForm.isHidden
        let indictor = micro_task.showLoading(view: view)
        AF.request(isLogin ? loginUrl : registerUrl, method: .post, parameters: params).responseString { (response) in
            indictor.hide(animated: true)
            if let _value = response.value {
                if let res = MicBaseResponse<MicUser>.deserialize(from: _value) {
                    if(res.retCode == "0") {
                        micro_task.showTip(message: "登录成功", view: self.view)
                        self.onLoginSuccess(micUser: res.data!)
                    } else {
                        micro_task.showTip(message: res.errMsg!, view: self.view)
                    }
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
