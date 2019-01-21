import RxSwift

/**
 A model object containing info on a user's account.
 */
struct Account {
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
}

/**
 An object that makes mock network requests to fetch a list of accounts for a user.
 */
class AccountsService {
    static let shared = AccountsService()
    
    private var i: Int = 0
    private var responses: [[Account]] = [
        [
            Account(accountName: "Every Day Checking", accountNumber: "123***123", balance: 2305.82, type: .checking),
            Account(accountName: "High-Interest Savings", accountNumber: "719***810", balance: 105.45, type: .savings),
            Account(accountName: "High-Interest Savings", accountNumber: "905***001", balance: 10613.19, type: .savings)
        ],
        [
            Account(accountName: "US Checking", accountNumber: "018***789", balance: 105.45, type: .checking),
            Account(accountName: "Travel Rewards Visa", accountNumber: "658***778", balance: 310.67, type: .creditCard),
            Account(accountName: "Money-Back Rewards Mastercard", accountNumber: "978***223", balance: 45.81, type: .creditCard)
        ],
        [
            Account(accountName: "Travel Rewards Visa", accountNumber: "658***778", balance: 310.67, type: .creditCard)
        ],
        [
            Account(accountName: "High-Interest Savings", accountNumber: "719***810", balance: 105.45, type: .savings),
            Account(accountName: "High-Interest Savings", accountNumber: "905***001", balance: 10613.19, type: .savings),
            Account(accountName: "US Checking", accountNumber: "018***789", balance: 105.45, type: .checking),
            Account(accountName: "Travel Rewards Visa", accountNumber: "658***778", balance: 310.67, type: .creditCard),
            Account(accountName: "Money-Back Rewards Mastercard", accountNumber: "978***223", balance: 45.81, type: .creditCard),
            Account(accountName: "Trading Account", accountNumber: "143***100", balance: 15054.01, type: .investing)
        ]
    ]
    
    func getAccounts() -> Observable<[Account]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                
                observer.onNext(self.responses[self.i])
                observer.onCompleted()
                
                self.i+=1
                if self.i > self.responses.count-1 {
                    self.i = 0
                }
            }
            
            return Disposables.create()
        })
    }
}
