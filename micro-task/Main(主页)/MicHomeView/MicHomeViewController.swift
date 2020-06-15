import UIKit
import Alamofire
import SnapKit

class MicHomeViewController: VTMagicController {
    
    var _menuList: [String] = [String]()
    var menuList: [MicDemandCategory]?
    var navHeight: CGFloat = 40.0
    var searchHeight: CGFloat = 34.0
    
    func addHeader() {
        // 添加搜索入口按钮
        let sEntrybtn  = UIButton()
        sEntrybtn.backgroundColor = UIColor.hex("#f5f5f9");
        sEntrybtn.layer.cornerRadius = searchHeight / 2
        sEntrybtn.layer.masksToBounds = true
        self.magicView.headerView.addSubview(sEntrybtn);
        sEntrybtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kIsIPhoneX ? kStatusbarHeight + 8 : kStatusbarHeight + 8)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(searchHeight)
        }
        sEntrybtn.addTarget(self, action: #selector(gotoSearch), for: .touchUpInside)
        
        // 添加搜索提示
        let searchText = UILabel()
        searchText.text = "搜索关键字"
        sEntrybtn.addSubview(searchText)
        searchText.textColor = UIColor.hex("#888b8e");
        searchText.font = UIFont.systemFont(ofSize: 12);
        searchText.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(30)
        }
        
        // 添加搜索ICON
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "search")
        sEntrybtn.addSubview(searchIcon)
        searchIcon.snp.makeConstraints { (make) in
            make.width.equalTo(14)
            make.height.equalTo(14)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
    }
    
    @objc func gotoSearch() {
        micro_task.gotoSearch(currentVC: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addHeader();
        // self.navigationController?.tabBarController?.selectedIndex = 3;
        
        self.navigationItem.title = "需求池"
        self.magicView.isHeaderHidden = false;
        self.magicView.headerHeight = kIsIPhoneX ? kNavBarAndStatusBarHeight : kNavBarAndStatusBarHeight;
        self.magicView.navigationHeight = navHeight;
        self.magicView.itemScale = 1.1;
        
        self.magicView.sliderColor = UIColor.hex("#f59304")
        self.magicView.layoutStyle = .default
        self.magicView.switchStyle = .default
        
        self.magicView.dataSource = self
        self.magicView.delegate = self
        
        // 获取导航菜单
        self.getMenuList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func getMenuList() {
        AF.request(getProjectCategory).responseString { response in
            if let _value = response.value {
                if let _res = MicBaseResponse<MicDemandCategoryData>.deserialize(from: _value) {
                    self.menuList = (_res.data?.list)
                    var _menuList: [String] = [String]()
                    if let menuList = self.menuList {
                        for (_, element) in menuList.enumerated() {
                            _menuList.append(element.name ?? "");
                        }
                    }
                    self._menuList = _menuList
                    self.magicView.reloadData()
                }
            }
        }
    }
}

extension MicHomeViewController  {
    
    override func menuTitles(for magicView: VTMagicView) -> [String] {
        return _menuList
    }
    
    // item 对应的标题
    override func magicView(_ magicView: VTMagicView, menuItemAt itemIndex: UInt) -> UIButton {
        let itemIdentifier = "itemIdentifier"
        var menuItem = magicView.dequeueReusableItem(withIdentifier: itemIdentifier)
        if menuItem == nil {
            menuItem = UIButton(type: .custom)
            menuItem?.setTitleColor(UIColor.hex("#999999"), for: .normal)
            menuItem?.setTitleColor(UIColor.hex("#000000"), for: .selected)
            menuItem?.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        }
        return menuItem!
    }
    
    // item 对应的主体内容
    override func magicView(_ magicView: VTMagicView, viewControllerAtPage pageIndex: UInt) -> UIViewController {
        let gridViewController = MicDemandTableViewController()
        let categoryId = self.menuList![Int(pageIndex)].id!
        gridViewController.appTypeId = categoryId
        return gridViewController
    }
    
    // 设置 slider 宽度
    override func magicView(_ magicView: VTMagicView, sliderWidthAt itemIndex: UInt) -> CGFloat {
        // let frame = self.magicView.menuItem(at: itemIndex)
        let data = self._menuList[Int(itemIndex) as Int]
        return 15.0 * CGFloat((data.count / 2))
    }
}
