//
//  WaterEntryTests.swift
//  WaterTrackerKitTests
//

import Testing
import Foundation

@testable import WaterTrackerKit

struct WaterEntryTests {
    @Test func encode() throws {
        let uuid = UUID()
        let entry = WaterEntry(id: uuid, amountMl: 250, source: .mac, loggedAt: Date())
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(entry)
        let dict = try #require(JSONSerialization.jsonObject(with: encoded, options: []) as? [String: Any])

        #expect(dict["id"] as? String == uuid.uuidString)
        #expect(dict["amount_ml"] as? Int == 250)
        #expect(dict["source"] as? String == "mac")
        #expect(dict["logged_at"] != nil)
    }
    @Test func decode() throws {
        let json = """
            {"id": "cd7ec5b9-e9ff-44ed-b904-cc610d7354f6", "amount_ml": 250, "source": "mac", "logged_at": 1786212963}
            """
        let decoded = try JSONDecoder().decode(WaterEntry.self, from: Data(json.utf8))

        #expect(decoded.id == UUID(uuidString: "cd7ec5b9-e9ff-44ed-b904-cc610d7354f6"))
        #expect(decoded.amountMl == 250)
        #expect(decoded.source == .mac)
        #expect(decoded.loggedAt.timeIntervalSinceReferenceDate == 1786212963)
    }
}
