//
//  StockChartView.swift
//  Stocks
//
//  Created by jake on 2/10/23.
//

import UIKit
import Charts

class StockChartView: UIView {

    struct ViewModel {
        let data: [Double]
        let showLegend: Bool
        let showAxis: Bool
        let fillColor: UIColor
        let days: Int
    }
    
    private let chartView: LineChartView = {
        let chart = LineChartView()
        chart.pinchZoomEnabled = false
        chart.setScaleEnabled(true)
        chart.xAxis.enabled = false
        chart.drawGridBackgroundEnabled = false
        chart.leftAxis.enabled = false
        chart.rightAxis.enabled = false
        chart.legend.enabled = false
        return chart
    }()

    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }

    public func reset() {
        chartView.data = nil
    }
    
    public func configure(with viewModel: ViewModel) {
        var entries = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated() {
            entries.append(
                .init(x: Double(index), y: value)
            )
        }
        
        chartView.rightAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataSet = LineChartDataSet(entries: entries, label: "\(viewModel.days) Days")
        dataSet.fillColor = viewModel.fillColor
        dataSet.drawFilledEnabled = true
        dataSet.drawIconsEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.drawCirclesEnabled = false
        chartView.data = LineChartData(dataSet: dataSet)
    }
}
