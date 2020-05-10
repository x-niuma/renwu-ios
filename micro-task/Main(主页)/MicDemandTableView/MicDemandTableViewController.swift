//
//  MicNiurenTableViewController.swift
//  micro-task
//
//  Created by arraybuffer on 2020/4/6.
//  Copyright © 2020 airtim. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit

class MicDemandTableViewController: UITableViewController {
    
    var demandList: [MicDemand] = []
    var pageInfo: MicPageInfo? = nil
    var header = MJRefreshNormalHeader() // 下拉刷新
    var footer = MJRefreshAutoNormalFooter() // 上拉加载
    var pageSize = 10
    var pageIndex = 1
    var appTypeId = 1
    var loading = false
    
    lazy var noDataView: UIView = {
       let v = UIView()
        v.isHidden = true
        return v
    }()
    
    lazy var kongImage: UIImageView = {
        let v = UIImageView()
        v.image = UIImage(named: "kong")?.withRenderingMode(.alwaysTemplate)
        v.tintColor = UIColor.hex("#bdc0c5")
        return v
    }()
    
    private func makeInitSubviews() {
        noDataView.addSubview(kongImage)
        view.addSubview(noDataView)
    }
    
    private func makeInitLayout() {
        noDataView.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(100)
            // make.size.equalToSuperview()
            make.center.equalToSuperview()
        }
        kongImage.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        makeInitSubviews()
        
        let nib = UINib(nibName: "MicDemandTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "demand_cell")
        self.tableView.rowHeight = 210;
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top:0, left: 0, bottom: 10, right: 0);
        self.tableView.backgroundColor = lineColor
        // self.tableView.showsVerticalScrollIndicator = false;
        
        // 下面3行防止页面抖动
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        // 下拉刷新
        header.setRefreshingTarget(self, refreshingAction: #selector(self.handleRefresh))
        header.setTitle("下拉刷新", for: .idle)
        header.setTitle("正在刷新", for: .refreshing)
        header.setTitle("即将刷新", for: .willRefresh)
        header.setTitle("释放刷新", for: .pulling)
        header.lastUpdatedTimeLabel?.isHidden = true // 隐藏上一次刷新时间
        header.stateLabel?.textColor = UIColor.hex("#666666")
        header.stateLabel?.font = UIFont.systemFont(ofSize: 13)
        self.tableView.mj_header = header

        // 上拉加载
        footer.setRefreshingTarget(self, refreshingAction: #selector(self.handleLoadMore))
        footer.isHidden = true
        footer.setTitle("上拉加载", for: .idle)
        footer.setTitle("正在加载", for: .refreshing)
        footer.setTitle("我也是有底线的", for: .noMoreData)
        footer.setTitle("释放加载", for: .pulling)
        footer.setTitle("正在加载", for: .refreshing)
        footer.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        footer.stateLabel?.textColor = UIColor.hex("#bdc0c5")
        self.tableView.mj_footer = footer
        
        // 触发刷新
        self.tableView.mj_header?.beginRefreshing {
            self.getTableList()
        }
        
        makeInitLayout()
    }
    
    // 下拉刷新
    @objc func handleRefresh() {
        self.getTableList()
    }
    
    // 上拉加载
    @objc func handleLoadMore() {
        print("handleLoadMore")
        self.pageIndex += 1
        // tableView.mj_footer?.isHidden = false
        // if (self)
        self.tableView.mj_footer!.beginRefreshing()
        self.loadMoreFn()
    }
    
    // 获取需求列表
    func getTableList() {
        pageIndex = 1
        let querys = "?pageIndex=\(pageIndex)&pageSize=\(pageSize)&appTypeId=\(appTypeId)"
        AF.request(getDemandListUrl + querys).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<MicDemandData>.deserialize(from: _value) {
                    self.demandList = (_res.data?.list)!
                    self.tableView.reloadData()
                    self.tableView.mj_header?.endRefreshing()
                    let localTotal = self.demandList.count
                    let romoteTotal = _res.data?.pageInfo?.total! ?? 0
                    self.tableView.mj_footer?.isHidden = !(localTotal < romoteTotal)
                    if (localTotal >= romoteTotal) {
                        self.tableView.mj_footer?.isHidden = false
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        if (self.demandList.count == 0) {
                            self.noDataView.isHidden = false
                            self.tableView.mj_footer?.isHidden = true
                        } else {
                            self.noDataView.isHidden = true
                            self.tableView.mj_footer?.isHidden = false
                        }
                    } else {
                        self.tableView.mj_footer?.resetNoMoreData()
                    }
                 }
            }
        }
    }
    
    func loadMoreFn() {
        let querys = "?pageIndex=\(pageIndex)&pageSize=\(pageSize)&appTypeId=\(appTypeId)"
        AF.request(getDemandListUrl + querys).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<MicDemandData>.deserialize(from: _value) {
                    self.demandList = self.demandList + (_res.data?.list)!
                    self.tableView.reloadData()
                    self.tableView.mj_footer?.endRefreshing()
                    let localTotal = self.demandList.count
                    let romoteTotal = _res.data?.pageInfo?.total! ?? 0
                    if (localTotal >= romoteTotal) {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                 }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.demandList.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demand_cell", for: indexPath) as! MicDemandTableViewCell;
        let data: MicDemand = self.demandList[indexPath.row]
        cell.setupData(demand: data, index: indexPath.row)
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dataItem: MicDemand = (self.demandList[indexPath.row])
        micro_task.gotoDemandDetail(currentVC: self, demandInfo: dataItem)
    }
}
