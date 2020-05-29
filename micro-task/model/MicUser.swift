//
//  MicUser.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/14.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import HandyJSON

class MicUser: HandyJSON {
    var id: Int? // ID
    var nickname: String? // 昵称
    var avatar: String? // 头像
    var gender: Int? // 性别
    var mobile: String? // 手机号码
    var email: String? // 邮箱
    var create_time: String? // 创建时间
    var login_time: String? // 登录时间
    var college: String? // 毕业院校
    var words: String? // 个人介绍
    var residence: String? // 居住地
    var background: String? // 主页背景
    var token: String? // 登录密码

    required init() {}
}
