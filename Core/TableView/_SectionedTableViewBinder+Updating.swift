import UIKit

/// An enum indicating the scope of sections affected by an operation. For example, this enum answers the question
/// "We're binding models - what section(s) is it for?"
internal enum SectionBindingScope<S: TableViewSection> {
    case forNamedSections([S])
    case forAllUnnamedSections
    case forAnySection
}

internal extension SectionedTableViewBinder {
    /**
     Updates the cell models and/or view models for the cells for either the given sections or 'any section'.
     
     - parameter models: The models (organized by section in a dictionary) to update to.
     - parameter viewModels: The view models (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateCellModels(_ models: [S: [Any]]?, viewModels: [S: [Any]]?, affectedSections: SectionBindingScope<S>) {
        guard let modelsOrViewModels = models ?? viewModels else {
            assertionFailure("Both the 'models' and 'view models' arrays were nil")
            return
        }
        
        // mark that the affected sections were updated via models and view model
        let type: _TableViewSectionDataModel<S>.CellDataType
        if models != nil && viewModels != nil {
            type = .modelsViewModels
        } else if models != nil {
            type = .models
        } else {
            type = .viewModels
        }
        let dataTypes: [S: _TableViewSectionDataModel<S>.CellDataType] = modelsOrViewModels.mapValues { _ in type }
        for (section, cellDataType) in dataTypes {
            self.nextDataModel.sectionModel(for: section).cellDataType = cellDataType
        }

        var items: [S: [_TableViewItemModel]] = [:]
        if let models = models, let viewModels = viewModels {
            items = models.reduce(into: [:]) { result, value in
                let (section, _models) = value
                guard let _viewModels = viewModels[section] else { fatalError("something weird weird") }
                result[section] = zip(_models, _viewModels).map { _TableViewItemModel(isNumberPlaceholder: false, model: $0, viewModel: $1) }
            }
        } else if let models = models {
            items = models.mapValues { _models in
                return _models.map { _TableViewItemModel(isNumberPlaceholder: false, model: $0, viewModel: nil) }
            }
        } else if let viewModels = viewModels {
            items = viewModels.mapValues { _viewModels in
                return _viewModels.map { _TableViewItemModel(isNumberPlaceholder: false, model: nil, viewModel: $0) }
            }
        }
        
        self.update(fromDataIn: items,
                    resettingMissingSectionsWith: [],
                    updatingKeyPath: \_TableViewSectionDataModel<S>.items,
                    affectedSections: affectedSections,
                    dataType: .cell)
    }
    
    /**
     Updates the number of manually created cells for either the given sections or 'any section'.
     
     - parameter numCells: The number of cells (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateNumberOfCells(_ numCells: [S: Int], affectedSections: SectionBindingScope<S>) {
        // mark that the affected sections were updated via a 'number of cells'
        for section in numCells.keys {
            self.nextDataModel.sectionModel(for: section).cellDataType = .number
        }

        let items: [S: [_TableViewItemModel]] = numCells.mapValues { numberOfCells in
            return (0..<numberOfCells).map { _ in
                return _TableViewItemModel(isNumberPlaceholder: true, model: nil, viewModel: nil)
            }
        }
        self.update(fromDataIn: items,
                    resettingMissingSectionsWith: [],
                    updatingKeyPath: \_TableViewSectionDataModel<S>.items,
                    affectedSections: affectedSections,
                    dataType: .cell)
    }
    
    /**
     Updates the titles for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateHeaderTitles(_ titles: [S: String?], affectedSections: SectionBindingScope<S>) {
        self.nextDataModel.headerTitleBound = true
        
        switch affectedSections {
        case .forNamedSections(let sections):
            self.nextDataModel.uniquelyBoundHeaderSections.append(contentsOf: sections)
        default: break
        }
        
        self.update(fromDataIn: titles,
                    resettingMissingSectionsWith: nil,
                    updatingKeyPath: \_TableViewSectionDataModel<S>.headerTitle,
                    affectedSections: affectedSections,
                    dataType: .header)
    }
    
    /**
     Updates the view models for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateHeaderViewModels(_ viewModels: [S: Any?], affectedSections: SectionBindingScope<S>) {
        self.nextDataModel.headerViewBound = true
        
        self.update(fromDataIn: viewModels,
                    resettingMissingSectionsWith: nil,
                    updatingKeyPath: \_TableViewSectionDataModel<S>.headerViewModel,
                    affectedSections: affectedSections,
                    dataType: .header)
    }
    
    /**
     Updates the titles for the footers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateFooterTitles(_ titles: [S: String?], affectedSections: SectionBindingScope<S>) {
        self.nextDataModel.footerTitleBound = true
        
        switch affectedSections {
        case .forNamedSections(let sections):
            self.nextDataModel.uniquelyBoundFooterSections.append(contentsOf: sections)
        default: break
        }
        
        self.update(fromDataIn: titles,
                    resettingMissingSectionsWith: nil,
                    updatingKeyPath: \_TableViewSectionDataModel<S>.footerTitle,
                    affectedSections: affectedSections,
                    dataType: .footer)
    }
    
    /**
     Updates the view models for the header for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateFooterViewModels(_ viewModels: [S: Any?], affectedSections: SectionBindingScope<S>) {
        self.nextDataModel.footerViewBound = true
        
        let nonNilViewModels: [S: Any] = viewModels.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilViewModels,
                    resettingMissingSectionsWith: nil,
                    updatingKeyPath: \_TableViewSectionDataModel<S>.footerViewModel,
                    affectedSections: affectedSections,
                    dataType: .footer)
    }
}

private extension SectionedTableViewBinder {
    enum DataUpdateType {
        case cell
        case header
        case footer
    }
    
    func update<V>(
        fromDataIn new: [S: V],
        resettingMissingSectionsWith resetValue: V,
        updatingKeyPath keyPath: ReferenceWritableKeyPath<_TableViewSectionDataModel<S>, V>,
        affectedSections: SectionBindingScope<S>,
        dataType: DataUpdateType)
    {
        switch affectedSections {
        case .forNamedSections(let sections):
            // If the new values are for specific named sections, simply iterate over the given sections and set the
            // value for the section in the reference to the 'current' data model to the data for the section in 'new'.
            for section in sections {
                let newValue = new[section] ?? resetValue
                let sectionModel = self.nextDataModel.sectionModel(for: section)
                sectionModel[keyPath: keyPath] = newValue
            }
            
            // mark either the cells or header/footers for the affected sections as dirty so they're reloaded
            switch dataType {
            case .cell:
                self.nextDataModel.cellUpdatedSections = self.nextDataModel.cellUpdatedSections.union(sections)
            case .header, .footer:
                self.nextDataModel.headerFooterUpdatedSections =
                    self.nextDataModel.headerFooterUpdatedSections.union(sections)
            }
            
        case .forAllUnnamedSections:
            /*
             If we're binding for dynamic, unnamed sections, we assume that the data in the 'new' dict given is the
             'state of the table' for any section not explicitly bound with the 'onSection' or 'onSections' methods. So,
             if a models/VMs array isn't included for a section in the titles/VMs dict, that section doesn't have any
             cells.
             
             Because explicitly bound sections have priority, we don't want to overwrite the models/VMs for a section
             that wasn't given if that section *was* bound uniquely by name. So, we create a 'sections to iterate' set
             of all the sections to update data for from the 'updateDict' object. This set is the union of the keys on
             the 'current' (i.e. the ref to the dictionary of data on the current 'next data model') and the 'new' (to
             add any new sections not accounted for), which then has the 'uniquely bound sections' subtracted from it.
             */
            var sectionsToIterate: Set<S> = Set(self.currentDataModel.sectionModels.map { $0.section })
            sectionsToIterate.formUnion(new.keys)
            
            let uniquelyBoundSections: [S]
            switch dataType {
            case .cell: uniquelyBoundSections = self.nextDataModel.uniquelyBoundCellSections
            case .header: uniquelyBoundSections = self.nextDataModel.uniquelyBoundHeaderSections
            case .footer: uniquelyBoundSections = self.nextDataModel.uniquelyBoundFooterSections
            }
            
            sectionsToIterate.subtract(uniquelyBoundSections)
            for section in sectionsToIterate {
                guard uniquelyBoundSections.contains(section) == false else { continue }
                let newValue = new[section] ?? resetValue
                let sectionModel = self.nextDataModel.sectionModel(for: section)
                sectionModel[keyPath: keyPath] = newValue
            }
            
            // mark either the cells or header/footers for the affected sections as dirty so they're reloaded
            switch dataType {
            case .cell:
                self.nextDataModel.cellUpdatedSections = self.nextDataModel.cellUpdatedSections.union(sectionsToIterate)
            case .header, .footer:
                self.nextDataModel.headerFooterUpdatedSections =
                    self.nextDataModel.headerFooterUpdatedSections.union(sectionsToIterate)
            }
        case .forAnySection:
            assertionFailure("Data binding not supported for 'any section' - internal error")
        }
    }
}
