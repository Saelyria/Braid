import Braid

class FormData {
    var title: String?
    var location: String?
    
    var isAllDay: Bool = false
    var date: Date? = Date()
    var startTime: Date? = Date()
    var endTime: Date? = Date(timeInterval: 86400, since: Date())
    
    var url: String?
    var notes: String?
}


enum FormItem: CollectionIdentifiable, Equatable {
    case title(String?)
    case location(String?)
    
    case isAllDay(Bool)
    case date(Date?)
    case datePicker
    case startTime(Date?)
    case startTimePicker
    case endTime(Date?)
    case endTimePicker
    
    case url(String?)
    case notes(String?)
    
//    enum CellModel {
//        case titleDetail(title: String, detail: String?)
//        case textField(title: String, enteredText: String?)
//        case toggle(title: String, isOn: Bool)
//        case textView(placeholder: String, numberOfLines: Int)
//        case datePicker(includeTime: Bool)
//    }
    
    var collectionId: String {
        switch self {
        case .title(_): return "title"
        case .location(_): return "location"
        case .isAllDay(_): return "isAllDay"
        case .date(_): return "date"
        case .datePicker: return "datePicker"
        case .startTime(_): return "startTime"
        case .startTimePicker: return "startTimePicker"
        case .endTime(_): return "endTime"
        case .endTimePicker: return "endTimePicker"
        case .url(_): return "url"
        case .notes(_): return "notes"
        }
    }
    
    static func == (lhs: FormItem, rhs: FormItem) -> Bool {
        switch (lhs, rhs) {
        case let (.title(lhsValue), .title(rhsValue)):
            return lhsValue == rhsValue
        case let (.location(lhsValue), .location(rhsValue)):
            return lhsValue == rhsValue
        case let (.isAllDay(lhsValue), .isAllDay(rhsValue)):
            return lhsValue == rhsValue
        case let (.date(lhsValue), .date(rhsValue)):
            return lhsValue == rhsValue
        case (.datePicker, .datePicker):
            return true
        case let (.startTime(lhsValue), .startTime(rhsValue)):
            return lhsValue == rhsValue
        case (.startTimePicker, .startTimePicker):
            return true
        case let (.endTime(lhsValue), .endTime(rhsValue)):
            return lhsValue == rhsValue
        case (.endTimePicker, .endTimePicker):
            return true
        case let (.url(lhsValue), .url(rhsValue)):
            return lhsValue == rhsValue
        case let (.notes(lhsValue), .notes(rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}
