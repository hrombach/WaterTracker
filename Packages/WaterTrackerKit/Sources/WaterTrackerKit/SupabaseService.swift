//
//  SupabaseService.swift
//  WaterTrackerKit
//
//  Created by Hendrik Rombach on 04.08.26.
//

import Foundation
import Supabase

struct EntryPayload: Encodable {
    let amountMl: Int
    let source: Source

    enum CodingKeys: String, CodingKey {
        case amountMl = "amount_ml"
        case source
    }
}

public final class SupabaseService: Sendable {
    private let client: SupabaseClient
    public static let shared = SupabaseService()

    public func fetchEntries(since: Date? = nil) async throws -> [WaterEntry] {
        var query = client.from("entries").select()
        if let since {
            query = query.gte("logged_at", value: since)
        }
        return try await query.order("logged_at", ascending: false).execute().value
    }

    public func logEntry(amountMl: Int, source: Source) async throws {
        let payload = EntryPayload(amountMl: amountMl, source: source)
        try await client.from("entries").insert(payload).execute()
    }

    package init(
        supabaseURL: URL = SupabaseConfig.url,
        supabaseKey: String = SupabaseConfig.publishableKey,
        session: URLSession = .shared
    ) {
        let options = SupabaseClientOptions(global: .init(session: session))
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey,
            options: options
        )
    }
}
