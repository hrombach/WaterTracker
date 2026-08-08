//
//  WaterEntry.swift
//  WaterTrackerKit
//
//  Created by Hendrik Rombach on 04.08.26.
//

import Foundation

public enum Source: String, Codable {
    case mac
    case iphone
}

public struct WaterEntry: Codable {
    public let id: UUID
    public let amountMl: Int
    public let source: Source
    public let loggedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case amountMl = "amount_ml"
        case source
        case loggedAt = "logged_at"
    }

    public init(id: UUID, amountMl: Int, source: Source, loggedAt: Date) {
        self.id = id
        self.amountMl = amountMl
        self.source = source
        self.loggedAt = loggedAt
    }
}
