import UIKit

internal extension SectionedTableViewBinder {
    /**
     Updates the cell models and/or view models for the cells for either the given sections or 'any section'.
     
     - parameter models: The models (organized by section in a dictionary) to update to.
     - parameter viewModels: The view models (organized by section in a dictionary) to update to.
     - parameter sections: The sections the titles are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateCellModels(_ models: [S: [Any]]?, viewModels: [S: [Any]]?, sections: [S]?) {
        guard !(models == nil && viewModels == nil) else {
            assertionFailure("Both the 'models' and 'view models' arrays were nil")
            return
        }
        
        if let models = models {
            self.update(fromDataIn: models, updatingProperty: &self.nextDataModel.sectionCellModels, sections: sections)
        }
        if let viewModels = viewModels {
            self.update(fromDataIn: viewModels, updatingProperty: &self.nextDataModel.sectionCellViewModels, sections: sections)
        }
    }
    
    /**
     Updates the number of manually created cells for either the given sections or 'any section'.
     
     - parameter numCells: The number of cells (organized by section in a dictionary) to update to.
     - parameter sections: The sections the titles are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateNumberOfCells(_ numCells: [S: Int], sections: [S]?) {
        self.update(fromDataIn: numCells, updatingProperty: &self.nextDataModel.sectionNumberOfCells, sections: sections)
    }
    
    /**
     Updates the titles for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the titles are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateHeaderTitles(_ titles: [S: String?], sections: [S]?) {
        let nonNilTitles: [S: String] = titles.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilTitles, updatingProperty: &self.nextDataModel.sectionHeaderTitles, sections: sections)
    }
    
    /**
     Updates the view models for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the models are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateHeaderViewModels(_ viewModels: [S: Any?], sections: [S]?) {
        let nonNilViewModels: [S: Any] = viewModels.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilViewModels, updatingProperty: &self.nextDataModel.sectionHeaderViewModels, sections: sections)
    }
    
    /**
     Updates the titles for the footers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the titles are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateFooterTitles(_ titles: [S: String?], sections: [S]?) {
        let nonNilTitles: [S: String] = titles.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilTitles, updatingProperty: &self.nextDataModel.sectionFooterTitles, sections: sections)
    }
    
    /**
     Updates the view models for the header for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the models are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateFooterViewModels(_ viewModels: [S: Any?], sections: [S]?) {
        let nonNilViewModels: [S: Any] = viewModels.filter { $0.value != nil }.mapValues { return $0! }
        self.update(fromDataIn: nonNilViewModels, updatingProperty: &self.nextDataModel.sectionFooterViewModels, sections: sections)
    }
}

private extension SectionedTableViewBinder {
    /**
     Updates a dictionary on the binder's `nextDataModel` to the given values for the given section.
     
     - parameter new: The dictionary containing values to update the 'next data model' with.
     - parameter current: A pointer to the dictionary property on the binder's `nextDataModel` that gets updated
        with the values from the 'new' dictionary.
     - parameter sections: The sections the models are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'dynamic
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
    */
    func update<V>(fromDataIn new: [S: V], updatingProperty current: inout [S: V], sections: [S]?) {
        // If we were given the sections to update, simply iterate over the given sections and set the value for the
        // section in the reference to the 'current' data model to the data for the section in 'new'.
        if let sections = sections {
            for section in sections {
                current[section] = new[section]
            }
        } else {
            /*
             If we're binding for 'dynamic sections' (i.e. the 'sections' array was nil), we assume that the data in the
             'new' dict given is the 'state of the table' for any section not explicitly bound with the 'onSection' or
             'onSections' methods. So, if a models/VMs array isn't included for a section in the titles/VMs dict, that
             section doesn't have any cells.
             
             Because explicitly bound sections have priority, we don't want to overwrite the models/VMs for a section
             that wasn't given if that section *was* bound uniquely by name. So, we create a 'sections to iterate' set
             of all the sections to update data for from the 'updateDict' object. This set is the union of the keys on
             the 'current' (i.e. the ref to the dictionary of data on the current 'next data model') and the 'new' (to
             add any new sections not accounted for), which then has the 'uniquely bound sections' subtracted from it.
             */
            var sectionsToIterate = Set<S>(current.keys)
            sectionsToIterate.formUnion(new.keys)
            sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
            for section in sectionsToIterate {
                guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                current[section] = new[section]
            }
        }
    }
}
