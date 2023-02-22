//
//  NewsStoryTableViewCell.swift
//  Stocks
//
//  Created by jake on 2/7/23.
//

import UIKit

class NewsStoryTableViewCell: UITableViewCell {
    // MARK: Identifier
    static let identifier = "NewsStoryTableViewCell"
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 13, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .tertiarySystemBackground
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 7
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .secondarySystemBackground
        
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(sourceLabel)
        contentView.addSubview(headlineLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var constraints: [NSLayoutConstraint] = []
        
        let imageSize: CGFloat = contentView.height / 1.3
        let verticalPadding: CGFloat = (contentView.height - imageSize) / 2
        let horizontalPadding: CGFloat = 20
        
        constraints.append(storyImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalPadding))
        constraints.append(storyImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding))
        constraints.append(storyImageView.widthAnchor.constraint(equalToConstant: imageSize))
        constraints.append(storyImageView.heightAnchor.constraint(equalToConstant: imageSize))
        
        let availableWidth = contentView.width - imageSize - (horizontalPadding * 2.5)
        constraints.append(headlineLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalPadding))
        constraints.append(headlineLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(headlineLabel.widthAnchor.constraint(equalToConstant: availableWidth))
        
        sourceLabel.sizeToFit()
        constraints.append(sourceLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalPadding))
        constraints.append(sourceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding))
        
        dateLabel.sizeToFit()
        constraints.append(dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalPadding))
        constraints.append(dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    public func configure(with viewModel: ViewModel) {
        headlineLabel.text = viewModel.headline
        sourceLabel.text = viewModel.source
        dateLabel.text = viewModel.dateString
        storyImageView.setImage(with: viewModel.imageURL)
    }
}

