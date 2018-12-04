import UIKit
import RxSwift

struct NewsItem: Decodable {
    let title: String
    let shortSummary: String
    let isAd: Bool
}

class NewsFeedService {
    static let shared = NewsFeedService()
    
    private lazy var newsItems: [NewsItem] = {
        var newsItems: [NewsItem] = []
        if let path = Bundle.main.path(forResource: "news-items", ofType: "json"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
            let parsedNewsItems = try? JSONDecoder().decode([NewsItem].self, from: data) {
            newsItems = parsedNewsItems
        }
        return newsItems
    }()
    
    func getNewsFeed(startingFrom: Int, numberOfItems: Int) -> Observable<[NewsItem]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500)) {
                var items: [NewsItem] = []
                for _ in 0..<numberOfItems {
                    let item = self.newsItems[Int.random(in: 0..<self.newsItems.count)]
                    items.append(item)
                }
 
                observer.onNext(items)
                observer.onCompleted()
            }
            
            return Disposables.create()
        })

    }
}
