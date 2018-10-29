import Tableau

class ImageTitleSubtitleTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel: CollectionIdentifiable {
        let id: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            
        }
    }
}
