import UIKit
import WebKit

class MicNiurenDetailViewController: UIViewController {
    
    var selectedDataItem: MicNiuren! // 选中条目
    var webView: WKWebView! // WKWebView
    var progressView: UIProgressView! // UIProgressView
    var webviewUrl: String!
    
//    let age: Int = 0
//    let num: Int // Optional

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // 页面显示
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true;
    }
    
    // 页面 UI 设置
    fileprivate func setupUI(){
        
        self.title = self.selectedDataItem.nickname

        // 创建 WKWebView
        let webView = WKWebView(frame: self.view.bounds)
        webView.scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(webView)
        
        // 放在前面 否则下面访问的时候为nil
        self.webView = webView
        
        // UIProgressView
        // UIProgressView后于WKWebView，否则被遮盖
        // 主要是y值要根据不同机型计算一下
        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 89, width: self.view.frame.size.width, height: 0))
        self.view.addSubview(progressView)
        
        // KVO观察estimatedProgress
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        
        // 1. 创建一个网页的地址
        self.webviewUrl = "http://micro.airtlab.com/userProfile/\(self.selectedDataItem.id!)"
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
    
    deinit {
        print("88")
        // 这里不移除观察者不会引起释放不了的问题
    }

}
