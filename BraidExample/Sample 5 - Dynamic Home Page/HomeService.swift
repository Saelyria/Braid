import RxSwift

struct HomePageSectionContent {
    let title: String
    let models: Models
    let footer: String?
    let footerRoute: String?
    
    enum Models {
        case products([Product])
        case stores([Store])
    }
}

class HomeService {
    static let shared = HomeService()

    /// Fetches the content for the home page, divided into 'home page section' models.
    func getHomePage() -> Observable<[HomePageSectionContent]> {
        return Observable.create({ observer in
            var content: [HomePageSectionContent] = []
            if let path = Bundle.main.path(forResource: "mock-home-response", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let parsedContent = try? JSONDecoder().decode([HomePageSectionContent].self, from: data) {
                content = parsedContent
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
                observer.onNext(content)
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
}

extension HomePageSectionContent: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
        case products
        case stores
        case footerText
        case footerRoute
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.title = try container.decode(String.self, forKey: .title)
        
        if let products = try container.decodeIfPresent([Product].self, forKey: .products) {
            self.models = .products(products)
        } else if let stores = try container.decodeIfPresent([Store].self, forKey: .stores) {
            self.models = .stores(stores)
        } else {
            throw DecodingError.keyNotFound(CodingKeys.stores, DecodingError.Context(codingPath: [], debugDescription: ""))
        }
        self.footer = try container.decodeIfPresent(String.self, forKey: .footerText)
        self.footerRoute = try container.decodeIfPresent(String.self, forKey: .footerRoute)
    }
}

