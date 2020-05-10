//
//  EasyJSBridge.swift
//  EasyJSBridge
//
//  Created by Howard on 2019/2/19.
//  Copyright © 2019 Howard. All rights reserved.
//

import UIKit
import WebKit

private let kCustomProtocolScheme = "easy-jsbridge"
private let kBridgeLoaded = "__BRIDGE_LOADED__"
private let kQueueHasMessage = "__QUEUE_MESSAGE__"
private let kFetchQueueString = "EasyJSBridge._fetchQueue()"

//消息响应回调
public typealias EasyJSBridgeResponseCallback = (Any?) -> Void

//消息处理回调
public typealias EasyJSBridgeHandler = (_ data: Any?, _ responseCallback: EasyJSBridgeResponseCallback) -> Void

open class EasyJSBridge: NSObject {
    //公共属性
    public weak var wkWebViewDelegate: WKNavigationDelegate? //设置wkWebViewDelegate属性，可以让外部代理和EasyJSBridge内部代理共存
    public weak var uiWebViewDelegate: UIWebViewDelegate?  //设置uiWebViewDelegate属性，可以让外部代理和EasyJSBridge内部代理共存
    
    //私有属性
    private static var logging = false
    
    private var wkWebView: WKWebView!
    private var uiWebView: UIWebView!
    private var callMessageQueue: [[String: Any]]?
    private var responseCallbacks: [String: EasyJSBridgeResponseCallback]!
    private var messageHandlers: [String: EasyJSBridgeHandler]!
    private var uniqueId: Int!
    private var isWKWebView: Bool = true //当前webview是否是WKWebView
}

//MARK:- 公共方法
extension EasyJSBridge {
    //注入EasyJSBridge
    //webView:WKWebView
    //webViewDelegate:WkWebview代理
    public static func bridgeForWKWebView(webView: WKWebView, _ webViewDelegate: WKNavigationDelegate? = nil) -> EasyJSBridge {
        let easyJSBridge = EasyJSBridge()
        easyJSBridge.platformSpecificSetup(webView: webView)
        easyJSBridge.wkWebView = webView
        easyJSBridge.wkWebView.navigationDelegate = easyJSBridge
        easyJSBridge.wkWebViewDelegate = webViewDelegate
        easyJSBridge.isWKWebView = true
        return easyJSBridge
    }
    
    //注入EasyJSBridge
    //webView:UIWebView
    //webViewDelegate:UIWebView代理
    public static func bridgeForUIWebView(webView: UIWebView, _ webViewDelegate: UIWebViewDelegate? = nil) -> EasyJSBridge {
        let easyJSBridge = EasyJSBridge()
        easyJSBridge.platformSpecificSetup(webView: webView)
        easyJSBridge.uiWebView = webView
        easyJSBridge.uiWebView.delegate = easyJSBridge
        easyJSBridge.uiWebViewDelegate = webViewDelegate
        easyJSBridge.isWKWebView = false
        return easyJSBridge
    }
    
    //开启调试日志，默认未开启
    public static func enableLogging() {
        logging = true
    }
    
    //注册一个方法供H5调用
    //handlerName:方法名
    //handler:处理回调
    public func registerHandler(handlerName: String, handler: @escaping EasyJSBridgeHandler) {
        self.messageHandlers[handlerName] = handler
    }
    
    //发消息给H5
    //handlerName:方法名
    //data:消息参数，默认为nil
    //responseCallback:H5响应回调
    public func callHandler(handlerName: String, data: Any? = nil, responseCallback: EasyJSBridgeResponseCallback? = nil) {
        var message: [String: Any] = [:]
        message["handlerName"] = handlerName
        if data != nil {
            message["data"] = data!
        }
        if responseCallback != nil {
            self.uniqueId += 1
            let callbackId = String(format: "objc_cb_%d", self.uniqueId)
            message["callbackId"] = callbackId
            self.responseCallbacks[callbackId] = responseCallback!
        }
        self.addH5MessageToQueue(message: message)
    }
}

