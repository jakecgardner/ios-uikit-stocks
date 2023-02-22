//
//  WatchListTableViewCell.swift
//  Stocks
//
//  Created by jake on 2/10/23.
//

import UIKit

class WatchListTableViewCell: UITableViewCell {
    // MARK: Identifier
    static let identifier = "WatchListTableViewCell"
    static let preferredHeight: CGFloat = 60
    
    struct ViewModel {
        let symbol: String
        let companyName: String
        let price: String
        let changeColor: UIColor
        let changePercentage: String
        let chartViewModel: StockChartView.ViewModel
    }

    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let companyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .white
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let miniChartView: StockChartView = {
        let chart = StockChartView()
        chart.clipsToBounds = true
        chart.isUserInteractionEnabled = false
        chart.translatesAutoresizingMaskIntoConstraints = false
        return chart
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.clipsToBounds = true
        contentView.addSubview(symbolLabel)
        contentView.addSubview(companyLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(changeLabel)
        contentView.addSubview(miniChartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        symbolLabel.sizeToFit()
        companyLabel.sizeToFit()
        priceLabel.sizeToFit()
        changeLabel.sizeToFit()
        
        var constraints: [NSLayoutConstraint] = []
        
        let horizontalPadding: CGFloat = 20
        let verticalPadding: CGFloat = (contentView.height - symbolLabel.height - companyLabel.height) / 2
        
        constraints.append(symbolLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalPadding))
        constraints.append(symbolLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding))
        constraints.append(symbolLabel.widthAnchor.constraint(equalToConstant: symbolLabel.width))
        constraints.append(symbolLabel.heightAnchor.constraint(equalToConstant: symbolLabel.height))
        
        constraints.append(companyLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalPadding))
        constraints.append(companyLabel.topAnchor.constraint(equalTo: symbolLabel.bottomAnchor))
        constraints.append(companyLabel.widthAnchor.constraint(equalToConstant: companyLabel.width))
        constraints.append(companyLabel.heightAnchor.constraint(equalToConstant: companyLabel.height))

        constraints.append(priceLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalPadding))
        constraints.append(priceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding))
        constraints.append(priceLabel.widthAnchor.constraint(equalToConstant: priceLabel.width))
        constraints.append(priceLabel.heightAnchor.constraint(equalToConstant: priceLabel.height))
        
        constraints.append(changeLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalPadding))
        constraints.append(changeLabel.topAnchor.constraint(equalTo: priceLabel.bottomAnchor))
        constraints.append(changeLabel.widthAnchor.constraint(equalToConstant: changeLabel.width))
        constraints.append(changeLabel.heightAnchor.constraint(equalToConstant: changeLabel.height))
        
        constraints.append(miniChartView.rightAnchor.constraint(equalTo: changeLabel.leftAnchor, constant: -horizontalPadding))
        constraints.append(miniChartView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        constraints.append(miniChartView.widthAnchor.constraint(equalToConstant: contentView.width / 3))
        constraints.append(miniChartView.heightAnchor.constraint(equalToConstant: contentView.height - verticalPadding*2))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        symbolLabel.text = nil
        companyLabel.text = nil
        priceLabel.text = nil
        changeLabel.text = nil
        miniChartView.reset()
    }
    
    public func configure(with viewModel: ViewModel) {
        symbolLabel.text = viewModel.symbol
        companyLabel.text = viewModel.companyName
        priceLabel.text = viewModel.price
        changeLabel.text = viewModel.changePercentage
        changeLabel.backgroundColor = viewModel.changeColor
        miniChartView.configure(with: viewModel.chartViewModel)
    }
}
