import UIKit

/**
 An object used to continue a binding chain.
 
 This is a throwaway object created when a table view binder's `onSections(_:)` method is called. This object declares a
 number of methods that take a binding handler and give it to the original table view binder to store for callback. A
 reference to this object should not be kept and should only be used in a binding chain.
 */
public class TableViewModelMultiSectionBinder<C: UITableViewCell, S: TableViewSection, M>
    : TableViewMutliSectionBinder<C, S>
{ 
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C, _ model: M) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let tappedHandler: CellTapCallback<S> = {  [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C,
            let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell or model wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.handlers.sectionCellTappedCallbacks[section] = tappedHandler
            }
        } else {
            self.binder.handlers.dynamicSectionsCellTappedCallback = tappedHandler
        }

        return self
    }
    
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C, _ model: M) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        let dequeueCallback: CellDequeueCallback<S> = { [weak binder = self.binder] (section, row, cell) in
            guard let cell = cell as? C,
            let model = binder?.currentDataModel.sectionCellModels[section]?[row] as? M else {
                assertionFailure("ERROR: Cell wasn't the right type; something went awry!")
                return
            }
            handler(section, row, cell, model)
        }
        
        if let sections = self.sections {
            for section in sections {
                self.binder.handlers.sectionCellDequeuedCallbacks[section] = dequeueCallback
            }
        } else {
            self.binder.handlers.dynamicSectionsCellDequeuedCallback = dequeueCallback
        }

        return self
    }
    
    @discardableResult
    public override func bind<H>(
        headerType: H.Type,
        viewModels: [S : H.ViewModel],
        updatedWith updateHandler: ((([S : H.ViewModel]) -> Void) -> Void)?)
        -> TableViewModelMultiSectionBinder<C, S, M>
        where H : UITableViewHeaderFooterView & ReuseIdentifiable & ViewModelBindable
    {
        super.bind(headerType: headerType, viewModels: viewModels)
        return self
    }
    
    @discardableResult
    public override func bind(
        headerTitles: [S : String],
        updateWith updateHandler: ((([S : String]) -> Void) -> Void)?)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(headerTitles: headerTitles, updateWith: updateHandler)
        return self
    }
    
    @discardableResult
    public override func bind<F>(
        footerType: F.Type,
        viewModels: [S : F.ViewModel],
        updatedWith updateHandler: ((([S : F.ViewModel]) -> Void) -> Void)?)
        -> TableViewModelMultiSectionBinder<C, S, M>
        where F : UITableViewHeaderFooterView & ReuseIdentifiable & ViewModelBindable
    {
        super.bind(footerType: footerType, viewModels: viewModels, updatedWith: updateHandler)
        return self
    }
    
    @discardableResult
    public override func bind(
        footerTitles: [S : String],
        updateWith updateHandler: ((([S : String]) -> Void) -> Void)?)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.bind(footerTitles: footerTitles, updateWith: updateHandler)
        return self
    }
    
    @discardableResult
    public override func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.onCellDequeue(handler)
        return self
    }
    
    @discardableResult
    public override func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        super.onTapped(handler)
        return self
    }
    
    @discardableResult
    public func dimensions(_ dimensions: MultiSectionModelDimension<S, M>...)
        -> TableViewModelMultiSectionBinder<C, S, M>
    {
        self._dimensions(dimensions)
        return self
    }
}
