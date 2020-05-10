//
//  MicNiurenTableViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/6.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Alamofire

class MicNiurenTableViewController: UITableViewController {
    
    var nuserList: [MicNiuren]?
    var cellName = "niuren_cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNUserList()
        
        self.tableView.contentInset = UIEdgeInsets(top:0, left: 0, bottom: 10, right: 0)
        self.tableView.separatorStyle = .none
        self.tableView.register(MicNiurenTableViewCell2.self, forCellReuseIdentifier: cellName)

        self.tableView.backgroundColor = lineColor
        
        self.tableView.estimatedRowHeight = 120;//估算高度
        self.tableView.rowHeight = UITableView.automaticDimension;
        
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "下拉刷新");
        refreshControl.tintColor = UIColor.gray
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged);
        self.tableView.refreshControl = refreshControl
    }
    
    @objc func loadData() {
        self.getNUserList()
    }
    
    // 获取牛人榜
    func getNUserList() {
        let url = "https://micro.airtlab.com/api/nuser"
        AF.request(url).responseJSON { response in
            if let resData = response.data {
                let decoder = JSONDecoder()
                do {
                    let model = try decoder.decode(NewsModel.self, from: resData)
                    self.nuserList = model.data?.list;
                    
                    if (self.tableView.refreshControl?.isRefreshing)! {
                        self.tableView.refreshControl?.endRefreshing()
                    }
                    self.tableView.reloadData()
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let list = self.nuserList {
            return list.count
        }
        return 0;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as? MicNiurenTableViewCell2
        if (cell == nil) {
            cell = MicNiurenTableViewCell2.init(style: .default, reuseIdentifier:cellName)
        }
        let data: MicNiuren = self.nuserList![indexPath.row]
        cell?.setupData(item: data, index: indexPath.row)
        cell?.itemData = data
        cell?.vc = self
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem = self.nuserList?[indexPath.row]
        micro_task.gotoNiurenDetail(currentVC: self, niurenInfo: dataItem!)
    }
}
