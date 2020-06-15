//
//  MicPerson.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/12.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit

class MicPerson: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true; // 是否使用安全归档
    
    // 编码(对象转 data)
    func encode(with coder: NSCoder) {
        coder.encode(nickname, forKey: "nickname")
        coder.encode(avatar, forKey: "avatar")
        coder.encode(words, forKey: "words")
        coder.encode(mobile, forKey: "mobile")
        coder.encode(token, forKey: "token")
        coder.encode(email, forKey: "email")
    }
    
    // 解码(data 转对象)
    required init?(coder: NSCoder) {
        super.init()
        nickname = coder.decodeObject(forKey: "nickname") as? String
        avatar = coder.decodeObject(forKey: "avatar") as? String
        words = coder.decodeObject(forKey: "words") as? String
        mobile = coder.decodeObject(forKey: "mobile") as? String
        token = coder.decodeObject(forKey: "token") as? String
        email = coder.decodeObject(forKey: "email") as? String
    }
    
    var nickname: String? // 用户昵称
    var avatar: String? // 头像地址
    var words: String? // 用户介绍
    var mobile: String? // 电话号码
    var token: String? // 电话号码
    var email: String? // 电子邮箱
    
    override init() {
        
    }
}
