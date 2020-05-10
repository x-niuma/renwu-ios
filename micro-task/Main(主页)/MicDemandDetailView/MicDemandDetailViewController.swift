import UIKit
import WebKit
//import EasyJSBridge

// https://github.com/pkh0225/PKHUrlManager/blob/7e913f032009e5cf05cc74726074a5c380f6be70/URLParser/WebViewController.swift

//

class MicDemandDetailViewController: UIViewController {
    
    var selectedDataItem: MicDemand! // 选中条目
    var webView: WKWebView! // WKWebView
    var progressView: UIProgressView! // UIProgressView
    var webviewUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 页面显示
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false;
    }
    
    // 页面 UI 设置
    fileprivate func setupUI(){
        
        // self.title = self.selectedDataItem.nickname
        self.title = "任务详情";
        
        // 创建 WKWebView
        let webView = WKWebView(frame: self.view.bounds)
        webView.backgroundColor = UIColor.hex("#f5f5f5")
        webView.scrollView.showsVerticalScrollIndicator = false
        
        // webview.navigationDelegate = self
        webView.uiDelegate = self as? WKUIDelegate
        webView.navigationDelegate = self as WKNavigationDelegate
        
        self.view.addSubview(webView)
        self.webView = webView
        
        // UIProgressView
        // UIProgressView后于WKWebView，否则被遮盖
        // 主要是y值要根据不同机型计算一下
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 0))
        self.view.addSubview(progressView)
        
        // KVO观察estimatedProgress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        
        webView.configuration.userContentController.add(self, name: "login")
        
        
        // 1. 创建一个网页的地址
        //         self.webviewUrl = "http://micro.airtlab.com/project/\(self.selectedDataItem.id!)"
        self.webviewUrl = "http://demo.airtlab.com/ios"
        
        let url = URL(string: self.webviewUrl)
        
        // 2. 通过网址创建一个请求
        if let url = url {
            let request = URLRequest(url: url)
            // 3. 加载请求
            webView.load(request)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            // 根据观察的进度来设置进度条的值
            let progress = Float(self.webView.estimatedProgress)
            self.progressView.setProgress(progress, animated: true)
            // 加载完成
            if progress >= 1.0{
                self.progressView.alpha = 0.0
                self.progressView.setProgress(0.0, animated: true)
            }
        }
    }
    
    @objc func injectMethod() {
        
    }
}

extension MicDemandDetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
    }
    
    // request 访问拦截
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    // 页面加载完成
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webview complete")
        // 在 webView 中执行 JS
        let js = "console.log('hello world')"
        webView.evaluateJavaScript(js) { (response, error) in
            print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
        }
    }
}

extension MicDemandDetailViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}


extension MicDemandDetailViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        let name: NSString = message.name as NSString
        let body: [String: Any] = message.body as! [String : Any]
        
        if (name.isEqual(to: "login")) {
            let loginView = MicLoginViewController();
            loginView.loginCb = {(userInfo: MicPerson) in
                let js = "\(body["callback"]!)(123)"
                self.webView.evaluateJavaScript(js) { (response, error) in
                    print("response:", response ?? "No Response", "\n", "error:", error ?? "No Error")
                }
            }
            self.present(loginView, animated: true){}
        }
    }
}
