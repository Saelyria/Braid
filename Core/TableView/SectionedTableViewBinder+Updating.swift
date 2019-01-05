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
        guard let items = models ?? viewModels else {
            assertionFailure("Both the 'models' and 'view models' arrays were nil")
            return
        }
        
        // mark that the affected sections were updated via models and view model
        let type: _TableViewDataModel<S>.CellDataType
        if models != nil && viewModels != nil {
            type = .modelsViewModels
        } else if models != nil {
            type = .models
        } else {
            type = .viewModels
        }
        let dataTypes: [S: _TableViewDataModel<S>.CellDataType] = items.mapValues { _ in type }
        self.update(fromDataIn: dataTypes,
                    updatingProperty: &self.nextDataModel.sectionCellDataType,
                    affectedSections: affectedSections,
                    dataType: .cell)
        
        if let models = models {
            self.update(fromDataIn: models,
                        updatingProperty: &self.nextDataModel.sectionCellModels,
                        affectedSections: affectedSections,
                        dataType: .cell)
        }
        if let viewModels = viewModels {
            self.update(fromDataIn: viewModels,
                        updatingProperty: &self.nextDataModel.sectionCellViewModels,
                        affectedSections: affectedSections,
                        dataType: .cell)
        }
    }
    
    /**
     Updates the number of manually created cells for either the given sections or 'any section'.
     
     - parameter numCells: The number of cells (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateNumberOfCells(_ numCells: [S: Int], affectedSections: SectionBindingScope<S>) {
        // mark that the affected sections were updated via a 'number of cells'
        let dataTypes: [S: _TableViewDataModel<S>.CellDataType] = numCells.mapValues { _ in .number }
        self.update(fromDataIn: dataTypes,
                    updatingProperty: &self.nextDataModel.sectionCellDataType,
                    affectedSections: affectedSections,
                    dataType: .cell)
        
        self.update(fromDataIn: numCells,
                    updatingProperty: &self.nextDataModel.sectionNumberOfCells,
                    affectedSections: affectedSections,
                    dataType: .cell)
    }
    
    /**
     Updates the titles for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateHeaderTitles(_ titles: [S: String?], affectedSections: SectionBindingScope<S>) {
        let nonNilTitles: [S: String] = titles.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilTitles,
                    updatingProperty: &self.nextDataModel.sectionHeaderTitles,
                    affectedSections: affectedSections,
                    dataType: .header)
    }
    
    /**
     Updates the view models for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateHeaderViewModels(_ viewModels: [S: Any?], affectedSections: SectionBindingScope<S>) {
        let nonNilViewModels: [S: Any] = viewModels.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilViewModels,
                    updatingProperty: &self.nextDataModel.sectionHeaderViewModels,
                    affectedSections: affectedSections,
                    dataType: .header)
    }
    
    /**
     Updates the titles for the footers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateFooterTitles(_ titles: [S: String?], affectedSections: SectionBindingScope<S>) {
        let nonNilTitles: [S: String] = titles.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilTitles,
                    updatingProperty: &self.nextDataModel.sectionFooterTitles,
                    affectedSections: affectedSections,
                    dataType: .footer)
    }
    
    /**
     Updates the view models for the header for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter affectedSections: The section scope affected by this update.
     */
    func updateFooterViewModels(_ viewModels: [S: Any?], affectedSections: SectionBindingScope<S>) {
        let nonNilViewModels: [S: Any] = viewModels.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilViewModels,
                    updatingProperty: &self.nextDataModel.sectionFooterViewModels,
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
    
    /**
     Updates a dictionary on the binder's `nextDataModel` to the given values for the given section.
     
     - parameter new: The dictionary containing values to update the 'next data model' with.
     - parameter current: A pointer to the dictionary property on the binder's `nextDataModel` that gets updated
        with the values from the 'new' dictionary.
     - parameter affectedSections: The section scope affected by this update.
     - parameter dataType: The type of data being updated (cell, header, or footer).
    */
    func update<V>(
        fromDataIn new: [S: V],
        updatingProperty current: inout [S: V],
        affectedSections: SectionBindingScope<S>,
        dataType: DataUpdateType)
    {
        switch affectedSections {
        case .forNamedSections(let sections):
            // If the new values are for specific named sections, simply iterate over the given sections and set the
            // value for the section in the reference to the 'current' data model to the data for the section in 'new'.
            for section in sections {
                current[section] = new[section]
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
            var sectionsToIterate = Set<S>(current.keys)
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
                current[section] = new[section]
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
