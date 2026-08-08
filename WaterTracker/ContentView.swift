//
//  ContentView.swift
//  WaterTracker
//
//  Created by Hendrik Rombach on 04.08.26.
//

import SwiftUI
import WaterTrackerKit

struct ContentView: View {
    @State private var entries: [WaterEntry] = []
    @State private var amountToLog: Int = 350
    @State private var errorMessage: String?
    @State private var isLoading = true

    private var totalML: Int {
        entries.map(\.amountMl).reduce(0, +)
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                Text("Total: \(totalML)ml")
            }
            Stepper("\(amountToLog)ml", value: $amountToLog, in: 50...2000, step: 50)
            Button("Log \(amountToLog)ml") {
                Task {
                    do {
                        try await SupabaseService.shared.logEntry(amountMl: amountToLog, source: .mac)
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    await loadEntries()
                }
            }
            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .task {
            await loadEntries()
        }
    }

    private func loadEntries() async {
        do {
            entries = try await SupabaseService.shared.fetchEntries(since: Calendar.current.startOfDay(for: Date()))
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

#Preview {
    ContentView()
}