//MARK:- 私有方法
extension EasyJSBridge {
    //初始化数据
    private func platformSpecificSetup(webView: Any) {
        self.callMessageQueue = []
        self.responseCallbacks = [:]
        self.messageHandlers = [:]
        self.uniqueId = 0
    }
    
    //调试日志
    private func log(action: String, data: Any) {
        if !EasyJSBridge.logging { return }
        var dataJson = ""
        if let dataString = data as? String {
            dataJson = dataString
        } else if let dataDic = data as? [String: Any] {
            guard let data = try? JSONSerialization.data(withJSONObject: dataDic, options: .prettyPrinted) else {
                return
            }
             dataJson =  String(data: data, encoding: .utf8) ?? ""
        }
        if dataJson.count > 500 {
            print("EasyJSBridge \(action): \(dataJson) [...]")
        } else {
            print("EasyJSBridge \(action): \(dataJson)")
        }
    }
    
    //是否是约定scheme
    private func isCorrentProcotocolScheme(url: URL) -> Bool {
        let result = url.scheme == kCustomProtocolScheme
        return result
    }
    
    //是否是注入请求
    private func isBridgeLoadedURL(url: URL) -> Bool {
        return url.scheme == kCustomProtocolScheme && url.host == kBridgeLoaded
    }
    
    //是否有H5发过来的消息队列
    private func hasQueueMessage(url: URL) -> Bool {
        return url.host == kQueueHasMessage
    }
    
    //添加消息到消息队列
    private func addH5MessageToQueue(message: [String: Any]) {
        if self.callMessageQueue != nil {
            self.callMessageQueue!.append(message)
        } else {
           self.dispatchMessage(message)
        }
    }
    
    //处理URL
    private func handleURL(_ requestUrl: URL) {
        if self.isBridgeLoadedURL(url: requestUrl) {
            self.injectJSFile()
        } else if self.hasQueueMessage(url: requestUrl) {
            self.flushMessageQueue()
        } else {
            self.log(action: "WARNING", data: "Received unknown EasyJSBridge command \(kCustomProtocolScheme)://\(requestUrl.path)")
        }
    }
    
