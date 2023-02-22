//
//  ViewController.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import UIKit
import FloatingPanel

class WatchListViewController: UIViewController {
    
    private var searchTimer: Timer?
    
    private var panel: FloatingPanelController?
    
    private var watchlistMap: [String: [CandleStick]] = [:]
    
    private var viewModels: [WatchListTableViewCell.ViewModel] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(WatchListTableViewCell.self, forCellReuseIdentifier: WatchListTableViewCell.identifier)
        return table
    }()
    
    static var maxChangeWidth: CGFloat = 0
    
    private var observer: NSObjectProtocol?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setUpSearchController()
        setUpTableView()
        fetchWatchListData()
        setUpFloatingPanel()
        setUpTitleView()
        setUpObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: Setup
    
    private func setUpTitleView() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: navigationController?.navigationBar.height ?? 100))
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: titleView.width-20, height: titleView.height))
        label.text = "Stocks"
        label.font = .systemFont(ofSize: 36, weight: .medium)
        titleView.addSubview(label)
        navigationItem.titleView = titleView
    }
    
    private func setUpSearchController() {
        let resultVC = SearchResultsViewController()
        resultVC.delegate = self
        
        let searchVC = UISearchController(searchResultsController: resultVC)
        searchVC.searchResultsUpdater = self
        
        navigationItem.searchController = searchVC
    }
    
    private func setUpFloatingPanel() {
        panel = FloatingPanelController()
        panel?.surfaceView.backgroundColor = .secondarySystemBackground
        panel?.delegate = self
        panel?.addPanel(toParent: self)
        
        let topStoriesVC = NewsViewController(type: .topStories)
        panel?.set(contentViewController: topStoriesVC)
        panel?.track(scrollView: topStoriesVC.tableView)
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setUpObserver() {
        observer = NotificationCenter.default.addObserver(forName: .didAddToWatchList, object: nil, queue: .main) { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchWatchListData()
        }
    }
    
    // MARK: Data Fetching
    
    private func fetchWatchListData() {
        let symbols = PersistenceService.shared.watchlist
        
        let group = DispatchGroup()
        
        for symbol in symbols where watchlistMap[symbol] == nil {
            group.enter()
            
            APIService.shared.marketData(for: symbol) { [weak self] result in
                defer {
                    group.leave()
                }
                
                switch result {
                case .success(let response):
                    let candleSticks = response.candleSticks
                    self?.watchlistMap[symbol] = candleSticks
                case .failure(let error):
                    print(error)
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            self?.createViewModels()
            self?.tableView.reloadData()
        }
    }
    
    // MARK: View Model
    
    private func createViewModels() {
        var viewModels: [WatchListTableViewCell.ViewModel] = []
        
        for (symbol, candleSticks) in watchlistMap {
            let changePercentage = candleSticks.getPercentage()
            viewModels.append(
                .init(
                    symbol: symbol,
                    companyName: UserDefaults.standard.string(forKey: symbol) ?? "Company",
                    price: getLatestClosingPrice(from: candleSticks),
                    changeColor: changePercentage < 0 ? .systemRed : .systemGreen,
                    changePercentage: String.percentage(from: changePercentage),
                    chartViewModel: .init(
                        data: candleSticks.reversed().map { $0.close },
                        showLegend: false,
                        showAxis: false,
                        fillColor: changePercentage < 0 ? .systemRed : .systemGreen,
                        days: 7
                    )
                )
            )
        }
        
        self.viewModels = viewModels.sorted(by: { $0.symbol < $1.symbol })
    }
    
    private func getLatestClosingPrice(from data: [CandleStick]) -> String {
        guard let closingPrice = data.first?.close else {
            return ""
        }
        return String.formatted(number: closingPrice)
    }
}

// MARK: - Throttled Search Query

extension WatchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? SearchResultsViewController,
              !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        searchTimer?.invalidate()
        
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { _ in
            APIService.shared.search(query: query) { result in
                switch result {
                case .success(let response):
                    DispatchQueue.main.async {
                        resultsVC.update(with: response.result)
                    }
                case .failure(let error):
                    print(error)
                }
            }
        })
    }
}

// MARK: - Open Details

extension WatchListViewController: SearchResultsViewControllerDelegate {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult) {
        navigationItem.searchController?.searchBar.resignFirstResponder()
        
        HapticsService.shared.vibrateForSelection()
        
        let detailsVC = StockDetailsViewController(
            symbol: searchResult.symbol,
            companyName: searchResult.description
        )
        detailsVC.title = searchResult.description
        
        let navigationVC = UINavigationController(rootViewController: detailsVC)
        present(navigationVC, animated: true)
    }
}

// MARK: - Floating Panel

extension WatchListViewController: FloatingPanelControllerDelegate {
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        navigationItem.titleView?.isHidden = fpc.state == .full
    }
}

// MARK: - TableView Delegates

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return WatchListTableViewCell.preferredHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WatchListTableViewCell.identifier, for: indexPath) as? WatchListTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        HapticsService.shared.vibrateForSelection()
        
        let viewModel = viewModels[indexPath.row]
        let detailsVC = StockDetailsViewController(
            symbol: viewModel.symbol,
            companyName: viewModel.companyName,
            candleSticks: watchlistMap[viewModel.symbol] ?? []
        )
        let navigationVC = UINavigationController(rootViewController: detailsVC)
        present(navigationVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            PersistenceService.shared.removeFromWatchlist(symbol: viewModels[indexPath.row].symbol)
            viewModels.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}
