//
//  MicMeUserCard.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/30.
//  Copyright © 2020 airtim. All rights reserved.
//  用户信息卡片

import UIKit
import Alamofire
import HandyJSON

class MicMeUserCard: UIView {
    var userCardH = 170
    let marginTop: CGFloat = 20.0
    let headerViewH = 160 + kNavBarAndStatusBarHeight
    let mainMenuH = 50
    var userInfo: MicPerson? = nil
    var assetInfo: MicUserAssets? = nil
    var vc: MicMeViewController!
    let menuTitle = [
        ["title": "关注", "needLogin": true, "value": 0],
        ["title": "收藏", "needLogin": true, "value": 0],
        ["title": "点赞", "needLogin": true, "value": 0],
        ["title": "积分", "needLogin": true, "value": 0],
    ]
    var navColor: UIColor!
    let userAvatarW = 60
    var bgColor: UIColor!
    var getUserInfo: (() -> Void)!
    var checkinState = 0
    
    lazy var userCard: UIView = {
        let userCard = UIView()
        userCard.backgroundColor = UIColor.hex("#ffffff")
        userCard.layer.cornerRadius = 6
        userCard.layer.masksToBounds = true
        return userCard
    }()
    
    lazy var userAvatar: UIImageView = {
        let m = UIImageView()
        m.layer.cornerRadius = CGFloat(userAvatarW / 2)
        m.layer.masksToBounds = true
        m.kf.setImage(with: URL(string: kDefaultAvatar))
        m.contentMode = .scaleAspectFill
        return m
    }()
    
    lazy var nickname: UILabel = {
        let l = UILabel()
        l.font = UIFont.systemFont(ofSize: 16)
        l.textColor = UIColor.hex("#000000")
        l.isHidden = true
        return l
    }()
    
    lazy var mobile: UILabel = {
        let l = UILabel()
        l.isHidden = true
        l.font = UIFont.systemFont(ofSize: 12)
        l.textColor = UIColor.hex("#8a8a8a")
        return l
    }()
    
    lazy var gridient: RadianGridient = {
        let view = RadianGridient()
        view.frame = CGRect(x: 0, y: 0, width: Int(kScreenWidth), height: Int(headerViewH))
        view.setGradient(UIColor.hex("#615963"), and: UIColor.hex("#615963"), widthSize: 0)
        return view
    }()
    
