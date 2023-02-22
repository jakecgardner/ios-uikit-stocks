//
//  SearchResultsTableViewCell.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
    // MARK: Identifier
    static let identifier = "SearchResultsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: SearchResultsTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
