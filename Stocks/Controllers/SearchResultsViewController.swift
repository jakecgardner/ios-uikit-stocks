//
//  SearchResultsViewController.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import UIKit

protocol SearchResultsViewControllerDelegate: AnyObject {
    func searchResultsViewControllerDidSelect(searchResult: SearchResult)
}

class SearchResultsViewController: UIViewController {

    private var results: [SearchResult] = []
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(SearchResultsTableViewCell.self, forCellReuseIdentifier: SearchResultsTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func setUpTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]) {
        self.results = results
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
    }
}

// MARK: - TableView Delegates

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableViewCell.identifier, for: indexPath)
        
        let result = results[indexPath.row]
        cell.textLabel?.text = result.displaySymbol
        cell.detailTextLabel?.text = result.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.searchResultsViewControllerDidSelect(searchResult: results[indexPath.row])
    }
}
