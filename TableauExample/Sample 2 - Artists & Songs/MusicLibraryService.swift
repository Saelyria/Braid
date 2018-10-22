//
//  ArtistsService.swift
//  TableauExample
//
//  Created by Aaron Bosnjak on 2018-10-18.
//  Copyright © 2018 AaronBosnjak. All rights reserved.
//

import RxSwift

class MusicLibraryService {
    static let shared = MusicLibraryService()
    
    private var i: Int = 0
    private var responses: [[Artist]] = [
        [
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
            Artist(name: "Led"),
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
            Artist(name: "System of a Down")
        ],
        [
            Artist(name: "Phantogram"),
            Artist(name: "Pearl Jam"),
            Artist(name: "Passion Pit"),
            Artist(name: "Paramore"),
            Artist(name: "My Chemical Romance"),
            Artist(name: "Nelly Furtado"),
            Artist(name: "Norah Jones"),
            Artist(name: "Coldplay"),
            Artist(name: "Stromae"),
            Artist(name: "Queens of the Stone Age"),
            Artist(name: "Queen"),
            Artist(name: "The Police"),
            Artist(name: "Of Monsters and Men"),
            Artist(name: "Clean Bandit"),
            Artist(name: "Nirvana"),
            Artist(name: "Oasis"),
            Artist(name: "Yuna"),
            Artist(name: "U2"),
            Artist(name: "Two Door Cinema Club"),
            Artist(name: "Tokyo Police Club")
        ],
        [
            Artist(name: "Nirvana"),
            Artist(name: "Oasis"),
            Artist(name: "Foo Fighters"),
            Artist(name: "Muse"),
            Artist(name: "Mounties"),
            Artist(name: "Bombay Bicycle Club"),
            Artist(name: "Big Data"),
            Artist(name: "Alabama Shakes"),
            Artist(name: "Yuna"),
            Artist(name: "Queens of the Stone Age"),
            Artist(name: "Stone Temple Pilots"),
            Artist(name: "Taylor Swift"),
            Artist(name: "The Strokes"),
            Artist(name: "Soundgarden"),
            Artist(name: "Queen"),
            Artist(name: "The Notorious B.I.G."),
            Artist(name: "Phoenix"),
            Artist(name: "Pink Floyd"),
            Artist(name: "Otis Redding"),
            Artist(name: "Major Lazer"),
            Artist(name: "Louis-Jean Cormier"),
            Artist(name: "Lisa Leblanc"),
            Artist(name: "Niel Young")
        ],
        [
            Artist(name: "The Beatles"),
            Artist(name: "k-os"),
            Artist(name: "Led"),
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
            Artist(name: "Soundgarden"),
            Artist(name: "Sharpest"),
            Artist(name: "Sixpence None The Richer"),
            Artist(name: "Shakey Graves"),
            Artist(name: "Sarah McLachlan"),
            Artist(name: "Rise Against"),
            Artist(name: "Regina Spektor"),
            Artist(name: "Radiohead"),
            Artist(name: "Tokyo Police Club")
        ]
    ]
    
    func getArtists() -> Observable<[Artist]> {
        return Observable.create({ observer in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500)) {
                
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
