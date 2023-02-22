//
//  NewsHeaderView.swift
//  Stocks
//
//  Created by jake on 2/7/23.
//

import UIKit

protocol NewsHeaderViewDelegate: AnyObject {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView)
}

class NewsHeaderView: UITableViewHeaderFooterView {
    // MARK: Identifier
    static let identifier = "NewsHeaderView"
    static let preferredHeight: CGFloat = 70
    
    weak var delegate: NewsHeaderViewDelegate?
    
    struct ViewModel {
        let title: String
        let shouldShowAddButton: Bool
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        return label
    }()
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitle("+ Watchlist", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Lifecycle
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapButton() {
        delegate?.newsHeaderViewDidTapAddButton(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 20, y: 0, width: label.width, height: contentView.height)
        
        button.sizeToFit()
        button.frame = CGRect(
            x: contentView.width - button.width - 28,
            y: (contentView.height - button.height) / 2,
            width: button.width + 8,
            height: button.height
        )
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
    }
    
    public func configure(with viewModel: ViewModel) {
        label.text = viewModel.title
        button.isHidden = !viewModel.shouldShowAddButton
    }
}
