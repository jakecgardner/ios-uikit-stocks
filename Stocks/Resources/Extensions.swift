//
//  Extensions.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import Foundation
import UIKit

// MARK: - Frame

extension UIView {
    var width: CGFloat {
        frame.size.width
    }
    var height: CGFloat {
        frame.size.height
    }
    var left: CGFloat {
        frame.origin.x
    }
    var right: CGFloat {
        left + width
    }
    var top: CGFloat {
        frame.origin.y
    }
    var bottom: CGFloat {
        top + height
    }
}

// MARK: - Date Formatters

extension DateFormatter {
    static let newsDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter
    }()
    
    static let prettyDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}

// MARK: - Number Formatters

extension NumberFormatter {
    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

// MARK: - String

extension String {
    static func string(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        return DateFormatter.prettyDateFormatter.string(from: date)
    }
    
    static func percentage(from double: Double) -> String {
        let formatter = NumberFormatter.percentFormatter
        return formatter.string(from: NSNumber(value: double)) ?? "\(double)"
    }
    
    static func formatted(number: Double) -> String {
        let formatter = NumberFormatter.decimalFormatter
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
}

// MARK: - ImageView

extension UIImageView {
    func setImage(with url: URL?) {
        guard let url = url else {
            return
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data, error == nil else {
                    return
                }
                DispatchQueue.main.async {
                    self?.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let didAddToWatchList = Notification.Name("didAddToWatchList")
}

// MARK: - CandleStick Percent Change

extension Array where Element == CandleStick {
    func getPercentage() -> Double {
        let latestDate = self[0].date
        guard let latestClose = self.first?.close,
            let priorClose = self.first(where: {
                !Calendar.current.isDate($0.date, inSameDayAs: latestDate)
            })?.close else {
            return 0
        }

        let diff = 1 - (priorClose/latestClose)
        return diff
    }
}
