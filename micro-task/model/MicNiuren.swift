import UIKit

struct NewsModel: Codable {
    var retCode: String?
    var errCode: String?
    var errMsg: String?
    var data: Result?
}

struct Result: Codable {
    var list: [MicNiuren]?
}

struct MicNiuren: Codable {
    var id: Int?
    var nickname: String?
    var avatar: String?
    var gender: Int?
    var mobile: String?
    var email: String?
    var create_time: String?
    var login_time: String?
    var college: String?
    var words: String?
    var residence: String?
    var background: String?
    var rcoinNum: Int? 
}
