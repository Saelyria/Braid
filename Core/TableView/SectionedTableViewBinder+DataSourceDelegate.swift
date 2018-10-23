//
//  SectionedTableViewBinder+DataSourceDelegate.swift
//  Tableau
//
//  Created by Aaron Bosnjak on 2018-10-23.
//  Copyright © 2018 AaronBosnjak. All rights reserved.
//
/*
import UIKit

extension SectionedTableViewBinder {
    func createDataSource() -> (UITableViewDataSource & UITableViewDelegate) {
        let rowHeight = !self.sectionCellHeightBlocks.isEmpty || self.cellHeightBlock != nil
        let headerHeight = !self.sectionHeaderHeightBlocks.isEmpty || self.headerHeightBlock != nil
        let footerHeight = !self.sectionFooterHeightBlocks.isEmpty || self.footerHeightBlock != nil
        let rowEstimatedHeight = !self.sectionEstimatedCellHeightBlocks.isEmpty || self.estimatedCellHeightBlock != nil
        let headerEstimatedHeight = !self.sectionHeaderEstimatedHeightBlocks.isEmpty || self.headerEstimatedHeightBlock != nil
        let footerEstimatedHeight = !self.sectionFooterEstimatedHeightBlocks.isEmpty || self.footerEstimatedHeightBlock != nil
        
//        let heightOption: Any
        if rowHeight && headerHeight && footerHeight {
            heightOption = H_RHF()
        } else if rowHeight && headerHeight {
            heightOption = H_RH()
        } else if rowEstimatedHeight && footerEstimatedHeight {
            heightOption = H_RF()
        } else if headerEstimatedHeight && footerEstimatedHeight {
            heightOption = H_HF()
        } else if rowEstimatedHeight {
            heightOption = H_R()
        } else if headerEstimatedHeight {
            heightOption = H_F()
        } else {
            heightOption = ()
        }
        
//        let estimatedHeightOption: Any
        if rowHeight && headerHeight && footerHeight {
            estimatedHeightOption = EH_RHF()
        } else if rowHeight && headerHeight {
            estimatedHeightOption = EH_RH()
        } else if rowEstimatedHeight && footerEstimatedHeight {
            estimatedHeightOption = EH_RF()
        } else if headerEstimatedHeight && footerEstimatedHeight {
            estimatedHeightOption = EH_HF()
        } else if rowEstimatedHeight {
            estimatedHeightOption = EH_R()
        } else if headerEstimatedHeight {
            estimatedHeightOption = EH_F()
        } else {
            estimatedHeightOption = ()
        }
        
        let dataSourceDelegate = _TableViewDataSourceDelegate(binder: self, heightOption: H_RHF.self, estimatedHeightOption: Void.self)
        return dataSourceDelegate
//        let dataSourceDelegate = _TableViewDataSourceDelegate(binder: self, heightOption: type(of: heightOption), estimatedHeightOption: type(of: estimatedHeightOption))
    }
    
//    func createDataSourceDelegate() {
//        let rowHeight = !self.sectionCellHeightBlocks.isEmpty || self.cellHeightBlock != nil
//        let headerHeight = !self.sectionHeaderHeightBlocks.isEmpty || self.headerHeightBlock != nil
//        let footerHeight = !self.sectionFooterHeightBlocks.isEmpty || self.footerHeightBlock != nil
//        let rowEstimatedHeight = !self.sectionEstimatedCellHeightBlocks.isEmpty || self.estimatedCellHeightBlock != nil
//        let headerEstimatedHeight = !self.sectionHeaderEstimatedHeightBlocks.isEmpty || self.headerEstimatedHeightBlock != nil
//        let footerEstimatedHeight = !self.sectionFooterEstimatedHeightBlocks.isEmpty || self.footerEstimatedHeightBlock != nil
//
//        // All 'heights' bound, no 'estimated heights' bound
//        if rowHeight && headerHeight && footerHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, Void>(binder: self)
//        } else if rowHeight && headerHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, Void>(binder: self)
//        } else if rowEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, Void>(binder: self)
//        } else if headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, Void>(binder: self)
//        } else if rowEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, Void>(binder: self)
//        } else if headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, Void>(binder: self)
//        }
//
//        // All 'heights' bound, '
//        else if rowHeight && headerHeight && footerHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, EH_RHF>(binder: self)
//        } else if rowHeight && headerHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, EH_RHF>(binder: self)
//        } else if rowEstimatedHeight && footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, EH_RHF>(binder: self)
//        } else if headerEstimatedHeight && footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, EH_RHF>(binder: self)
//        } else if rowEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, EH_RHF>(binder: self)
//        } else if headerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_H, EH_RHF>(binder: self)
//        } else if footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, EH_RHF>(binder: self)
//        }
//
//        // All 'heights' bound, 'estimated row' and 'estimated footer'
//        else if rowHeight && headerHeight && footerHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RHF, EH_RH>(binder: self)
//        } else if rowHeight && headerHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RH, EH_RH>(binder: self)
//        } else if rowEstimatedHeight && footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_RF, EH_RH>(binder: self)
//        } else if headerEstimatedHeight && footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_HF, EH_RH>(binder: self)
//        } else if rowEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_R, EH_RH>(binder: self)
//        } else if headerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_H, EH_RH>(binder: self)
//        } else if footerEstimatedHeight
//        && rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, H_F, EH_RH>(binder: self)
//        }
//
//        // No 'heights' bound, all 'estimated heights' bound
//        else if rowEstimatedHeight && headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RHF>(binder: self)
//        } else if rowEstimatedHeight && headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RH>(binder: self)
//        } else if rowEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_RF>(binder: self)
//        } else if headerEstimatedHeight && footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_HF>(binder: self)
//        } else if rowEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_R>(binder: self)
//        } else if headerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_H>(binder: self)
//        } else if footerEstimatedHeight {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, EH_F>(binder: self)
//        } else {
//            self.tableViewDataSourceDelegate = _TableViewDataSourceDelegate<S, Void, Void>(binder: self)
//        }
//    }
}
*/
