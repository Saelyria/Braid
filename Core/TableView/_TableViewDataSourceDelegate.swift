import UIKit

/*
 These structs/protocols are used to effectively 'add' the 'height' and 'estimated height' delegate methods to the
 datasource/delegate object, as the table view has different behaviour for calculating heights for rows/headers/footers
 depending on whether or not the delegate responds to the methods. I know, it's weird.
 */
//struct EH_RHF: _EH_R, _EH_H, _EH_F { }
//struct EH_RH: _EH_R, _EH_H { }
//struct EH_RF: _EH_R, _EH_F { }
//struct EH_HF: _EH_H, _EH_F { }
//struct EH_R: _EH_R { }
//struct EH_H: _EH_H { }
//struct EH_F: _EH_F { }
//
//struct H_RHF: _H_R, _H_H, _H_F { }
//struct H_RH: _H_R, _H_H { }
//struct H_RF: _H_R, _H_F { }
//struct H_HF: _H_H, _H_F { }
//struct H_R: _H_R { }
//struct H_H: _H_H { }
//struct H_F: _H_F { }
//
//protocol _EH_R { }
//protocol _EH_H { }
//protocol _EH_F { }
//protocol _H_R { }
//protocol _H_H { }
//protocol _H_F { }

/// An internal class that acts as the de facto data source / delegate to a binder's table view.
//class _TableViewDataSourceDelegate<S: TableViewSection, H, EH>: NSObject, UITableViewDataSource, UITableViewDelegate {
class _TableViewDataSourceDelegate<S: TableViewSection>: NSObject, UITableViewDataSource, UITableViewDelegate {

    private weak var binder: SectionedTableViewBinder<S>!
//
//    init(binder: SectionedTableViewBinder<S>, heightOption: H.Type, estimatedHeightOption: EH.Type) {
//        self.binder = binder
//    }
    
    init(binder: SectionedTableViewBinder<S>) {
        self.binder = binder
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        let string = aSelector.description
        
        if aSelector == Selector(("tableView:estimatedHeightForRowAt:")) {
            let cellEstimatedHeightWasBound = !self.binder.sectionEstimatedCellHeightBlocks.isEmpty || self.binder.estimatedCellHeightBlock != nil
            return cellEstimatedHeightWasBound
        }
        
        if aSelector == Selector(("tableView:estimatedHeightForHeaderInSection:")) {
            let cellEstimatedHeightWasBound = !self.binder.sectionFooterEstimatedHeightBlocks.isEmpty || self.binder.footerEstimatedHeightBlock != nil
            return cellEstimatedHeightWasBound
        }
        
        return super.responds(to: aSelector)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.binder.displayedSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = self.binder.displayedSections[section]
        if let models = self.binder.currentDataModel.sectionCellModels[section] {
            return models.count
        } else if let viewModels = self.binder.currentDataModel.sectionCellViewModels[section] {
            return viewModels.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.binder.displayedSections[section]
        
        // don't return a title if the section has a header dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' header dequeue block
        if self.binder.sectionHeaderDequeueBlocks[section] != nil ||
        (!self.binder.currentDataModel.uniquelyBoundSections.contains(section) && self.binder.headerDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionHeaderTitles[section]
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let section = self.binder.displayedSections[section]
        
        // don't return a title if the section has a footer dequeue block specifically assigned or if the section
        // was not uniquely bound and there is an 'all sections' footer dequeue block
        if self.binder.sectionFooterDequeueBlocks[section] != nil ||
        (!self.binder.currentDataModel.uniquelyBoundSections.contains(section) && self.binder.footerDequeueBlock != nil) {
            return nil
        }
        return self.binder.currentDataModel.sectionFooterTitles[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.binder.displayedSections[indexPath.section]
        
        // We can't fall back to the 'all sections' cell dequeue block - might expect a different cell type.
        let _dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.sectionCellDequeueBlocks[section] : self.binder.cellDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return UITableViewCell() }

        let cell = dequeueBlock(section, tableView, indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection sectionInt: Int) -> UIView? {
        let section = self.binder.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' header dequeue block - might expect a different header type.
        let _dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.sectionHeaderDequeueBlocks[section] : self.binder.headerDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return nil }
        return dequeueBlock(tableView, sectionInt)
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection sectionInt: Int) -> UIView? {
        let section = self.binder.displayedSections[sectionInt]
        
        // We can't fall back to the 'all sections' footer dequeue block - might expect a different footer type.
        let _dequeueBlock = (self.binder.currentDataModel.uniquelyBoundSections.contains(section)) ?
            self.binder.sectionFooterDequeueBlocks[section] : self.binder.footerDequeueBlock
        guard let dequeueBlock = _dequeueBlock else { return nil }
        return dequeueBlock(tableView, sectionInt)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.binder.displayedSections[indexPath.section]
        guard let cell = tableView.cellForRow(at: indexPath),
        let callback = self.binder.sectionCellTappedCallbacks[section] ?? self.binder.cellTappedCallback else { return }
        callback(section, indexPath.row, cell)
    }
}

// MARK: Height extensions

//extension _TableViewDataSourceDelegate where H: _EH_R {
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = self.binder.displayedSections[indexPath.section]
//        if let estimatedHeightBlock = self.binder.sectionEstimatedCellHeightBlocks[section] ?? self.binder.estimatedCellHeightBlock {
//            return estimatedHeightBlock(indexPath.row)
//        }
//        return tableView.estimatedRowHeight
//    }
//}
//
//extension _TableViewDataSourceDelegate where H: _EH_H {
//    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection sectionInt: Int) -> CGFloat {
//        let section = self.binder.displayedSections[sectionInt]
//        if let heightBlock = self.binder.sectionHeaderEstimatedHeightBlocks[section] ?? self.binder.headerEstimatedHeightBlock {
//            return heightBlock()
//        }
//        return tableView.estimatedSectionHeaderHeight
//    }
//}
//
//extension _TableViewDataSourceDelegate where H: _EH_F {
//    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection sectionInt: Int) -> CGFloat {
//        let section = self.binder.displayedSections[sectionInt]
//        if let heightBlock = self.binder.sectionFooterEstimatedHeightBlocks[section] ?? self.binder.footerEstimatedHeightBlock {
//            return heightBlock()
//        }
//        return tableView.estimatedSectionFooterHeight
//    }
//}
//
//// MARK: Estimated height extensions
//
//extension _TableViewDataSourceDelegate where H: _H_R {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let section = self.binder.displayedSections[indexPath.section]
//        if let heightBlock = self.binder.sectionCellHeightBlocks[section] ?? self.binder.cellHeightBlock {
//            return heightBlock(indexPath.row)
//        }
//        return tableView.rowHeight
//    }
//}
//
//extension _TableViewDataSourceDelegate where H: _H_H {
//    func tableView(_ tableView: UITableView, heightForHeaderInSection sectionInt: Int) -> CGFloat {
//        let section = self.binder.displayedSections[sectionInt]
//        if let heightBlock = self.binder.sectionHeaderHeightBlocks[section] ?? self.binder.headerHeightBlock {
//            return heightBlock()
//        }
//        return tableView.sectionHeaderHeight
//    }
//}
//
//extension _TableViewDataSourceDelegate where H: _H_F {
//    func tableView(_ tableView: UITableView, heightForFooterInSection sectionInt: Int) -> CGFloat {
//        let section = self.binder.displayedSections[sectionInt]
//        if let heightBlock = self.binder.sectionFooterHeightBlocks[section] ?? self.binder.footerHeightBlock {
//            return heightBlock()
//        }
//        return tableView.sectionFooterHeight
//    }
//}

