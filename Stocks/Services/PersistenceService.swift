//
//  PersistenceService.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}
    
    private let userDefaults: UserDefaults = .standard
    
    private struct Contants {
        static let onboarded = "hasOnboarded"
        static let watchlist = "watchlist"
    }
    
    public var watchlist: [String] {
        if !hasOnboarded {
            userDefaults.setValue(true, forKey: Contants.onboarded)
            setUpDefaults()
        }
        return userDefaults.stringArray(forKey: Contants.watchlist) ?? []
    }
    
    /// Stores watchlist in UserDefaults.standard
    /// - Parameters:
    ///   - symbol: String
    ///   - companyName: String
    public func addToWatchlist(symbol: String, companyName: String) {
        var current = watchlist
        current.append(symbol)
        userDefaults.set(current, forKey: Contants.watchlist)
        userDefaults.set(companyName, forKey: symbol)
        NotificationCenter.default.post(name: .didAddToWatchList, object: nil)
    }
    
    /// Check for symbol in watchlist
    /// - Parameter symbol: String
    /// - Returns: Bool
    public func watchlistContains(symbol: String) -> Bool {
        return watchlist.contains(symbol)
    }
    
    /// Removes symbol from watchlist and writes new watchlist to UserDefaults.standard
    /// - Parameter symbol: String
    public func removeFromWatchlist(symbol: String) {
        userDefaults.set(nil, forKey: symbol)
        
        var newList = [String]()
        for item in watchlist where item != symbol {
            newList.append(item)
        }
        
        userDefaults.set(newList, forKey: Contants.watchlist)
    }
    
    /// Set to true after first watchlist access
    private var hasOnboarded: Bool {
        return userDefaults.bool(forKey: Contants.onboarded)
    }
    
    /// Seed the watchlist with common symbols
    private func setUpDefaults() {
        let map: [String: String] = [
            "AAPL": "Apple Inc.",
            "GOOG": "Alphabet",
            "META": "Meta Inc.",
            "MSFT": "Microsoft Corporation",
        ]
        
        let symbols = map.keys.map { $0 }
        userDefaults.set(symbols, forKey: Contants.watchlist)
        
        for (symbol, name) in map {
            userDefaults.set(name, forKey: symbol)
        }
    }
}
