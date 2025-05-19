//
//  BaseTableViewCell.swift
//  RealtimeKitUI
//
//  Created by sudhir kumar on 16/02/23.
//

import UIKit

open class BaseTableViewCell: UITableViewCell {
    public let cellSeparatorBottom = UIView()
    public let cellSeparatorTop = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cellSeparatorBottom)
        contentView.addSubview(cellSeparatorTop)
        cellSeparatorTop.set(.leading(contentView, dyteSharedTokenSpace.space4),
                          .trailing(contentView),
                          .height(0.25),
                          .top(contentView))
        cellSeparatorBottom.set(.leading(contentView, dyteSharedTokenSpace.space4),
                          .trailing(contentView),
                          .height(0.25),
                          .bottom(contentView))
        cellSeparatorTop.backgroundColor =  dyteSharedTokenColor.background.shade600
        cellSeparatorBottom.backgroundColor =  dyteSharedTokenColor.background.shade600
        cellSeparatorTop.isHidden = true
        cellSeparatorBottom.isHidden = true
        
    }
    
    required  public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
