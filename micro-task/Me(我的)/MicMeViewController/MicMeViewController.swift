//
//  Mic2ViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/6.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire
import HandyJSON

let rote = CGFloat(375.0 / 169.0)
let bgHeight = kScreenWidth / rote

class MicMeViewController: UIViewController {
    let menu1 = [
        ["title": "我的接单", "needLogin": true],
        ["title": "我的需求", "needLogin": true],
        ["title": "发布需求", "needLogin": true],
        ["title": "账户设置", "needLogin": true],
        ["title": "关于我们", "needLogin": false],
        ["title": "设置", "needLogin": true]
    ];
    var userInfo: MicPerson? = nil // 用户信息
    var assetInfo: MicUserAssets? = nil // 资产信息
    let headerViewH = 170 + 20 + kNavBarAndStatusBarHeight
    var menu2Btns = [UIButton]()
    var loginBtn = UIButton()
    var cellHeight = 50
    var bgColor = UIColor.hex("#615963")
    var navColor = UIColor.hex("#615963")
    var isLogined: Bool = false // 是否登录(维护登录状态)
    
    /**
     * 获取用户信息
     */
    @objc func getUserInfo() {
        let userDefaults = UserDefaults.standard
        let locale = userDefaults.object(forKey: "userInfo")
        if (locale != nil) {
            /**
             * 之前登录过, 把用户信息取出来
             */
            do {
                let userInfo: MicPerson = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [MicPerson.self], from: locale as! Data) as! MicPerson;
                self.userInfo = userInfo;
            } catch {
                print(error)
            }
        }
        
        if (self.userInfo != nil) {
            /**
             * 本地已经缓存了用户信息, 先展示出来
             * 然后判断登录是否过期, 如果过期, 需要清除页面上展示的用户信息
             */
            headerView.updateUserInfo(userInfo: self.userInfo!)

            if (self.userInfo?.token) != nil {
                self.getAccountInfo()
            } else {
                clearLoginState()
            }
        } else {
            clearLoginState()
        }
    }
    
    func clearLoginState() {
        self.headerView.clearLoginState()
    }
    
    // 获取账户信息
    func getAccountInfo() {
        let url = getUserAssetsUrl + "?token=\((self.userInfo?.token)!)"
        AF.request(url, method: .get).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<MicUserAssets>.deserialize(from: _value) {
                    if (_res.retCode == "0") {
                        self.isLogined = true
                        self.assetInfo = _res.data
                        self.headerView.updateMenu(assetInfo: self.assetInfo!)
                    } else {
                        self.isLogined = false
                        self.clearLoginState()
                    }
                }
            }
        }
        