    lazy var tableNav: MicMeHeader = {
        let header = MicMeHeader.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kNavBarAndStatusBarHeight))
        header.backgroundColor = navColor
        header.vc = self.vc
        return header
    }()
    
    lazy var checkin: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.setTitle("立即签到", for: .normal)
        btn.setTitleColor(UIColor.hex("#8a8a8a"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        btn.layer.borderColor = UIColor.hex("#8a8a8a").cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(handleClickCheckin), for: .touchUpInside)
        return btn
    }()
    
    lazy var loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("登录/注册", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(UIColor.hex("#8a8a8a"), for: .normal)
        btn.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return btn
    }()
    
    lazy var menu: [UIButton] = {
        var menu = [UIButton]()
//        let icons: [String] = ["guanzhu", "shoucang", "zan2", "jifen"]
        var values: [Int] = [0, 0, 0, 0, 0]
        
        if let _assetInfo = self.assetInfo {
            values[0] = _assetInfo.followNum ?? 0
            values[1] = _assetInfo.collectNum ?? 0
            values[2] = _assetInfo.likeNum ?? 0
            values[3] = _assetInfo.pointNum ?? 0
        }
        
        for (index, _) in menuTitle.enumerated() {
            let btn = UIButton.init(type: .custom)
            
            let value = UILabel()
            value.text = "\(values[index])"
            value.textColor = UIColor.black
            value.font = UIFont(name: "Thonburi", size: 18)
            value.textColor = UIColor.hex("#615963")
            
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = UIColor.hex("#8a8a8a")
            label.text = menuTitle[index]["title"]! as! String
            
            btn.addSubview(value)
            btn.addSubview(label)
            
            btn.addTarget(self, action: #selector(handleClickMenu(sender:)), for: .touchUpInside)
            menu.append(btn)
        }
        return menu
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: menu)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleToFill
        return stackView
    }()
    
    lazy var mainMenu: UIView = {
        let mainMenu = UIView()
        mainMenu.layer.cornerRadius = 6.0;
        mainMenu.layer.masksToBounds = true;
        mainMenu.backgroundColor = UIColor.white
        return mainMenu
    }()
    
    @objc func setContext(vc: MicMeViewController) {
        self.vc = vc
        self.tableNav.vc = vc
    }
    
    @objc func handleClickMenu(sender: UIButton) {
        for (index, btn) in menu.enumerated() {
            if (sender == btn) {
                if (menuTitle[index]["needLogin"]! as! Bool && !self.vc.isLogined) {
                    let loginView = MicLoginViewController();
                    loginView.loginCb = {(userInfo: MicPerson) in
                        self.getUserInfo()
                        if (index == 0) {micro_task.gotoMyFollow(currentVC: self.vc)}
                        if (index == 1) {micro_task.gotoMyCollect(currentVC: self.vc)}
                        if (index == 2) {micro_task.gotoMyLike(currentVC: self.vc)}
                        if (index == 3) {micro_task.getoMyPoint(currentVC: self.vc)}
                    }
                    self.vc.present(loginView, animated: true){}
                    return
                }
                
                if (index == 0) {micro_task.gotoMyFollow(currentVC: vc)}
                if (index == 1) {micro_task.gotoMyCollect(currentVC: vc)}
                if (index == 2) {micro_task.gotoMyLike(currentVC: vc)}
                if (index == 3) {micro_task.getoMyPoint(currentVC: vc)}
            }
        }
    }
    
    @objc func handleClickCheckin() {
        if (self.checkinState == 0) {
            class Data: HandyJSON {
                required init() {}
            }
            AF.request(micro_task.appendToken(url: getCheckinStateUrl), method: .post).responseString { response in
                if let _value = response.value {
                    if let _res = MicBaseResponse<Data>.deserialize(from: _value) {
                        if (_res.retCode == "0") {
                            self.getCheckinState()
                            self.vc.getAccountInfo()
                            micro_task.gotoCheckinList(currentVC: self.vc)
                        }
                    }
                }
            }
        } else {
            micro_task.gotoCheckinList(currentVC: vc)
        }
    }
    
    @objc func handleLogin() {
        micro_task.login(currentVC: vc) { (userInfo) in
            self.getUserInfo!()
        }
    }
    
    @objc func makeInitSubviews() {
        self.addSubview(gridient)
        self.addSubview(tableNav)
        self.addSubview(userCard)
        userCard.addSubview(userAvatar)
        userCard.addSubview(nickname)
        userCard.addSubview(mobile)
        userCard.addSubview(checkin)
        userCard.addSubview(mainMenu)
        userCard.addSubview(loginBtn)
        mainMenu.addSubview(stackView)
    }
    
    @objc func makeInitLayout() {
        tableNav.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(kNavBarAndStatusBarHeight)
            make.left.right.equalToSuperview()
        }
        userCard.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarAndStatusBarHeight + marginTop)
            make.height.equalTo(userCardH)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        userAvatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset((userCardH - userAvatarW)/2 - 20)
            make.width.equalTo(userAvatarW)
            make.height.equalTo(userAvatarW)
            make.left.equalToSuperview().offset(16)
        }
        loginBtn.snp.makeConstraints { (make) in
            make.left.equalTo(userAvatar.snp.right).offset(10)
            make.centerY.equalTo(userAvatar.snp.centerY)
        }
        nickname.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(20)
            make.left.equalTo(userAvatar.snp.right).offset(10)
            make.top.equalTo(userAvatar).offset(8)
        }
        mobile.snp.makeConstraints { (make) in
            make.width.equalTo(140)
            make.height.equalTo(30)
            make.left.equalTo(userAvatar.snp.right).offset(10)
            make.top.equalTo(nickname.snp.bottom).offset(0)
        }
        checkin.snp.makeConstraints { (make) in
            make.width.equalTo(68)
            make.height.equalTo(30)
            make.centerY.equalTo(userAvatar.snp.centerY)
            make.right.equalToSuperview().offset(-16)
        }
        mainMenu.snp.makeConstraints { (make) in
            make.top.equalTo(userAvatar.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(0)
            make.right.equalToSuperview().offset(0)
            make.height.equalTo(mainMenuH)
        }
        stackView.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        for btn in menu {
            let label = btn.subviews[0] as! UILabel
            let value = btn.subviews[1] as! UILabel
            label.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(6)
                make.centerX.equalToSuperview()
            }
            value.snp.makeConstraints { (make) in
                make.top.equalTo(label.snp.bottom).offset(6)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    func updateMenu(assetInfo: MicUserAssets) {
        self.assetInfo = assetInfo
        var values: [Int] = [0, 0, 0, 0, 0]
        if let _assetInfo = self.assetInfo {
            values[0] = _assetInfo.followNum ?? 0
            values[1] = _assetInfo.collectNum ?? 0
            values[2] = _assetInfo.likeNum ?? 0
            values[3] = _assetInfo.pointNum ?? 0
            values[4] = _assetInfo.rcoinNum ?? 0
        }
        for (index, btn) in menu.enumerated() {
            let label = btn.subviews[0] as! UILabel
            label.text = "\(values[index])"
        }
    }
    
    func resetMenu() {
        let values: [Int] = [0, 0, 0, 0, 0]
        self.assetInfo = nil
        for (index, btn) in menu.enumerated() {
            let label = btn.subviews[0] as! UILabel
            label.text = "\(values[index])"
        }
    }
    
    // 清除登录状态
    func clearLoginState() {
        // 资产信息
        self.assetInfo = nil
        let values: [Int] = [0, 0, 0, 0, 0]
        for (index, btn) in menu.enumerated() {
            let label = btn.subviews[0] as! UILabel
            label.text = "\(values[index])"
        }
        
        // 头像信息
        self.userInfo = nil
        nickname.isHidden = true
        mobile.isHidden = true
        checkin.isHidden = true

        loginBtn.isHidden = false
        self.userAvatar.kf.setImage(with: URL(string: kDefaultAvatar))
    }

    func updateUserInfo(userInfo: MicPerson) {
        nickname.isHidden = false
        mobile.isHidden = false
        checkin.isHidden = false
        loginBtn.isHidden = true
        
        self.getCheckinState()
        
        self.userInfo = userInfo
        if let avatar = self.userInfo?.avatar {
            self.userAvatar.kf.setImage(with: URL(string: avatar));
        }
        if let _nickname = self.userInfo?.nickname {
            self.nickname.text = _nickname
        }
        if let _email = self.userInfo?.email {
            self.mobile.text = _email
        }
    }
    
    // 获取签到状态
    func getCheckinState() {
        class Data: HandyJSON {
            var status: Int?
            required init() {}
        }
        AF.request(micro_task.appendToken(url: getCheckinStateUrl)).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<Data>.deserialize(from: _value) {
                    if (_res.errCode == "0") {
                        self.checkinState = (_res.data?.status)!
                        if (self.checkinState == 0) {
                            self.checkin.setTitle("立即签到", for: .normal)
                        } else {
                            self.checkin.setTitle("已签到", for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeInitSubviews()
        makeInitLayout()
        getCheckinState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
