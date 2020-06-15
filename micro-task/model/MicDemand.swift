//  MicProject.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/4.
//  Copyright © 2020 airtim. All rights reserved.
//  需求对象数据模型

import UIKit
import HandyJSON

// 假设这是某一个业务具体的数据格式定义
class MicDemand: HandyJSON {
    required init() {}
    // 字段定义
    var id: Int? // ID
    var title: String? // 标题
    var description: String? // 描述
    var reward: Int? // 赏金
    // var imgs: String?
    var createTime: String? // 创建时间
    // var update_time: String? // 更新时间
    var requires: String? // 技能要求
    var appType: String? // 应用类型
    var projectType: String? // 项目类型
    var appTypeId: Int? // 项目类型ID
    var projectTypeId: Int? // 应用类型ID
    var userId: Int? // 发布者用户ID
    var userInfo: MicUser? // 发布者信息
    var enrollList: [Any]? // 报名列表
}

class MicDemandData: HandyJSON {
    var pageInfo: MicPageInfo?
    var list: [MicDemand]?
    required init() {}
}

class MicPageInfo: HandyJSON {
    var pageSize: Int?
    var pageIndex: Int?
    var total: Int?
    required init() {}
}
