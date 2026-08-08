//
//  HealthKitService.swift
//  WaterTrackerPhone
//
//  Created by Hendrik Rombach on 04.08.26.
//

import Foundation
import HealthKit
import WaterTrackerKit

final class HealthKitService {
    static let shared = HealthKitService()
    private let store: HKHealthStore = .init()
    private let waterType = HKQuantityType(.dietaryWater)

    var lastSyncDate: Date? {
        get {
            UserDefaults.standard.object(forKey: "lastSyncDate") as? Date
        }
        set(lastSyncDate) {
            UserDefaults.standard.set(lastSyncDate, forKey: "lastSyncDate")
        }
    }

    func requestAuthorization() async throws {
        try await store.requestAuthorization(toShare: [waterType], read: [waterType])
    }

    private func createSample(entry: WaterEntry) -> HKQuantitySample {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: Double(entry.amountMl))
        let sample = HKQuantitySample(type: waterType, quantity: quantity, start: entry.loggedAt, end: entry.loggedAt)
        return sample
    }

    func syncWater() async throws {
        let entries = try await SupabaseService
            .shared
            .fetchEntries(since: lastSyncDate)
            .filter { $0.loggedAt != lastSyncDate }

        if entries.isEmpty {
            return
        }

        let samples = entries.map { createSample(entry: $0) }

        try await store.save(samples)

        lastSyncDate = entries.first?.loggedAt
    }

    private init() {}
}
