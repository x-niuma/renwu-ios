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
import Toast_Swift

class MicSettingViewController: UIViewController {
    var isLogind: Bool = false
    let menu1 = [
        ["title": "关于我们", "needLogin": false],
        //        ["title": "帮助与反馈", "needLogin": false],
        ["title": "联系我们", "needLogin": false],
        ["title": "缓存清理", "needLogin": false],
        ["title": "给我一个好评吧", "needLogin": false],
//        ["title": "退出登录", "needLogin": true],
        //        ["title": "注销账户", "needLogin": true],
    ];
    
    lazy var tableView: UITableView = {
        let t = UITableView.init(frame: .zero, style: .plain)
        t.delegate = self
        t.dataSource = self
        t.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        t.contentOffset = .init(x: 0, y: 0)
        t.backgroundColor = UIColor.hex("#f5f5f5")
        t.separatorStyle = .none
        return t
    }()
    
    lazy var footer: UIView = {
        let v = UIView()
        v.backgroundColor = .red
        return v
    }()
    
    lazy var loginOut: UIView = {
        let v = UIButton()
        v.setTitle("退出登录", for: .normal)
        v.layer.cornerRadius = 2
        v.layer.masksToBounds = true
        v.setTitleColor(UIColor.white, for: .normal)
        v.backgroundColor = UIColor.hex("#615963")
        v.addTarget(self, action: #selector(logout), for: .touchUpInside)
        return v
    }()
    
    private func makeInitLayout() {
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview().offset(0)
        }
        footer.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        loginOut.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview().offset(-12)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(self.menu1.count * 60 + 40)
        }
    }
    
    private func makeInitSubviews() {
        tableView.tableFooterView = footer
        view.addSubview(tableView)
        self.view.addSubview(loginOut)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        self.navigationItem.title = "设置"
        super.viewDidLoad()
        makeInitSubviews()
        makeInitLayout()
    }
}


extension MicSettingViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = "cellID";
        var cell:UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellID)
        if (cell==nil) {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: cellID);
        }
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text =  self.menu1[indexPath.row]["title"] as? String
        if (indexPath.row == 1) {
            cell.detailTextLabel?.text = "1056834607@qq.com"
        }
        
        cell.selectionStyle = .none
        
        if (indexPath.row == (self.menu1.count - 1)) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: cell.bounds.size.width + 16);
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index: Int = indexPath.row
        if (index == 0) {
            micro_task.gotoAboutUs(currentVC: self)
        }
        //        if (index == 1) {
        //             showEmail()
        //        }
        if (index == 2) {
            clear()
        }
        if (index == 3) {
            givePrice()
        }
        if (index == 4) {
            logout()
        }
    }
    
    //跳转到应用的AppStore页页面
    func gotoAppStore() {
        let urlString = "itms-apps://itunes.apple.com/app/id1516051676"
        let url = NSURL(string: urlString)
        UIApplication.shared.openURL(url! as URL)
    }
    
    func givePrice() {
        //弹出消息框
        let alertController = UIAlertController(
            title: "觉得好用吗？给我个评价吧！",
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "暂不评价",
            style: .cancel,
            handler: nil
        )
        let okAction = UIAlertAction(
            title: "好的",
            style: .default,
            handler: { action in
                self.gotoAppStore()
        }
        )
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showEmail() {
        let style = ToastStyle()
        self.view.makeToast("邮箱: 1056834607@qq.com", duration: 2.0, position: .center, style: style)
    }
    
    // 退出登录确认弹窗
    @objc func logout() {
        let alertController = UIAlertController(
            title: "真的要退出登录吗",
            message: nil,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: "取消",
            style: .cancel,
            handler: nil
        )
        let okAction = UIAlertAction(
            title: "确认",
            style: .default,
            handler: { action in
                micro_task.loginOut()
                let viewControllers = self.navigationController?.viewControllers
                let prevVC: MicMeViewController = (viewControllers![viewControllers!.count - 2]) as! MicMeViewController
                
                prevVC.isLogined = false
                prevVC.userInfo = nil
                prevVC.clearLoginState()
                self.navigationController?.popViewController(animated: true)
            }
        )
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // 缓存清理
    func clear() {
        // create a new style
        let style = ToastStyle()
        
        // present the toast with the new style
        self.view.makeToast("缓存清理成功~", duration: 1.0, position: .center, style: style)
        
        //        self.view.makeToast("缓存清理成功", point: CGPoint(x: 100, y: 100), title: "ddd", image: UIImage(named: "success")) { (didTap) in
        //            print(111)
        //        }
    }
}
