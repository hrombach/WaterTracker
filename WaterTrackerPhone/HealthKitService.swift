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
    private static let metadataKey = "xyz.anarkitty.water-tracker.id"

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
        let sample = HKQuantitySample(
            type: waterType,
            quantity: quantity,
            start: entry.loggedAt,
            end: entry.loggedAt,
            metadata: [Self.metadataKey: entry.id.uuidString]
        )
        return sample
    }

    private func getExistingSamples() async throws -> [String: HKQuantitySample] {
        let descriptor = HKSampleQueryDescriptor(
            predicates: [.quantitySample(
                type: waterType,
                predicate: HKQuery.predicateForSamples(withStart: lastSyncDate, end: Date())
            )],
            sortDescriptors: [SortDescriptor(\.endDate, order: .forward)],
            limit: HKObjectQueryNoLimit
        )
        let samples = try await descriptor
            .result(for: store)
            .filter { $0.metadata?[Self.metadataKey] != nil }
        var result: [String: HKQuantitySample] = [:]

        for sample in samples {
            if let key = sample.metadata?[Self.metadataKey] as? String {
                result[key] = sample
            }
        }

        return result
    }

    private func fetchEntriesForSync() async throws -> [WaterEntry] {
        return try await SupabaseService
            .shared
            .fetchEntries(since: lastSyncDate)
    }

    func syncWater() async throws {
        let entries = try await fetchEntriesForSync()

        if entries.isEmpty {
            return
        }

        let existingSamples = try await getExistingSamples()

        var samples: [HKQuantitySample] = []

        for entry in entries {
            if existingSamples[entry.id.uuidString] != nil {
                continue
            }

            samples.append(createSample(entry: entry))
        }

        if samples.isEmpty {
            return
        }

        try await store.save(samples)

        lastSyncDate = entries.first?.loggedAt
    }

    private init() {}
}
