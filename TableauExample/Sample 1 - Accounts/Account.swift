import Tableau

struct Account: Identifiable {
    enum AccountType {
        case checking
        case savings
        case investing
        case creditCard
    }
    
    let accountName: String
    let accountNumber: String
    let balance: Double
    let type: AccountType
    
    var id: String { return self.accountNumber }
}
