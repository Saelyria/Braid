import Tableau

final class CenterLabelTableViewCell: UITableViewCell, ViewModelBindable, ReuseIdentifiable {
    typealias ViewModel = String
    
    var viewModel: CenterLabelTableViewCell.ViewModel? {
        didSet {
            self.centerLabel.text = self.viewModel
        }
    }
    
    private let centerLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    private func setup() {
        self.addSubview(self.centerLabel)
        self.centerLabel.numberOfLines = 0
        self.centerLabel.font = UIFont.systemFont(ofSize: 12)
        self.centerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[l]-20-|", options: [], metrics: nil, views: ["l": self.centerLabel]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|-20-[l]-20-|", options: [], metrics: nil, views: ["l": self.centerLabel]))
    }
}
