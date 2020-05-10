import UIKit

import UIKit
import HandyJSON

class MicDemandCategory: HandyJSON {
    required init() {}
    var id: Int?
    var name: String?
    var parent_id: String?
    var logo: String?
    var create_time: String?
}

class MicDemandCategoryData: HandyJSON {
    var list: [MicDemandCategory]?
    required init() {}
}
