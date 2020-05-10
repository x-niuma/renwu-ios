//
//  MicWebViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/18.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import WebKit

class MicWebViewController: UIViewController {
    
    var webviewUrl: String!
    
    lazy var webview: WKWebView = {
        var webview = WKWebView(frame: view.bounds)
        webview.backgroundColor = UIColor.hex("#f5f5f5")
        webview.scrollView.showsVerticalScrollIndicator = false
        webview.uiDelegate = self as WKUIDelegate
        webview.navigationDelegate = self as WKNavigationDelegate
        return webview
    }()
    
    lazy var progressView: UIProgressView = {
        return UIProgressView()
    }()
    
    lazy var refreshMask: UIView = {
        let v = UIView()
//        v.backgroundColor = UIColor.black
        // v.alpha = 0.5
        return v
    }()
    
    lazy var indictor: UILabel = {
        let v = UILabel()
        v.text = "加载中..."
        v.textColor = UIColor.hex("#8a8a8a")
        v.font = UIFont.systemFont(ofSize: 0)
        return v
    }()
    
    private func makeInitSubviews() {
        view.addSubview(webview)
        view.addSubview(progressView)
        view.addSubview(refreshMask)
        refreshMask.addSubview(indictor)
    }
    
    private func makeInitLayout() {
        webview.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(kNavBarAndStatusBarHeight)
            make.width.equalToSuperview()
            make.height.equalTo(2)
            make.left.equalToSuperview()
        }
        refreshMask.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        indictor.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = self.title
        view.backgroundColor = UIColor.white
        makeInitSubviews()
        makeInitLayout()
        
        // 注册消息
        webview.configuration.userContentController.add(self, name: "login")
        webview.configuration.userContentController.add(self, name: "alert")
        
        // KVO观察estimatedProgress
        webview.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        
        refreshURL()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    @objc func refreshURL(){
        let _url = (self.webviewUrl!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: _url)
        if let url = url {
            webview.load(URLRequest(url: url))
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            // 根据观察的进度来设置进度条的值
            let progress = Float(webview.estimatedProgress)
            self.progressView.setProgress(progress, animated: true)
            // 加载完成
            if progress >= 1.0{
                progressView.alpha = 0.0
                progressView.setProgress(0.0, animated: true)
                refreshMask.isHidden = true
            } else {
                refreshMask.isHidden = false
            }
        }
    }
}

// MARK: -导航处理
extension MicWebViewController: WKNavigationDelegate {
    // request 访问拦截
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        var requestUrl: String = ""
        if let _url = navigationAction.request.url?.absoluteString {
            requestUrl = _url
        }
        
        // 主页
        if (requestUrl == "micro://main") {
            micro_task.gotoSearch(currentVC: self);
            decisionHandler(.cancel)
            return
        }
        
        // 聊天详情
        if (requestUrl.contains("micro://chatItem")) {
            let esUrl = requestUrl.removingPercentEncoding ?? ""
            let desc = esUrl.components(separatedBy: "?")
            let searchStr = desc[1]
            
            let querys = searchStr.components(separatedBy: "&")
            var dict: Dictionary = [String: String]()
            
            for item in querys {
                let array = item.components(separatedBy: "=")
                let key = array[0]
                let value = array[1]
                dict[key] = value
            }
            
            micro_task.gotoChatItem(currentVC: self, userId: dict["userId"]!, nickname: dict["nickname"]!, avatar: dict["avatar"]!)
            
            decisionHandler(.cancel)
            return
        }
        
        // 修改 user-agent
        webView.evaluateJavaScript("navigator.userAgent") { (response, error) in
            let userAgent: String = response as! String
            let nUserAgent: String = userAgent + " " + "MICRO_TASK"
            webView.customUserAgent = nUserAgent
        }
        
        // 下发请求
        decisionHandler(.allow)
    }
    
    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview complete")
        let js = "console.log('hello world2')"
        webView.evaluateJavaScript(js) { (response, error) in
            print("response2:", response ?? "No Response", "\n", "error:", error ?? "No Error")
        }
    }
}

// MARK: - WKUIDelegate
extension MicWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // show js alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
        let action = UIAlertAction.init(title: "确定", style: .default) { (action) in
            completionHandler()
        }
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // show js commfirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController.init(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel) { (action) in
            completionHandler(false)
        }
        alert.addAction(cancelAction)
        
        let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
            completionHandler(true)
        }
        alert.addAction(sureAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // show js Prompt
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController.init(title: "提示", message: prompt, preferredStyle: .alert)
        
        alert.addTextField { (texfiled) in
            texfiled.placeholder = defaultText
        }
        
        let sureAction = UIAlertAction.init(title: "确定", style: .default) { (action) in
            completionHandler(alert.textFields?.last?.text ?? "")
        }
        alert.addAction(sureAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - WKScriptMessageHandler
extension MicWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let name: NSString = message.name as NSString
        let body: [String: Any] = message.body as! [String : Any]
        
        // 用户登录
        if (name.isEqual(to: "login")) {
            let loginView = MicLoginViewController();
            loginView.loginCb = {(userInfo: MicPerson) in
                let js = "\(body["callback"]!)(123)"
                self.webview.evaluateJavaScript(js) { (response, error) in
                    print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                }
            }
            self.present(loginView, animated: true){}
        }
    }
}
