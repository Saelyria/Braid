import Tableau

class ImageTitleSubtitleTableViewCell: UITableViewCell, ReuseIdentifiable, ViewModelBindable {
    struct ViewModel: Identifiable {
        let id: String
    }
    
    var viewModel: ViewModel? {
        didSet {
            
        }
    }
}
