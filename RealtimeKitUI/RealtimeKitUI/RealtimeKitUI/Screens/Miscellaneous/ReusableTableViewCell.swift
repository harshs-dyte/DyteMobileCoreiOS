//
//  ReusableTableViewCell.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 14/02/23.
//

import UIKit



class TitleTableViewCell: BaseTableViewCell {
    let lblTitle = {
        let lblTitle = RtkUIUTility.createLabel()
        return lblTitle
    }()
    
    private var viewModel: TitleTableViewCellModel?
    
    func createSubView(on baseView: UIView) {
        baseView.addSubview(lblTitle)
        lblTitle.set(.fillSuperView(baseView))
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        let baseView = UIView()
        createSubView(on: baseView)
        contentView.addSubview(baseView)
        baseView.set(.below(self.cellSeparatorTop, dyteSharedTokenSpace.space5),
                     .above(cellSeparatorBottom, dyteSharedTokenSpace.space5),
                     .sameLeadingTrailing(contentView,dyteSharedTokenSpace.space4))
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
struct TitleTableViewCellModel: BaseModel {
    var title: String
    func clean() {
        
    }
}

extension TitleTableViewCell: ConfigureView {
    var model: TitleTableViewCellModel {
        if let model =  viewModel {
            return model
        }
        fatalError("Before calling this , Please set model first using 'func configure(model: TitleTableViewCellModel)'")
    }
    
    func configure(model: TitleTableViewCellModel) {
        viewModel = model
        self.lblTitle.text = model.title
    }
}

class AcceptButtonTableViewCell: ButtonTableViewCell {
    
    override func setupView() {
        super.setupView()
        self.button.backgroundColor = dyteSharedTokenColor.background.shade800
    }
}
class AcceptButtonJoinStageRequestTableViewCell: AcceptButtonTableViewCell {
}

class AcceptButtonWaitingTableViewCell: AcceptButtonTableViewCell {
}

class RejectButtonTableViewCell: ButtonTableViewCell {
    
    override func setupView() {
        super.setupView()
        self.button.backgroundColor = dyteSharedTokenColor.background.shade800
    }
}
class RejectButtonJoinStageRequestTableViewCell: RejectButtonTableViewCell {
}

class ButtonTableViewCell: BaseTableViewCell {
    
    let button = {
        let button = RtkButton()
        return button
    }()
    
    var buttonClick:((RtkButton) -> Void)?
    private var viewModel: ButtonTableViewCellModel?

    func createSubView(on baseView: UIView) {
        baseView.addSubview(button)
        button.set(.fillSuperView(baseView))
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        let baseView = UIView()
        createSubView(on: baseView)
        contentView.addSubview(baseView)
        baseView.set(.below(self.cellSeparatorTop, dyteSharedTokenSpace.space2),
                     .above(cellSeparatorBottom, dyteSharedTokenSpace.space2),
                     .sameLeadingTrailing(cellSeparatorBottom))
        button.addTarget(self, action: #selector(buttonClick(button:)), for: .touchUpInside)
    }
    
   @objc func buttonClick(button: RtkButton) {
       self.buttonClick?(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ButtonTableViewCellModel: BaseModel {
    var buttonTitle: String
    var titleColor: UIColor = dyteSharedTokenColor.status.success
    func clean() {
        
    }
}

extension ButtonTableViewCell: ConfigureView {
    var model: ButtonTableViewCellModel {
        if let model =  viewModel {
            return model
        }
        fatalError("Before calling this , Please set model first using 'func configure(model: TitleTableViewCellModel)'")
    }
    
    func configure(model: ButtonTableViewCellModel) {
        viewModel = model
        self.button.setTitle(model.buttonTitle, for: .normal)
        self.button.setTitleColor(model.titleColor, for: .normal)
    }
}


struct SearchTableViewCellModel: BaseModel {
    var placeHolder: String
    func clean() {
        
    }
}

class SearchTableViewCell: BaseTableViewCell {
    let searchBar = {
        let searchBar = UISearchBar()
        searchBar.changeText(color: dyteSharedTokenColor.textColor.onBackground.shade700)
        searchBar.searchBarStyle = .minimal
        searchBar.isUserInteractionEnabled = false
        return searchBar
    }()
    private var viewModel: SearchTableViewCellModel?

    
    func createSubView(on baseView: UIView) {
        baseView.addSubview(searchBar)
        searchBar.set(.fillSuperView(baseView))
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setupView() {
        let baseView = UIView()
        createSubView(on: baseView)
        contentView.addSubview(baseView)
        baseView.set(.below(self.cellSeparatorTop, dyteSharedTokenSpace.space2),
                     .above(cellSeparatorBottom, dyteSharedTokenSpace.space2),
                     .sameLeadingTrailing(contentView,dyteSharedTokenSpace.space4))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SearchTableViewCell: ConfigureView {
    var model: SearchTableViewCellModel {
        if let model =  viewModel {
            return model
        }
        fatalError("Before calling this , Please set model first using 'func configure(model: TitleTableViewCellModel)'")
    }
    
    func configure(model: SearchTableViewCellModel) {
        viewModel = model
        self.searchBar.placeholder = model.placeHolder
    }
}