    //发送消息给H5
    private func dispatchMessage(_ message: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: message, options: .prettyPrinted) else {
            return
        }
        var messsJson =  String(data: data, encoding: .utf8) ?? ""
        messsJson = messsJson.replacingOccurrences(of: "\\", with: "\\\\")
        messsJson = messsJson.replacingOccurrences(of: "\"", with: "\\\"")
        messsJson = messsJson.replacingOccurrences(of: "\'", with: "\\\'")
        messsJson = messsJson.replacingOccurrences(of: "\n", with: "\\n")
        messsJson = messsJson.replacingOccurrences(of: "\r", with: "\\r")
        self.log(action: "Send", data: message)
        let jsCommand = String(format: "EasyJSBridge._handleMessageFromApp('%@')", messsJson)
        if Thread.current.isMainThread {
            self.evaluateJS(jsCommand)
            
        } else {
            DispatchQueue.main.async {
                 self.evaluateJS(jsCommand)
            }
        }
    }
    
    //格式化H5发过来的消息队列
    private func formatMessage(message: String) -> Array<Any>? {
        let data = message.data(using: String.Encoding.utf8)
        guard let messageData = data else {
            self.log(action: "WARNING", data: "H5发过来的消息为空")
            return nil
        }
        let messageArray = try! JSONSerialization.jsonObject(with: messageData, options: .allowFragments) as? Array<Any>
        return messageArray
    }
    
    //注入JSBridge
    private func injectJSFile() {
        let path = Bundle(for: EasyJSBridge.self).path(forResource: "easy-bridge.js", ofType: "txt")
        guard let filePath = path else { return }
        let js = try? String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let jsString = js else { return }
        self.evaluateJS(jsString) { [weak self](_, _) in
            guard let self = self else { return }
            if self.callMessageQueue != nil {
                for message in self.callMessageQueue! {
                    self.dispatchMessage(message)
                }
                self.callMessageQueue = nil
            }
        }
    }
    
    //执行JS命令
    private func evaluateJS(_ js: String, complete:((Any?, Error?) -> Void)? = nil) {
        if self.isWKWebView {
            self.wkWebView.evaluateJavaScript(js, completionHandler: complete)
        } else {
            let result = self.uiWebView.stringByEvaluatingJavaScript(from: js)
            complete?(result, nil)
        }
    }
    
    //拉取H5发过来的消息队列
    private func flushMessageQueue() {
        self.evaluateJS(kFetchQueueString, complete: { [weak self](result, error) in
            if error != nil {
                self?.log(action: "WARNING", data: "从H5获取数据错误\(error!)")
            } else {
                guard let self = self else { return }
                self.handleMessage(result: result)
            }
        })
    }
    
    //处理h5发过来的消息
    private func handleMessage(result: Any?) {
        let resultString = result as? String
        if resultString == nil || resultString!.count <= 0 {
            self.log(action: "WARNING", data: "MessageQueue is nil")
            return
        }
        let messageArr = self.formatMessage(message: resultString!)
        guard let messages = messageArr else {
            return
        }
        for messsage in messages {
            guard let messageDic = messsage as? [String: Any] else {
                continue
            }
            self.log(action: "Receive", data: messageDic)
            let responseId = messageDic["responseId"] as? String
            if responseId != nil {
                let responseCallback = self.responseCallbacks[responseId!]
                if responseCallback != nil {
                    responseCallback!(messageDic["responseData"])
                    self.responseCallbacks.removeValue(forKey: responseId!)
                }
            } else {
                let handlerName: String = messageDic["handlerName"] as? String ?? ""
                let callbackId =  messageDic["callbackId"] as? String
                var responseCallback: EasyJSBridgeResponseCallback!
                if callbackId != nil {
                    responseCallback = {[weak self](data) in
                        guard let self = self else { return }
                        var message: [String: Any] = [:]
                        message["responseId"] = callbackId!
                        message["responseData"] = data
                        self.addH5MessageToQueue(message: message)
                    }
                } else {
                    responseCallback = {(_) in}
                }
                let handler =  self.messageHandlers[handlerName]
                if handler == nil {
                    continue
                }
                handler!(messageDic["data"], responseCallback)
            }
        }
    }
}

//MARK:- UIWebView--UIWebViewDelegate
extension EasyJSBridge: UIWebViewDelegate {
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let url = request.url
        guard let requestUrl = url else { return true }
        if self.isCorrentProcotocolScheme(url: requestUrl) {
            self.handleURL(requestUrl)
        }
        var result = true
        result =  self.uiWebViewDelegate?.webView?(webView, shouldStartLoadWith: request, navigationType: navigationType) ?? true
        return result
    }
    
    public func webViewDidStartLoad(_ webView: UIWebView) {
        self.uiWebViewDelegate?.webViewDidStartLoad?(webView)
    }
    
    public func webViewDidFinishLoad(_ webView: UIWebView) {
        self.uiWebViewDelegate?.webViewDidFinishLoad?(webView)
    }
    
    public func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.uiWebViewDelegate?.webView?(webView, didFailLoadWithError: error)
    }
}

//MARK:- WKWebView--WKNavigationDelegate
extension EasyJSBridge: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        guard let requestUrl = url else { return }
        if self.isCorrentProcotocolScheme(url: requestUrl) {
            self.handleURL(requestUrl)
            decisionHandler(.cancel)
        } else {
            self.wkWebViewDelegate?.webView?(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
            decisionHandler(.allow)
        }
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.wkWebView != webView {
            return
        }
        self.wkWebViewDelegate?.webView?(webView, didFinish: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if self.wkWebView != webView {
            return
        }
        self.wkWebViewDelegate?.webView?(webView, didFail: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.wkWebView != webView {
            return
        }
        self.wkWebViewDelegate?.webView?(webView, didStartProvisionalNavigation: navigation)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if self.wkWebView != webView {
            return
        }
        self.wkWebViewDelegate?.webView?(webView, didFailProvisionalNavigation: navigation, withError: error)
    }
    
    public func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if self.wkWebView != webView {
            return
        }
        self.wkWebViewDelegate?.webView?(webView, didReceive: challenge, completionHandler: completionHandler)
    }
}
