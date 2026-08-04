//
//  HealthKitService.swift
//  WaterTrackerPhone
//
//  Created by Hendrik Rombach on 04.08.26.
//

import Foundation
import HealthKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let store: HKHealthStore = .init()
    private let waterType = HKQuantityType(.dietaryWater)
    
    func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [waterType], read: [waterType])
    }
    
    func logWater(amountMl: Int) async throws {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(amountMl))
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: Date(), end: Date())
        try await store.save(sample)
    }
    
    private init() {}
}
