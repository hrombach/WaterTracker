//
//  SupabaseServiceTests.swift
//  WaterTrackerKit
//
//  Created by Hendrik Rombach on 08.08.26.
//

import Testing
import Foundation
import Mocker

@testable import WaterTrackerKit

struct SupabaseServiceTests {
    @Test func fetchEntries() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        
        let json = """
            [
                {
                    "id": "a082e5c9-bac1-412b-88e3-691b73ce262a",
                    "amount_ml": 250,
                    "source": "mac",
                    "logged_at": "2026-08-04T19:14:00.130927+00:00"
                },
                {
                    "id": "24532a95-b5d3-448b-9249-39545fc1670e",
                    "amount_ml": 250,
                    "source": "mac",
                    "logged_at": "2026-08-04T19:14:01.632867+00:00"
                },
                {
                    "id": "69a38056-f766-4c54-869b-284268ad9400",
                    "amount_ml": 250,
                    "source": "mac",
                    "logged_at": "2026-08-04T19:14:02.86+00:00"
                },
                {
                    "id": "ebf57cbe-3fe0-40c4-8945-47c6ce6588aa",
                    "amount_ml": 350,
                    "source": "mac",
                    "logged_at": "2026-08-04T19:24:21.808733+00:00"
                },
                {
                    "id": "b9fe3a34-91a2-40b3-871a-5e1007626c00",
                    "amount_ml": 600,
                    "source": "mac",
                    "logged_at": "2026-08-04T19:24:26.404905+00:00"
                }
            ]
            """
        
        Mock(
            url: try #require(URL(string: "https://test.supabase.example/rest/v1/entries")),
            ignoreQuery: true,
            contentType: .json,
            statusCode: 200,
            data: [.get: Data(json.utf8)]
        ).register()
        
        let service = SupabaseService(
            supabaseURL: try #require(URL(string: "https://test.supabase.example")),
            supabaseKey: "test-key",
            session: session
        )
        
        let entries = try await service.fetchEntries()
        
        #expect(entries.count == 5)
        
        let entry = entries.first
        
        #expect(entry?.id == UUID(uuidString: "a082e5c9-bac1-412b-88e3-691b73ce262a"))
        #expect(entry?.amountMl == 250)
        #expect(entry?.source == .mac)
        
        let expectedDate = try Date(
            "2026-08-04T19:14:00.130927+00:00",
            strategy: .iso8601
                .year()
                .month()
                .day()
                .dateTimeSeparator(.standard)
                .time(includingFractionalSeconds: true)
        )
        
        #expect(entry?.loggedAt == expectedDate)
    }
    
    @Test func logEntry() async throws {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockingURLProtocol.self]
        let session = URLSession(configuration: configuration)
        nonisolated(unsafe) var receivedBody: [String: Any]?
        
        var mock = Mock(
            url: try #require(URL(string: "https://test.supabase.example/rest/v1/entries")),
            ignoreQuery: true,
            contentType: .json,
            statusCode: 201,
            data: [.post: Data()]
        )

        mock.onRequestHandler = OnRequestHandler(jsonDictionaryCallback: { _, body in
            receivedBody = body
        })
        mock.register()

        let service = SupabaseService(
            supabaseURL: try #require(URL(string: "https://test.supabase.example")),
            supabaseKey: "test-key",
            session: session
        )
        
        try await service.logEntry(amountMl: 1000, source: .mac)
        
        #expect(receivedBody?["amount_ml"] as? Int == 1000)
        #expect(receivedBody?["source"] as? String == "mac")
    }
}
