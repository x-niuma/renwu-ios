# EasyJSBridge
iOS Native和H5交互神器

## 示例
![](/Screenshots/example_1.png) 

## 背景
swift项目中快速实现Native和H5的交互，Android也可以实现此方案，H5小伙伴使用起来也方便灵活，简单调用同时兼容iOS和Android

## 功能
-  App和H5双向通信
-  支持UIWebView和WKWebView
-  支持多个Scheme并存
-  开启和关闭调试日志

## 要求
-  iOS 8.0+
-  Swift 4.0+

## 安装
#### CocoaPods
`Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!
pod 'EasyJSBridge'
```

然后运行:
```bash
$ pod install
```

## 使用
#### 导入头文件
```swift
import EasyJSBridge
```
#### 具体用法

**iOS端**

开启调试日志信息
```swift
EasyJSBridge.enableLogging() //默认未启动调试日志
```

注入EasyJSBridge
```swift
self.easyJSBridge = EasyJSBridge.bridgeForWKWebView(webView: self.wkWebView) //WKWebView中注入EasyJSBridge
self.easyJSBridge = EasyJSBridge.bridgeForUIWebView(webView: self.uiWebView) //UIWebView中注入EasyJSBridge
```

注册方法供H5调用
```swift
//handlerName:方法名
//handler:- data:H5传递过来的数据 responseCallback:把处理好的数据返回给H5
self.easyJSBridge.registerHandler(handlerName: "xxxx", handler: { (data, responseCallback) in
    print("Hello App:\(data ?? "")")
    responseCallback("xxxx")
})
```

调用H5注册好的一个名为xxxx的方法
```swift
self.easyJSBridge.callHandler(handlerName: "xxxx")
```

调用H5注册好的一个名为xxxx的方法，带参数
 ```swift
self.easyJSBridge.callHandler(handlerName: "xxxx", data: "xxxx")
```

调用H5注册好的一个名为xxxx的方法，带参数，带H5响应回调
```swift
self.easyJSBridge.callHandler(handlerName: "xxxx", data: "xxxx", responseCallback: { (response) in
    print("收到H5的响应数据:\(response ?? "")")
})
```

**H5端**

在Window对象上注入EasyJSBridge，注入成功后会进入回调方法
```js
function setupWebViewJavascriptBridge(callback) {
    if(window.EasyJSBridge) {
        return callback(EasyJSBridge);
    }
    if(window.WVJBCallbacks) {
        return window.WVJBCallbacks.push(callback);
    }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'easy-jsbridge://__BRIDGE_LOADED__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function() {
        document.documentElement.removeChild(WVJBIframe)
    }, 0)
}
```

注册一个名为xxxx的方法供App调用
```js
//handlerName:方法名
//handler:- data:App传递过来的数据 responseCallback:把处理好的数据返回给App
bridge.registerHandler('xxxx', function(data, responseCallback) {
    alert('收到App数据:'+data);
    responseCallback("xxxx");
})
```

调用App注册好的一个名为xxxx的方法
```js
bridge.callHandler('xxxx')
```

调用App注册好的一个名为xxxx的方法，带参数
```js
bridge.callHandler('xxxx', "xxxx")
```

调用App注册好的一个名为xxxx的方法，带参数，带App响应回调
```js
bridge.callHandler('xxxx', "xxxx", function(data) {
    alert('收到App的响应数据:'+data)
})
```

## 最后
使用过程中如果有任何问题和建议都可以随时联系我，我的邮箱 344185723@qq.com
愿大家都可以开开心心的写代码！



