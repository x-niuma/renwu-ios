//
//  MicNiurenTableViewCell2.swift
//  micro-task
//
//  Created by arraybuffer on 2020/5/1.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import SnapKit

class MicNiurenTableViewCell2: UITableViewCell {
    var vc: UIViewController!
    var itemData: MicNiuren!

    lazy var nickname: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.hex("#000")
        return label
    }()
    
    lazy var words: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = UIColor.hex("#8a8a8a")
        label.numberOfLines = 0
        return label
    }()
    
    lazy var sort: UILabel = {
        let label = UILabel()
        label.text = "1"
        label.backgroundColor = UIColor.purple
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.hex("#8a8a8a")
        label.textAlignment = .center
        label.backgroundColor = badgeCOlor
        return label
    }()
    
    lazy var chatBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("向他咨询", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        btn.setTitleColor(UIColor.hex("#8a8a8a"), for: .normal)
        btn.layer.borderColor = UIColor.hex("#8a8a8a").cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        return btn
    }()
    
    lazy var TLine: UIView = {
       let v = UIView()
        v.backgroundColor = UIColor.hex("#f5f5f5")
        return v
    }()
    
    lazy var avatarView: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(UIColor.hex("#a8a8a8"), for: .normal)
        btn.layer.cornerRadius = 4
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var rcoinNum: UILabel = {
        let v = UILabel()
        v.text = "成就：0"
        v.font = UIFont.systemFont(ofSize: 12)
        v.textColor = UIColor.hex("#8a8a8a")
        return v
    }()
    
    lazy var mainView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.white
        return v
    }()
    
    // 给 cell 设置数据
    func setupData(item: MicNiuren, index: Int) {
        self.nickname.text = item.nickname;
        self.sort.text = String(index + 1)
        self.words.text = item.words ?? "这个人很懒什么也没说～"
        if (item.rcoinNum != nil) {
            self.rcoinNum.text = "成就：\(item.rcoinNum!)"
        }
        
        // let urlPath = "http://c1.airtlab.com/图片1.jpg"; 为啥用这个头像会失败
        if let avatar = item.avatar {
            let url = URL(string: avatar)
            if let url = url {
                self.avatarView.kf.setImage(with: url, for: .normal)
            } else {
                print(avatar)
            }
        }
    }
    
    @objc func handleChat() {
        micro_task.gotoChatItem(currentVC: vc, niuren: itemData)
    }
    
    override func layoutSubviews () {
        super.layoutSubviews()
        var frame = contentView.frame
        frame.origin.x += 10
        frame.size.width -= 20
        contentView.frame = frame
        self.backgroundColor = lineColor
    }
    
    private func makeInitSubviews() {
        contentView.backgroundColor = UIColor.hex("#f5f5f5")
        contentView.addSubview(TLine)
        contentView.addSubview(sort)
        contentView.addSubview(mainView)
        
        mainView.addSubview(avatarView)
        mainView.addSubview(nickname)
        mainView.addSubview(words)
        mainView.addSubview(chatBtn)
        mainView.addSubview(rcoinNum)
    }
    
    private func makeInitLayout () {
        TLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(10)
        }
        sort.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.width.height.equalTo(20)
            make.top.equalToSuperview().offset(10)
        }
        mainView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.bottom.right.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        avatarView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.width.height.equalTo(45)
            make.top.equalToSuperview().offset(10)
        }
        nickname.snp.makeConstraints { (make) in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        words.snp.makeConstraints { (make) in
            make.left.equalTo(avatarView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.top.equalTo(nickname.snp.bottom).offset(12)
        }
        rcoinNum.snp.makeConstraints { (make) in
            make.leading.equalTo(words)
            make.top.equalTo(words.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-12)
        }
        chatBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(22)
            make.width.equalTo(56)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init? (coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        makeInitSubviews()
        makeInitLayout()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
}
