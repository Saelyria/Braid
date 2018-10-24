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
    func updateCellModels(_ models: [S: [Identifiable]]?, viewModels: [S: [Identifiable]]?, sections: [S]?) {
        // If we were given the sections to update, simply iterate over the given sections to update them.
        if let sections = sections {
            for section in sections {
                if let models = models {
                    self.nextDataModel.sectionCellModels[section] = models[section]
                }
                if let viewModels = viewModels {
                    self.nextDataModel.sectionCellViewModels[section] = viewModels[section]
                }
            }
        } else {
            /*
             If we're binding for 'any section' (i.e. the 'sections' array was nil), we assume that the models/VMs array
             dict given is the 'state of the table' for any section not explicitly bound with the 'onSection' or
             'onSections' methods. So, if a models/VMs array isn't included for a section in the titles/VMs dict, that
             section doesn't have any cells.
             
             Because explicitly bound sections have priority, we don't want to overwrite the models/VMs for a section
             that wasn given if that section *was* bound uniquely by name.
             */
            if let models = models {
                // create a set of sections to update by adding sections already with models to the ones being added,
                // then subtract the sections that were 'uniquely' bound
                var sectionsToIterate = Set<S>(self.nextDataModel.sectionCellModels.keys)
                sectionsToIterate.formUnion(models.keys)
                sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                for section in sectionsToIterate {
                    guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                    self.nextDataModel.sectionCellModels[section] = models[section]
                }
            }
            if let viewModels = viewModels {
                // create a set of sections to update by adding sections already with view models to the ones being
                // added, then subtract the sections that were 'uniquely' bound
                var sectionsToIterate = Set<S>(self.nextDataModel.sectionCellViewModels.keys)
                sectionsToIterate.formUnion(viewModels.keys)
                sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                for section in sectionsToIterate {
                    guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                    self.nextDataModel.sectionCellViewModels[section] = viewModels[section]
                }
            }
        }
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
        self.updateHeaderOrFooterTitlesOrViewModels(titles: titles, viewModels: nil, isHeader: true, sections: sections)
    }
    
    /**
     Updates the view models for the headers for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the models are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateHeaderViewModels(_ viewModels: [S: Identifiable?], sections: [S]?) {
        self.updateHeaderOrFooterTitlesOrViewModels(titles: nil, viewModels: viewModels, isHeader: true, sections: sections)
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
        self.updateHeaderOrFooterTitlesOrViewModels(titles: titles, viewModels: nil, isHeader: false, sections: sections)
    }
    
    /**
     Updates the view models for the header for either the given sections or 'any section'.
     
     - parameter titles: The titles (organized by section in a dictionary) to update to.
     - parameter sections: The sections the models are for. Single- or multi-section binders should pass in their
        'section(s)' property for this argument. If this parameter is nil, the data is assumed to be for the 'any
        sections' entry (i.e. data that is used to populate sections not explicitly bound with the `onSection` or
        `onSections` methods on the binder).
     */
    func updateFooterViewModels(_ viewModels: [S: Identifiable?], sections: [S]?) {
        self.updateHeaderOrFooterTitlesOrViewModels(titles: nil, viewModels: viewModels, isHeader: false, sections: sections)
    }
}

private extension SectionedTableViewBinder {
    func updateHeaderOrFooterTitlesOrViewModels(
        titles: [S: String?]?,
        viewModels: [S: Identifiable?]?,
        isHeader: Bool,
        sections: [S]?)
    {
        // If we were given the sections to update, simply iterate over the given sections to update them.
        if let sections = sections {
            for section in sections {
                if isHeader {
                    if let titles = titles {
                        self.nextDataModel.sectionHeaderTitles[section] = titles[section] ?? nil
                    } else if let viewModels = viewModels {
                        self.nextDataModel.sectionHeaderViewModels[section] = viewModels[section] ?? nil
                    }
                } else {
                    if let titles = titles {
                        self.nextDataModel.sectionFooterTitles[section] = titles[section] ?? nil
                    } else if let viewModels = viewModels {
                        self.nextDataModel.sectionFooterViewModels[section] = viewModels[section] ?? nil
                    }
                }
            }
        } else {
            /*
             If we're binding for 'any section' (i.e. the 'sections' array was nil), we assume that the titles/VMs
             dict given is the 'state of the table' for any section not explicitly bound with the 'onSection' or
             'onSections' methods. So, if a title/VM isn't included for a section in the titles/VMs dict, that
             section doesn't have a header/footer.
             
             Because explicitly bound sections have priority, we don't want to overwrite the title/VM for a section
             that wasn given if that section *was* bound uniquely by name.
             */
            if isHeader {
                if let titles = titles {
                    // create a set of sections to update by adding sections already with titles to the ones being
                    // added, then subtract the sections that were 'uniquely' bound
                    var sectionsToIterate = Set<S>(self.nextDataModel.sectionHeaderTitles.keys)
                    sectionsToIterate.formUnion(titles.keys)
                    sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                    for section in sectionsToIterate {
                        guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                        self.nextDataModel.sectionHeaderTitles[section] = titles[section] ?? nil
                    }
                } else if let viewModels = viewModels {
                    // create a set of sections to update by adding sections already with view models to the ones being
                    // added, then subtract the sections that were 'uniquely' bound
                    var sectionsToIterate = Set<S>(self.nextDataModel.sectionHeaderViewModels.keys)
                    sectionsToIterate.formUnion(viewModels.keys)
                    sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                    for section in sectionsToIterate {
                        guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                        self.nextDataModel.sectionHeaderViewModels[section] = viewModels[section] ?? nil
                    }
                }
            } else {
                if let titles = titles {
                    // create a set of sections to update by adding sections already with titles to the ones being
                    // added, then subtract the sections that were 'uniquely' bound
                    var sectionsToIterate = Set<S>(self.nextDataModel.sectionFooterTitles.keys)
                    sectionsToIterate.formUnion(titles.keys)
                    sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                    for section in sectionsToIterate {
                        guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                        self.nextDataModel.sectionFooterTitles[section] = titles[section] ?? nil
                    }
                } else if let viewModels = viewModels {
                    // create a set of sections to update by adding sections already with titles to the ones being
                    // added, then subtract the sections that were 'uniquely' bound
                    var sectionsToIterate = Set<S>(self.nextDataModel.sectionFooterViewModels.keys)
                    sectionsToIterate.formUnion(viewModels.keys)
                    sectionsToIterate.subtract(self.nextDataModel.uniquelyBoundSections)
                    for section in sectionsToIterate {
                        guard self.nextDataModel.uniquelyBoundSections.contains(section) == false else { continue }
                        self.nextDataModel.sectionFooterViewModels[section] = viewModels[section] ?? nil
                    }
                }
            }
        }
    }
}
