import RxSwift

/**
 A model object containing information about a musical artist.
 */
struct Artist: Hashable {
    let name: String
    
    /// The first letter of the artist, accounting for articles.
    var firstLetter: String {
        let nameNoArticle: String
        if self.name.lowercased().starts(with: "the ") {
            nameNoArticle = String(self.name.dropFirst(4))
        } else if self.name.lowercased().starts(with: "a ") {
            nameNoArticle = String(self.name.dropFirst(2))
        } else if self.name.lowercased().starts(with: "an ") {
            nameNoArticle = String(self.name.dropFirst(3))
        } else {
            nameNoArticle = self.name
        }
        
        return String(nameNoArticle.first!)
    }
}

/**
 An object that makes mock network requests to fetch a list of artists for a user.
 */
class MusicLibraryService {
    static let shared = MusicLibraryService()
    
    private var allArtists: [Artist] = [
        Artist(name: "Louis-Jean Cormier"),
        Artist(name: "Lisa Leblanc"),
        Artist(name: "Led Zepplin"),
        Artist(name: "Metric"),
        Artist(name: "Fat Larry's Band"),
        Artist(name: "Tame Impala"),
        Artist(name: "Animal Collective"),
        Artist(name: "Coldplay"),
        Artist(name: "Stromae"),
        Artist(name: "Queens of the Stone Age"),
        Artist(name: "Queen"),
        Artist(name: "The Police"),
        Artist(name: "Of Monsters and Men"),
        Artist(name: "Clean Bandit"),
        Artist(name: "Nirvana"),
        Artist(name: "Oasis"),
        Artist(name: "Foo Fighters"),
        Artist(name: "Muse"),
        Artist(name: "Mounties"),
        Artist(name: "k-os"),
        Artist(name: "Kanye West"),
        Artist(name: "Kendrick Lamar"),
        Artist(name: "Heart"),
        Artist(name: "Hollerado"),
        Artist(name: "Half Moon Run"),
        Artist(name: "Car Seat Headrest"),
        Artist(name: "Fleetwood Mac"),
        Artist(name: "Finger Eleven"),
        Artist(name: "Feist"),
        Artist(name: "Ed Sheeran"),
        Artist(name: "Elton John"),
        Artist(name: "AC/DC"),
        Artist(name: "Led"),
        Artist(name: "Dido"),
        Artist(name: "Digitalism"),
        Artist(name: "Crystal Castles"),
        Artist(name: "Post Malone"),
        Artist(name: "City and Colour"),
        Artist(name: "Bombay Bicycle Club"),
        Artist(name: "Big Data"),
        Artist(name: "Alabama Shakes"),
        Artist(name: "Yuna"),
        Artist(name: "U2"),
        Artist(name: "Two Door Cinema Club"),
        Artist(name: "Tokyo Police Club"),
        Artist(name: "A Tribe Called Quest"),
        Artist(name: "Phantogram"),
        Artist(name: "Pearl Jam"),
        Artist(name: "Passion Pit"),
        Artist(name: "Paramore"),
        Artist(name: "My Chemical Romance"),
        Artist(name: "Nelly Furtado"),
        Artist(name: "Norah Jones"),
        Artist(name: "Niel Young"),
        Artist(name: "Otis Redding"),
        Artist(name: "The Strokes"),
        Artist(name: "Soundgarden"),
        Artist(name: "The Notorious B.I.G."),
        Artist(name: "The Beatles"),
        Artist(name: "Sharpest"),
        Artist(name: "Sixpence None The Richer"),
        Artist(name: "Shakey Graves"),
        Artist(name: "Sarah McLachlan"),
        Artist(name: "Rise Against"),
        Artist(name: "Regina Spektor"),
        Artist(name: "Radiohead"),
        Artist(name: "System of a Down")
    ]
    
    func getArtists() -> Observable<[Artist]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500)) {
                var artists: [Artist] = []
                for _ in 0..<self.allArtists.count / 5 * 4 {
                    let i = Int.random(in: 0..<self.allArtists.count)
                    artists.append(self.allArtists[i])
                }
                let artistsSet = Set<Artist>(artists)
                observer.onNext(Array(artistsSet))
                observer.onCompleted()
            }
            
            return Disposables.create()
        })
    }
}
