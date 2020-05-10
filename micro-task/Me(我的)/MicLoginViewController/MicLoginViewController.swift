//
//  MicLoginViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/10.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Alamofire

struct UserInfoRes: Codable {
    var data: UserInfoData?
    var errCode: String?
    var retCode: String?
}

struct UserInfoData: Codable {
    var avatar: String?
    var token: String?
    var id: Int?
    var nickname: String?
    var gender: Int?
    var mobile: String?
    var email: String?
    var create_time:  String?
    var login_time: String?
    var college: String?
    var words: String?
    var residence: String?
    var background: String?
}

class MicLoginViewController: UIViewController {
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var accountField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginSwitch: UIButton! // 切换按钮(切换登录或者注册)
    @IBOutlet weak var switchTip: UILabel! // 提示
    
    var loginCb:((_ userInfo: MicPerson)->Void)?
    
    var isLogin: Bool = true; // 表示是否为登录, 值为false时, 表示注册帐号
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        loginSwitch.addTarget(self, action: #selector(handleSwitch), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.handleModeChange()
    }
    
    // 设置提交按钮的状态
    func handleModeChange() {
        if (self.isLogin) {
            self.submitBtn.setTitle("立即登录", for: .normal)
            self.loginSwitch.setTitle("注册", for: .normal)
            self.switchTip.text = "没有账户？"
        } else {
            self.submitBtn.setTitle("立即注册", for: .normal)
            self.loginSwitch.setTitle("登录", for: .normal)
            self.switchTip.text = "已有账户？"
        }
    }
    
    // 点击切换按钮
    @objc func handleSwitch() {
        self.isLogin = !self.isLogin
        self.handleModeChange()
    }
    
    // 点击提交按钮
    @objc func handleSubmit() {
        self.doLogin()
    }
    
    // 存储用户信息
    func saveUserInfo() {}
    
    // 登录方法
    @objc func doLogin() {
        let params = [
            "mobile": self.accountField.text,
            "password": self.passwordField.text
        ]
        
        AF.request(self.isLogin ? loginUrl : registerUrl, method: .post, parameters: params).responseJSON { (resJson) in
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
}
