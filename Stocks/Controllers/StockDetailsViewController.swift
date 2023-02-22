//
//  StockDetailsViewController.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import UIKit
import SafariServices

class StockDetailsViewController: UIViewController {

    private let symbol: String
    private let companyName: String
    private var candleSticks: [CandleStick] = []
    private var stories: [NewsStory] = []
    private var metrics: Metrics?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(NewsStoryTableViewCell.self, forCellReuseIdentifier: NewsStoryTableViewCell.identifier)
        table.register(NewsHeaderView.self, forHeaderFooterViewReuseIdentifier: NewsHeaderView.identifier)
        return table
    }()
    
    // MARK: Lifecycle
    
    init(
        symbol: String,
        companyName: String,
        candleSticks: [CandleStick] = []
    ) {
        self.symbol = symbol
        self.companyName = companyName
        self.candleSticks = candleSticks
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = companyName
        
        setUpCloseButton()
        setUpTableView()
        
        fetchStockData()
        fetchNews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpCloseButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width * 0.7) + 100))
    }
    
    // MARK: Data Fetching
    
    private func fetchStockData() {
        let group = DispatchGroup()
        
        if candleSticks.isEmpty {
            group.enter()
            APIService.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }

                switch result {
                case .success(let response):
                    self?.candleSticks = response.candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.enter()
        
        APIService.shared.financialMetrics(for: symbol) { [weak self] result in
            defer {
                group.leave()
            }

            switch result {
            case .success(let response):
                self?.metrics = response.metric
            case .failure(let error):
                print(error)
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.renderChart()
        }
    }
    
    private func fetchNews() {
        APIService.shared.news(for: .company(symbol: symbol)) { [weak self] result in
            switch result {
            case .success(let stories):
                DispatchQueue.main.async {
                    self?.stories = stories
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Render Chart
    
    private func renderChart() {
        let headerView = StockDetailsHeaderView(frame: CGRect(x: 0, y: 0, width: view.width, height: (view.width*0.7) + 100))
        
        var metricViewModels: [MetricCollectionViewCell.ViewModel] = []
        if let metrics = metrics {
            metricViewModels.append(
                .init(name: "52W High", value: "\(metrics.AnnualWeekHigh)")
            )
            metricViewModels.append(
                .init(name: "52W Low", value: "\(metrics.AnnualWeekLow)")
            )
            metricViewModels.append(
                .init(name: "52W Return", value: "\(metrics.AnnualWeekPriceReturnDaily)")
            )
            metricViewModels.append(
                .init(name: "Beta", value: "\(metrics.beta)")
            )
            metricViewModels.append(
                .init(name: "Volume", value: "\(metrics.TenDayAverageTradingVolume)")
            )
        }
        
        let changePercentage = candleSticks.getPercentage()
        headerView.configure(
            chartViewModel: .init(
                data: candleSticks.reversed().map { $0.close },
                showLegend: true,
                showAxis: true,
                fillColor: changePercentage < 0 ? .systemRed : .systemGreen,
                days: 7
            ),
            metricViewModels: metricViewModels
        )
        tableView.tableHeaderView = headerView
    }
}

// MARK: - Add To Watchlist

extension StockDetailsViewController: NewsHeaderViewDelegate {
    func newsHeaderViewDidTapAddButton(_ headerView: NewsHeaderView) {
        headerView.button.isHidden = true
        
        PersistenceService.shared.addToWatchlist(symbol: symbol, companyName: companyName)
        
        HapticsService.shared.vibrate(for: .success)
        
        let alert = UIAlertController(title: "Added to watchlist", message: "We've added \(companyName) to your watchlist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - TableView Delegates

extension StockDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return NewsStoryTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NewsHeaderView.identifier) as? NewsHeaderView else {
            return nil
        }
        header.delegate = self
        header.configure(with: .init(title: symbol.uppercased(), shouldShowAddButton: !PersistenceService.shared.watchlistContains(symbol: symbol)))
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return NewsHeaderView.preferredHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsStoryTableViewCell.identifier, for: indexPath) as? NewsStoryTableViewCell else {
            fatalError()
        }
        cell.configure(with: .init(model: stories[indexPath.row]))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsService.shared.vibrateForSelection()
        
        guard let url = URL(string: stories[indexPath.row].url) else {
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
