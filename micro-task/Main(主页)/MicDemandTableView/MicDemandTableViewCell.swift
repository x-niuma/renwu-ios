//
//  MicDemandTableViewCell.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/13.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Kingfisher

class MicDemandTableViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var projectType: UILabel!
    @IBOutlet weak var appType: UILabel!
    @IBOutlet weak var reward: UILabel!
    @IBOutlet weak var skill: UILabel!
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var authorNickname: UILabel!
    @IBOutlet weak var authorAvatar: UIImageView!
    @IBOutlet weak var rollNum: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var frame = contentView.frame
        frame.origin.y += 10
        frame.origin.x += 10
        frame.size.height -= 10
        frame.size.width -= 10 * 2
        contentView.frame = frame
        self.backgroundColor = lineColor
        self.contentView.backgroundColor = UIColor.white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func setupData (demand: MicDemand, index: Int) {
        self.contentView.layer.cornerRadius = 4;
        self.contentView.layer.masksToBounds = true;
        
        self.title.text = "\(index + 1). \(demand.title!)"
        self.appType.text = demand.appType!
        self.projectType.text = demand.projectType! + "任务"
        self.createTime.text = demand.createTime!
        self.skill.text = demand.requires!
        self.authorNickname.text = demand.userInfo?.nickname
        self.authorAvatar.kf.setImage(with: URL(string: (demand.userInfo?.avatar)!))
        self.authorAvatar.layer.cornerRadius = 14;
        self.authorAvatar.layer.masksToBounds = true;
        self.rollNum.text = "\((demand.enrollList?.count)!)人投标"
    }
}
