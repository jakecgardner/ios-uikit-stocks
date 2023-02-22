//
//  StockDetailSHeaderView.swift
//  Stocks
//
//  Created by jake on 2/11/23.
//

import UIKit

class StockDetailsHeaderView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    private var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
    
    private let chartView = StockChartView()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.register(MetricCollectionViewCell.self, forCellWithReuseIdentifier: MetricCollectionViewCell.identifier)
        collection.backgroundColor = .secondarySystemBackground
        return collection
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        addSubview(chartView)
        addSubview(collectionView)
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = CGRect(x: 0, y: 0, width: width, height: height-100)
        chartView.isUserInteractionEnabled = false
        collectionView.frame = CGRect(x: 0, y: height-100, width: width, height: 100)
    }
    
    public func configure(
        chartViewModel: StockChartView.ViewModel,
        metricViewModels: [MetricCollectionViewCell.ViewModel]
    ) {
        self.metricViewModels = metricViewModels
        chartView.configure(with: chartViewModel)
        collectionView.reloadData()
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return metricViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MetricCollectionViewCell.identifier, for: indexPath) as? MetricCollectionViewCell else {
            fatalError()
        }
        cell.configure(with: metricViewModels[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: width/2, height: 100/3)
    }
}
