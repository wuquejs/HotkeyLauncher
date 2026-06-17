import Foundation

enum ShortcutStatus: Equatable {
    case registered
    case disabled
    case missingApplication
    case duplicate
    case conflict(Int32)
    case error(Int32)

    var title: String {
        switch self {
        case .registered:
            return "已启用"
        case .disabled:
            return "已停用"
        case .missingApplication:
            return "应用缺失"
        case .duplicate:
            return "重复"
        case .conflict:
            return "冲突"
        case .error:
            return "错误"
        }
    }

    var detail: String {
        switch self {
        case .registered:
            return "已注册，正在监听"
        case .disabled:
            return "快捷键已停用"
        case .missingApplication:
            return "应用路径不存在"
        case .duplicate:
            return "另一个已启用快捷方式使用了相同按键"
        case .conflict(let code):
            return "macOS 拒绝注册此热键，状态码 \(code)"
        case .error(let code):
            return "注册失败，状态码 \(code)"
        }
    }
}
