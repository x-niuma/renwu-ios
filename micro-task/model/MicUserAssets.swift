//
//  MicUser.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/14.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import HandyJSON

class MicUserAssets: HandyJSON {
    var followNum: Int? // 关注数
    var collectNum: Int? // 收藏数
    var likeNum: Int? // 点赞数
    var pointNum: Int? // 积分数
    var rcoinNum: Int? // 成就

    required init() {}
}
