//
//  MicNiurenTableViewCell.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/5.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Kingfisher

class MicNiurenTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var words: UILabel!
    @IBOutlet weak var sort: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 设置内边距
        var frame = contentView.frame
        // frame.origin.x = 10;
        // frame.size.width -= 10 * 2
        frame.origin.y += 10
        frame.size.height -= 10
        contentView.frame = frame
        // self.tableView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10
    }
    
    // 给 cell 设置数据
    func setupData(item: MicNiuren, index: Int) {
        // cell 设置
        self.backgroundColor = lineColor // 设置 cell 背景颜色
        
        // 昵称
        self.nickname.text = item.nickname;
        
        // 序号
        self.sort.text = String(index)
        self.sort.textAlignment = .center
        self.sort.textColor = UIColor.gray
        self.sort.backgroundColor = badgeCOlor
        self.sort.font = .systemFont(ofSize: 12)
        
        // 个人介绍
        self.words.textColor = UIColor.gray
        self.words.font = .systemFont(ofSize: 12)
        if item.words != nil {
            self.words.text = item.words!
        } else {
            self.words.text = "这个用户很懒啥也没说"
        }
        
        // 头像设置
        // let urlPath = "http://c1.airtlab.com/图片1.jpg"; 为啥用这个头像会失败
        if let avatar = item.avatar {
            let url = URL(string: avatar)
            if let url = url {
                self.avatar?.kf.setImage(with: url);
            } else {
                print(avatar)
            }
        }
    }
}
