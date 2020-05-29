//
//  MicAPP.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/12.
//  Copyright © 2020 airtim. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import HandyJSON


// MARK: -尺寸相关
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
let kIsIPhone = UI_USER_INTERFACE_IDIOM() == .phone
let kIsIPhoneX = kScreenWidth >= 375.0 && kScreenHeight >= 812.0 && kIsIPhone
let kStatusbarHeight = kIsIPhoneX ? 44.0 : 20.0
let kNavBarHeight = 44
let kNavBarAndStatusBarHeight : CGFloat = kIsIPhoneX ? 88.0 : 64.0
let KDocuments = NSHomeDirectory() + "/Documents/"
let kDefaultAvatar = "https://c1.airtlab.com/micro-avatar.png"


// MARK: -WebView 页面配置
let h5BaseUrl = "http://micro.airtlab.com"
let baseUrl = "http://micro.airtlab.com/api"

//let baseUrl = "http://192.168.0.104:8003"
//let h5BaseUrl = "http://192.168.0.104:8000"

let loginUrl = baseUrl + "/user/login/" // 用户登录
let registerUrl = baseUrl + "/user/register/" // 用户注册
let getUserAssetsUrl = baseUrl + "/user/getUserAssets/" // 获取用户资产
let getDemandListUrl = baseUrl + "/demand/" // 获取需求列表
let getProjectCategory = baseUrl + "/projectCategory/" // 获取需求分类
let getCheckinStateUrl = baseUrl + "/checkin" // 获取签到状态
let getLoginStatusUrl = baseUrl + "/user/checkLogin" // 获取登录状态
let getEmailCodeUrl = baseUrl + "/common/getEmailCode" // 获取邮箱验证码

// MARK: -颜色
let lineColor = UIColor.hex("#f4f4f4")
let badgeCOlor = UIColor.hex("#faebd7")
let fontMainColor = UIColor.hex("#333")
let fontSecondColor = UIColor.hex("#646566")
let fontGrayColor = UIColor.hex("#b3aeae")
func rgbaColor(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1);
}

// MARK: 公共方法
func appendToken(url: String) -> String {
    let userDefaults = UserDefaults.standard
    let locale = userDefaults.object(forKey: "userInfo")
    var userInfo: MicPerson? = nil
    var token: String = "";
    if (locale != nil) {
        do {
            userInfo = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [MicPerson.self], from: locale as! Data) as? MicPerson;
            token = userInfo?.token! ?? ""
        } catch {
            print(error)
        }
    }
    var nUrl = url
    if (!(nUrl.contains("?"))) {
        nUrl += "?"
    }
    return nUrl + "&token=\(token)"
}

func loginOut() {
    let userDefaults = UserDefaults.standard
    userDefaults.removeObject(forKey: "userInfo")
    userDefaults.synchronize()
}

// Loading
func showLoading(view: UIView) -> MBProgressHUD {
     let hud = MBProgressHUD.showAdded(to: view, animated: true)
     hud.label.text = "加载中..."
     hud.label.font = UIFont.systemFont(ofSize: 12)
     // hud.contentColor = UIColor.blue
     hud.removeFromSuperViewOnHide = true
     return hud
 }
 
 // Tip
func showTip(message: String = "操作成功", view: UIView) {
     let hud = MBProgressHUD.showAdded(to: view, animated: true)
     hud.mode = .text
     hud.label.text = message
     hud.label.font = UIFont.systemFont(ofSize: 12)
     // hud.contentColor = UIColor.blue
     hud.hide(animated: true, afterDelay: 1.5)
 }

// MARK: -页面跳转配置
func gotoH5(currentVC: UIViewController, url: String, title: String) {
    let vc = MicWebViewController()
    vc.webviewUrl = appendToken(url: url)
    vc.title = title
    currentVC.navigationController?.pushViewController(vc, animated: true)
}

