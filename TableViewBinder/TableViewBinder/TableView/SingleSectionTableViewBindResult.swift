import UIKit
import RxSwift

/**
 A throwaway object created when a table view binder's `onSection(_:)` method is called. This object declares a number
 of methodss that take a binding handler and give it to the original table view binder to store for callback.
 */
public class SingleSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection> {
    internal let binder: SectionedTableViewBinder<S>
    internal let section: S
    
    internal init(binder: SectionedTableViewBinder<S>, section: S) {
        self.binder = binder
        self.section = section
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models from a given observable.
    */
    @discardableResult
    public func bind<NC>(cellType: NC.Type, viewModels: Observable<[NC.ViewModel]>) -> SingleSectionTableViewBindResult<NC, S>
    where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        let section = self.section
        guard self.binder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        viewModels.subscribe(onNext: { [weak binder = self.binder] (viewModels: [NC.ViewModel]) in
            binder?.sectionCellViewModels[section] = viewModels
            binder?.reload(section: section)
        }).disposed(by: self.binder.disposeBag)
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections.value[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                cell.viewModel.value = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
        
        let tableViewBindResult = SingleSectionTableViewBindResult<NC, S>(binder: self.binder, section: self.section)
        return tableViewBindResult
    }
    
    /**
     Bind the given cell type to the declared sections, creating them based on the view models created from a given
     array of models mapped to view models by a given function.
    */
    @discardableResult
    public func bind<NC, NM>(cellType: NC.Type, models: Observable<[NM]>, mapToViewModelsWith mapToViewModel: @escaping (NM) -> NC.ViewModel)
    -> SingleSectionModelTableViewBindResult<NC, S, NM> where NC: UITableViewCell & ViewModelBindable & ReuseIdentifiable {
        let section = self.section
        guard self.binder.sectionCellDequeueBlocks[section] == nil else {
            fatalError("Section already has a cell type bound to it - re-binding not supported.")
        }
        
        models.subscribe(onNext: { [weak binder = self.binder] (models: [NM]) in
            binder?.sectionCellModels[section] = models
            binder?.sectionCellViewModels[section] = models.map(mapToViewModel)
            binder?.reload(section: section)
        }).disposed(by: self.binder.disposeBag)
        
        let cellDequeueBlock: CellDequeueBlock = { [weak binder = self.binder] (tableView, indexPath) in
            if let section = binder?.displayedSections.value[indexPath.section],
            let cell = binder?.tableView.dequeueReusableCell(withIdentifier: NC.reuseIdentifier, for: indexPath) as? NC,
            let viewModel = (binder?.sectionCellViewModels[section] as? [NC.ViewModel])?[indexPath.row] {
                cell.viewModel.value = viewModel
                binder?.sectionCellDequeuedCallbacks[section]?(indexPath.row, cell)
                return cell
            }
            return UITableViewCell()
        }
        self.binder.sectionCellDequeueBlocks[section] = cellDequeueBlock
        
        let tableViewBindResult = SingleSectionModelTableViewBindResult<NC, S, NM>(binder: self.binder, section: self.section)
        return tableViewBindResult
    }
    
    /**
     Bind the given header type to the declared section with the given observable for their view models.
    */
    @discardableResult
    public func bind<H>(headerType: H.Type, viewModel: Observable<H.ViewModel>) -> SingleSectionTableViewBindResult<C, S>
    where H: UITableViewHeaderFooterView & ViewModelBindable & ReuseIdentifiable {
        guard self.binder.sectionHeaderDequeueBlocks[section] == nil else {
            print("WARNING: Section already has a header type bound to it - re-binding not supported.")
            return self
        }
        
        viewModel.subscribe(onNext: { [weak binder = self.binder] (viewModel: H.ViewModel) in
            binder?.sectionHeaderViewModels[self.section] = viewModel
            binder?.reload(section: self.section)
        }).disposed(by: self.binder.disposeBag)
        
        let headerDequeueBlock: HeaderDequeueBlock = { [weak binder = self.binder] (tableView, sectionInt) in
            if let section = binder?.displayedSections.value[sectionInt],
                let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: H.reuseIdentifier) as? H,
                let viewModel = binder?.sectionHeaderViewModels[section] as? H.ViewModel {
                header.viewModel.value = viewModel
                return header
            }
            return nil
        }
        self.binder.sectionHeaderDequeueBlocks[section] = headerDequeueBlock
        
        return self
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared section.
    */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ row: Int, _ dequeuedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        let dequeueCallback: CellDequeueCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellDequeuedCallbacks[section] = dequeueCallback
        
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared section is tapped.
    */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        let tappedHandler: CellTapCallback = { row, cell in
            guard let cell = cell as? C else { fatalError("Cell wasn't the right type; something went awry!") }
            handler(row, cell)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
    
    /**
     Add a callback handler to provide the cell height for cells in the declared section.
    */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionCellHeightBlocks[section] = handler
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared section.
    */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ row: Int) -> CGFloat) -> SingleSectionTableViewBindResult<C, S> {
        self.binder.sectionEstimatedCellHeightBlocks[section] = handler
        return self
    }
}

public class SingleSectionModelTableViewBindResult<C: UITableViewCell, S: TableViewSection, M>: SingleSectionTableViewBindResult<C, S> {
    @discardableResult
    public func onTapped(_ handler: @escaping (_ row: Int, _ tappedCell: C, _ model: M) -> Void) -> SingleSectionTableViewBindResult<C, S> {
        let section = self.section
        let tappedHandler: CellTapCallback = {  [weak binder = self.binder] row, cell in
            guard let cell = cell as? C, let model = binder?.sectionCellModels[section]?[row] as? M else {
                fatalError("Cell or model wasn't the right type; something went awry!")
            }
            handler(row, cell, model)
        }
        
        self.binder.sectionCellTappedCallbacks[section] = tappedHandler
        return self
    }
}
