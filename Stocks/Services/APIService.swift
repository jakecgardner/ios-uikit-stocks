//
//  APIService.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import Foundation

final class APIService {
    static let shared = APIService()
    private init() {}
    
    private struct Constants {
        static let apiKey = "<api key>"
        static let sandboxApiKey = ""
        static let baseUrl = "https://finnhub.io/api/v1/"
        static let dayInSeconds: Double = 3600 * 24
    }
    
    private enum Endpoint: String {
        case companyNews = "company-news"
        case financialMetric = "stock/metric"
        case marketData = "stock/candle"
        case search
        case topStories = "news"
    }
    
    private enum APIError: Error {
        case errorDecoding
        case invalidUrl
        case noDataInResponse
        case noResponse
        case unknownError
    }
    
    /// Retrieve a URL for the specified endpoint
    /// - Parameters:
    ///   - endpoint: pre-defined endpoint String
    ///   - queryParams:dictionary of parameters to add to query string. Automatically adds API key.
    /// - Returns: URL
    private func url(for endpoint: Endpoint, queryParams: [String: String] = [:]) -> URL? {
        var urlString = Constants.baseUrl + endpoint.rawValue
        
        var queryItems = [URLQueryItem]()
        
        for (name, value) in queryParams {
            queryItems.append(.init(name: name, value: value))
        }
        
        queryItems.append(.init(name: "token", value: Constants.apiKey))
        
        let queryString = queryItems.map { "\($0.name)=\($0.value ?? "")" }.joined(separator: "&")
        urlString += "?" + queryString

        return URL(string: urlString)
    }
    
    /// Performs API call to <url>, decoding a <expecting>, and executing <completion> on completion.
    /// - Parameters:
    ///   - url: URL
    ///   - expecting: decoded type
    ///   - completion: closure accepting a Result<T>
    private func request<T: Codable>(
        url: URL?,
        expecting: T.Type,
        completion: @escaping ((Result<T, Error>) -> Void)
    ) {
        guard let url = url else {
            completion(.failure(APIError.invalidUrl))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(.failure(APIError.noDataInResponse))
                return
            }
            guard response != nil else {
                completion(.failure(APIError.noResponse))
                return
            }
            guard error == nil else {
                completion(.failure(APIError.unknownError))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(expecting, from: data)
                completion(.success(decoded))
            } catch {
                print(error)
                completion(.failure(APIError.errorDecoding))
            }
        }
        
        task.resume()
    }
    
    public func search(
        query: String,
        completion: @escaping ((Result<SearchResponse, Error>) -> Void)
    ) {
        guard let safeQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        request(
            url: url(for: .search, queryParams: ["q" : safeQuery]),
            expecting: SearchResponse.self,
            completion: completion
        )
    }
    
    public func news(
        for type: NewsViewController.`Type`,
        completion: @escaping (Result<[NewsStory], Error>) -> Void
    ) {
        let today = Date()
        let fromSearchDate = today.addingTimeInterval(-(Constants.dayInSeconds * 3))
        
        switch type {
        case .topStories:
            let url = url(for: .topStories, queryParams: ["category" : "general"])
            request(url: url, expecting: [NewsStory].self, completion: completion)
        case .company(let symbol):
            let url = url(
                for: .companyNews,
                queryParams: [
                    "symbol" : symbol,
                    "from": DateFormatter.newsDateFormatter.string(from: fromSearchDate),
                    "to": DateFormatter.newsDateFormatter.string(from: today)
                ]
            )
            request(url: url, expecting: [NewsStory].self, completion: completion)
        }
    }
    
    public func marketData(
        for symbol: String,
        numberOfDays: TimeInterval = 7,
        completion: @escaping (Result<MarketDataResponse, Error>) -> Void
    ) {
        let today = Date().addingTimeInterval(-(Constants.dayInSeconds))
        let fromSearchDate = today.addingTimeInterval(-(Constants.dayInSeconds * numberOfDays))
        
        let url = url(
            for: .marketData,
            queryParams: [
                "symbol": symbol,
                "resolution": "1",
                "from": String(Int(fromSearchDate.timeIntervalSince1970)),
                "to": String(Int(today.timeIntervalSince1970))
            ]
        )
        
        request(url: url, expecting: MarketDataResponse.self, completion: completion)
    }
    
    public func financialMetrics(
        for symbol: String,
        completion: @escaping (Result<FinancialMetricResponse, Error>) -> Void
    ) {
        let url = url(
            for: .financialMetric,
            queryParams: [
                "symbol": symbol,
                "metric": "all",
            ]
        )
        
        request(url: url, expecting: FinancialMetricResponse.self, completion: completion)
    }
    
}
