import UIKit

public class BaseMultiSectionTableViewBindResult<C: UITableViewCell, S: TableViewSection> {
    /// The bind result's original binder. This is mostly used internally and can be ignored.
    let baseBinder: _BaseTableViewBinder<S>
    /// The sections the bind result is for. This is mostly used internally and can be ignored.
    let sections: [S]
    /// 'bind result' objects for the individual sections being bound to
    internal var sectionBindResults: [S: SingleSectionTableViewBindResult<C, S>] = [:]
    
    internal init(binder: _BaseTableViewBinder<S>, sections: [S]) {
        self.baseBinder = binder
        self.sections = sections
    }
    
    /**
     Add a handler to be called whenever a cell is dequeued in the declared sections.
     */
    @discardableResult
    public func onCellDequeue(_ handler: @escaping (_ section: S, _ row: Int, _ dequeuedCell: C) -> Void) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.onCellDequeue({ row, cell in
                handler(section, row, cell)
            })
        }
        return self
    }
    
    /**
     Add a handler to be called whenever a cell in the declared sections is tapped.
     */
    @discardableResult
    public func onTapped(_ handler: @escaping (_ section: S, _ row: Int, _ tappedCell: C) -> Void) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.onTapped({ row, cell in
                handler(section, row, cell)
            })
        }
        return self
    }
    
    /**
     Add a callback handler to provide the cell height for cells in the declared sections.
     */
    @discardableResult
    public func cellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.cellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }
    
    /**
     Add a callback handler to provide the estimated cell height for cells in the declared sections.
     */
    @discardableResult
    public func estimatedCellHeight(_ handler: @escaping (_ section: S, _ row: Int) -> CGFloat) -> RxMultiSectionTableViewBindResult<C, S> {
        for section in self.sections {
            let bindResult: RxSingleSectionTableViewBindResult<C, S> = self.bindResult(for: section)
            bindResult.estimatedCellHeight({ row in
                handler(section, row)
            })
        }
        return self
    }

}
