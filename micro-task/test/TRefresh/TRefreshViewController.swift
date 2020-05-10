import UIKit

class TRefreshViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var items:[String]!
    var tableView:UITableView?

    override func loadView() {
        super.loadView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshItemData()
        self.tableView = UITableView(frame: self.view.frame, style:.plain)
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
                
        self.view.addSubview(self.tableView!)

        //下拉刷新相关设置,使用闭包Block
        self.tableView!.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            sleep(2)
            //重现生成数据
            self.refreshItemData()
            //重现加载表格数据
            self.tableView!.reloadData()
            //结束刷新
            self.tableView!.mj_header?.endRefreshing()
        })
        
        let footer = MJRefreshAutoNormalFooter()
        footer.setRefreshingTarget(self, refreshingAction: #selector(self.loadMore))
        footer.setTitle("正在加载", for: .refreshing)
        footer.setTitle("我是有底线的", for: .noMoreData)
        
        self.tableView?.mj_footer = footer
    }
    
    @objc func loadMore() {
        print("hello world")
        let start = items.count
        let end = start + 20
        for index in start...end {
               items.append("条目\(index)")
           }
        self.tableView?.mj_footer?.endRefreshing()
        if (items.count > 80) {
            self.tableView?.mj_footer?.endRefreshingWithNoMoreData()
        }
//        self.tableView?.reloadData()
    }

    //初始化数据
    func refreshItemData() {
        items = []
        self.tableView?.mj_footer?.resetNoMoreData()
        for index in 0...20 {
            items.append("条目\(index)")
        }
    }

    //在本例中，只有一个分区
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    //返回表格行数（也就是返回控件数）
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }

    //创建各单元显示内容(创建参数indexPath指定的单元）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            let cell = UITableViewCell()
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.text = self.items[indexPath.row]
            return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