func gotoSearch(currentVC: UIViewController) {
    let url = h5BaseUrl + "/search"
    gotoH5(currentVC: currentVC, url: url, title: "搜索")
}

func gotoDemandDetail(currentVC: UIViewController, demandInfo: MicDemand) {
    let url = h5BaseUrl + "/project/\(demandInfo.id!)"
    gotoH5(currentVC: currentVC, url: url, title: "需求详情")
}

func gotoNiurenDetail(currentVC: UIViewController, niurenInfo: MicNiuren) {
    let url = h5BaseUrl + "/userProfile/\(niurenInfo.id!)" // 用户主页
    gotoH5(currentVC: currentVC, url: url, title: niurenInfo.nickname!)
}

func gotoMyFollow (currentVC: UIViewController) {
    let url = h5BaseUrl + "/follow"
    gotoH5(currentVC: currentVC, url: url, title: "我的关注")
}

func gotoMyCollect (currentVC: UIViewController) {
    let url = h5BaseUrl + "/collect?typeId=1&objectId=2"
    gotoH5(currentVC: currentVC, url: url, title: "我的收藏")
}

func getoMyPoint (currentVC: UIViewController){
    let url = h5BaseUrl + "/point"
    gotoH5(currentVC: currentVC, url: url, title: "我的积分")
}

func gotoMyLike (currentVC: UIViewController) {
    let url = h5BaseUrl + "/collect?typeId=2&objectId=2"
    gotoH5(currentVC: currentVC, url: url, title: "我的点赞")
}

func gotoUserInfo (currentVC: UIViewController) {
    let url = h5BaseUrl + "/userInfo"
    gotoH5(currentVC: currentVC, url: url, title: "我的资料")
}

func gotoCreateDemand (currentVC: UIViewController) {
    let url = h5BaseUrl + "/demand/create"
    gotoH5(currentVC: currentVC, url: url, title: "发布需求")
}

func gotoMyDemand (currentVC: UIViewController) {
    let url = h5BaseUrl + "/my-project"
    gotoH5(currentVC: currentVC, url: url, title: "我的需求")
}

func gotoMyEnroll(currentVC: UIViewController) {
    let url = h5BaseUrl + "/user-enroll-project"
    gotoH5(currentVC: currentVC, url: url, title: "我的接单")
}

func gotoDemo(currentVC: UIViewController) {
    gotoH5(currentVC: currentVC, url: "http://demo.airtlab.com/ios?token=xxxx", title: "webview")
}

func gotoChatItem(currentVC: UIViewController, niuren: MicNiuren) {
    let url = h5BaseUrl + "/chatItem/\(niuren.id!)?avatar=\(niuren.avatar!)&nickname=\(niuren.nickname!)"
    gotoH5(currentVC: currentVC, url: url, title: niuren.nickname!)
}

func login(currentVC: UIViewController, success: @escaping (MicPerson)->Void) {
    let loginView = MicLoginViewController();
    loginView.loginCb = success
    currentVC.present(loginView, animated: true){}
}

func gotoCheckinList(currentVC: UIViewController) {
    let url = h5BaseUrl + "/checkin"
    gotoH5(currentVC: currentVC, url: url, title: "我的签到")
}

func gotoPointList(currentVC: UIViewController) {
    let url = h5BaseUrl + "/point"
    gotoH5(currentVC: currentVC, url: url, title: "我的积分")
}

func gotoChatItem(currentVC: UIViewController, userId: String, nickname: String, avatar: String) {
    let url = h5BaseUrl + "/chatItem/\(userId)?avatar=\(avatar)&nickname=\(nickname)"
    gotoH5(currentVC: currentVC, url: url, title: nickname)
}

func gotoAboutUs(currentVC: UIViewController) {
    let url = h5BaseUrl + "/about-us"
    gotoH5(currentVC: currentVC, url: url, title: "关于我们")
}

func gotoSetting(currentVC: UIViewController) {
    let view = MicSettingViewController()
    currentVC.navigationController?.pushViewController(view, animated: true)
}
