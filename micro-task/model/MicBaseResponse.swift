//
//  MicBaseResponse.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/14.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import HandyJSON

// 假设这是服务端返回的统一定义的 response 格式
class MicBaseResponse<T: HandyJSON>: HandyJSON {
    var retCode: String?
    var errCode: String?
    var errMsg: String?
    var data: T? // 具体的data的格式和业务相关，故用泛型定义
    public required init() {}
}
