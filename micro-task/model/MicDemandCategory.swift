import UIKit

import UIKit
import HandyJSON

class MicDemandCategory: HandyJSON {
    required init() {}
    var id: Int?
    var name: String?
    var parentId: String?
    var logo: String?
    var createTime: String?
}

class MicDemandCategoryData: HandyJSON {
    var list: [MicDemandCategory]?
    required init() {}
}
