import UIKit

class MicNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // navigationItem
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.navigationItem.leftBarButtonItem = returnItem
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    lazy var returnItem: UIBarButtonItem = {
        let button = UIButton.init(type: UIButton.ButtonType.custom)
        button.setImage(UIImage.init(named: "arrow_back"), for: .normal)
        button.setImage(UIImage.init(named: "arrow_back"), for: .highlighted)
        button.frame = .init(x: 0, y: 0, width: 20, height: 20)
        button.contentEdgeInsets = .init(top: 0, left: -10, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(onActionReturn), for: .touchUpInside)
        let item = UIBarButtonItem.init(customView: button)
        return item
    }()
    
    @objc func onActionReturn() {
        popViewController(animated: true)
    }
}