//        AF.request(url).responseJSON { response in
//            if let resData = response.data {
//                let decoder = JSONDecoder()
//                do {
//                    let model = try decoder.decode(MicUserAssestRes.self, from: resData)
//                    if model.retCode == "0" {
//                        if let data = model.data {
//                            self.isLogined = true
//                            self.assetInfo = data
//                            self.headerView.updateMenu(assetInfo: self.assetInfo!)
//                        } else {
//                            self.isLogined = false
//                            self.clearLoginState()
//                        }
//                    } else {
//                        self.isLogined = false
//                        self.clearLoginState()
//                    }
//                }
//                catch {
//                    print(error)
//                }
//            }
//        }
    }
    
    lazy var headerView: MicMeUserCard = {
        let frame = CGRect.init(x: 0, y: 0, width: Int(kScreenWidth), height: Int(headerViewH))
        let view = MicMeUserCard.init(frame: frame)
        view.setContext(vc: self)
        view.navColor = navColor
        view.getUserInfo = getUserInfo
        return view
    }()
    
    lazy var fixedHeader: MicMeHeader = {
        let frame = CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kNavBarAndStatusBarHeight)
        let v = MicMeHeader.init(frame: frame)
        v.vc = self
        v.backgroundColor = UIColor.white
        v.titleLabel.text = "我的"
        v.saomaBtn.tintColor = UIColor.hex("#888888")
        v.settingBtn.tintColor = UIColor.hex("#888888")
        v.alpha = 0
        return v
    }()
    
    lazy var tableView: UITableView = {
        let t = UITableView.init(frame: .zero, style: .plain)
        t.delegate = self
        t.dataSource = self
        t.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        t.contentOffset = .init(x: 0, y: 0)
        t.backgroundColor = UIColor.hex("#f5f5f5")
        t.contentInsetAdjustmentBehavior = .never
        return t
    }()
    
    lazy var footerView: UIView = {
        let footerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Int(kScreenWidth), height: self.menu1.count * cellHeight + 24))
        footerView.backgroundColor = UIColor.hex("#f5f5f5")
        return footerView
    }()
    
    lazy var coverBg: UIView = {
        let view = UIView()
        view.backgroundColor = navColor
        return view
    }()
    
    private func makeInitLayout() {
        fixedHeader.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.height.equalTo(kNavBarAndStatusBarHeight)
            make.left.right.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0)
            make.left.bottom.right.equalToSuperview().offset(0)
        }
        coverBg.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(0)
            make.height.equalTo(0)
        }
    }
    
    private func makeInitSubviews() {
        view.addSubview(tableView)
        view.addSubview(fixedHeader)
        view.addSubview(coverBg)
        tableView.tableHeaderView = headerView
    }
    
    func addFooterMenu() {
        for (index, value) in menu1.enumerated() {
            let item = UIButton()
            footerMenu.addSubview(item)
            item.addTarget(self, action: #selector(handleClickMenu(sender:)), for: .touchUpInside)
            item.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(0)
                make.right.equalToSuperview().offset(0)
                make.top.equalToSuperview().offset(index * cellHeight)
                make.height.equalTo(cellHeight)
            }
            
            let icon = UIImageView()
            icon.image = UIImage(named: "bill")?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = bgColor
            item.addSubview(icon)
            icon.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(8)
                make.centerY.equalToSuperview()
            }
            
            let name = UILabel()
            item.addSubview(name)
            name.text = value["title"] as? String
            name.textColor = UIColor.hex("#8a8a8a")
            name.font = UIFont.systemFont(ofSize: 16)
            name.snp.makeConstraints { (make) in
                make.left.equalTo(icon.snp.right).offset(8)
                make.centerY.equalToSuperview()
            }
            
            if ((index + 1) != menu1.count) {
                let line = UIView()
                item.addSubview(line)
                line.backgroundColor = UIColor.hex("#f5f5f5")
                line.snp.makeConstraints { (make) in
                    make.left.equalToSuperview().offset(12)
                    make.right.equalToSuperview().offset(0)
                    make.height.equalTo(1)
                    make.bottom.equalToSuperview().offset(0)
                }
            }
            
            let arrow = UIImageView()
            arrow.image = UIImage(named: "arrow-right")
            item.addSubview(arrow)
            arrow.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-10)
            }
        }
    }
    
    lazy var footerMenu: UIView = {
        let footerMenu = UIView()
        footerMenu.backgroundColor = UIColor.white
        footerMenu.layer.cornerRadius = 6
        footerMenu.layer.masksToBounds = true
        return footerMenu
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        self.getUserInfo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeInitSubviews()
        makeInitLayout()
        
        footerView.addSubview(footerMenu)
        tableView.tableFooterView = footerView
        footerMenu.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(self.menu1.count * cellHeight)
            make.top.equalToSuperview().offset(12)
        }
        addFooterMenu()
    }
    
    @objc func handleClickMenu(sender: UIButton) {
        for (index, btn) in footerMenu.subviews.enumerated() {
            if (btn === sender) {
                if (menu1[index]["needLogin"]! as! Bool && !self.isLogined) {
                    let loginView = MicLoginViewController();
                    loginView.loginCb = {(userInfo: MicPerson) in
                        self.getUserInfo()
                        if (index == 3) {micro_task.gotoUserInfo(currentVC: self)}
                        if (index == 2) {micro_task.gotoCreateDemand(currentVC: self)}
                        if (index == 1) {micro_task.gotoMyDemand(currentVC: self)}
                        if (index == 0) {micro_task.gotoMyEnroll(currentVC: self)}
                        if (index == 4) {micro_task.gotoAboutUs(currentVC: self)}
                        if (index == 5) {micro_task.gotoSetting(currentVC: self)}
                    }
                    self.present(loginView, animated: true){}
                    return
                }
                
                if (index == 3) {micro_task.gotoUserInfo(currentVC: self)}
                if (index == 2) {micro_task.gotoCreateDemand(currentVC: self)}
                if (index == 1) {micro_task.gotoMyDemand(currentVC: self)}
                if (index == 0) {micro_task.gotoMyEnroll(currentVC: self)}
                if (index == 4) {micro_task.gotoAboutUs(currentVC: self)}
                if (index == 5) {micro_task.gotoSetting(currentVC: self)}
            }
        }
    }
    
    // 下拉刷新
    @objc func loadData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    // 往上滑动，offset是增加的，往下是减小的
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let alpha = offset/kNavBarAndStatusBarHeight
        if (offset <= 0) {
            coverBg.snp.updateConstraints { (make) in
                make.height.equalTo(abs(offset))
            }
            self.fixedHeader.alpha = 0
        } else {
            coverBg.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            self.fixedHeader.alpha = alpha
        }
    }
}


extension MicMeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.title?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID";
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell==nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: cellID);
        }
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text =  self.menu1[indexPath.row]["title"] as? String
        cell.selectionStyle = .none
        
        if (indexPath.row == (self.menu1.count - 1)) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width + 16);
        }
        return cell
    }
}
