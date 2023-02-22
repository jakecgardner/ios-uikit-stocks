//
//  HapticsService.swift
//  Stocks
//
//  Created by jake on 2/6/23.
//

import Foundation
import UIKit

final class HapticsService {
    static let shared = HapticsService()
    private init() {}
    
    public func vibrateForSelection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
