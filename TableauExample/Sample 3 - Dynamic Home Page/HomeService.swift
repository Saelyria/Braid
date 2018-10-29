import RxSwift

struct HomePageSection {
    let title: String
    let modelType: ModelType
    let footer: String?
    let footerRoute: String?
    
    enum ModelType {
        case products([Product])
        case stores([Store])
    }
}

class HomeService {
    static let shared = HomeService()

    /// Fetches the content for the home page, divided into 'home page section' models.
    func getHomePage() -> Observable<[HomePageSection]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500)) {
                
                observer.onNext([])
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
}
