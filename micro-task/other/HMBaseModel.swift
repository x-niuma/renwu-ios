//
//  HMBaseModel.swift
//  SwiftTest
//
//  Created by 小莲吴 on 2020/3/17.
//  Copyright © 2020 小莲吴. All rights reserved.
//

import UIKit
import ObjectiveC

@objcMembers class HMBaseModel: NSObject,NSCoding {
    let kArchivePath = KDocuments + NSStringFromClass(object_getClass(self)!)
    
    required override init(){
        super.init()
    }
    init(object: Any?) {
        super.init()
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
    }
    
    // MARK: coding
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        for name in self.propertyList() ?? [] {
            self.setValue(aDecoder.decodeObject(forKey: name ), forKey: name )
        }
    }
    
    func encode(with aCoder: NSCoder) {
        for name in self.propertyList() ?? [] {
            aCoder.encode(self.value(forKey: name ), forKey: name )
        }
    }
    
    // MARK: - Public
    func archive() {
        let className = NSStringFromClass(object_getClass(self) ?? AnyClass.self as! AnyClass)
        let archivePath = NSHomeDirectory() + "/Documents/"+className
        if #available(iOS 11.0, *) {
            if let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false) {
                try? archivedData.write(to: NSURL.fileURL(withPath: archivePath))
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    //归档
    class func unarchive() -> Self {
        let className = NSStringFromClass(object_getClass(self) ?? AnyClass.self as! AnyClass)
        let archivePath = NSHomeDirectory() + "/Documents/"+className
        if let archivedData = try? Data(contentsOf: NSURL.fileURL(withPath: archivePath)) {
            if let archiveObj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedData)  as? Self {
                return archiveObj
            } else {
                return self.init()
            }
        }
        return self.init()
        
    }
    func removeArchive() -> Bool {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: kArchivePath) {
            do {
                try fileManager.removeItem(atPath: kArchivePath)
            } catch {
            }
        }
        return false
    }
    
    
    //反射机制objc_property_t获取属性列表
    func propertyList() -> [String]? {
        var propertyCount: UInt32 = 0
        let propertyList = class_copyPropertyList(self.classForCoder, &propertyCount)
        var propertyNames: [String] = []
        for i in 0..<Int(propertyCount) {
            
            let property = propertyList?[Int(i)]
            var name: String? = nil
            if let property = property {
                name = String(utf8String: property_getName(property))
            }
            propertyNames.append(name ?? "")
        }
        return propertyNames
        
    }
    
}
