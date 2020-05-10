//
//  MicExtend.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/15.
//  Copyright © 2020 airtim. All rights reserved.
//

import Foundation
import UIKit

// Mark String 扩展
extension String {

    /// 十六进制字符串颜色转为UIColor
    /// - Parameter alpha: 透明度
    func uicolor(alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt32 = 0, green: UInt32 = 0, blue: UInt32 = 0
        var hex = self
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6-hex.count {
                hex += "0"
            }
        }

        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt32(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt32(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(startIndex, offsetBy: 4)...])).scanHexInt32(&blue)

        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}

// Mark UIColor 扩展
extension UIColor {
    /// 以十六进制字符串颜色初始化UIColor
    /// - Parameter hexColor: 十六进制颜色
    /// - Parameter alpha: 透明度
    static func hex(_ hexColor: String, alpha: CGFloat = 1.0) -> UIColor {
        return hexColor.uicolor(alpha: 1.0)
    }
}


extension String {
    static func sizeWithString(string: String, width: CGFloat, font: UIFont) {
//        let rect = string.boundingRectWithSize(CGSizeMake(width, MAXFLOAT), context: <#NSStringDrawingContext?#>)
    }
}
