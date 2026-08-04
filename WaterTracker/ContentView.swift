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
    
    private var totalML: Int {
        entries.map(\.amountMl).reduce(0, +)
    }

    var body: some View {
        VStack {
            Text("Total: \(totalML)ml")
            Stepper("\(amountToLog)ml", value: $amountToLog, in: 50...2000, step: 50)
            Button("Log \(amountToLog)ml") {
                Task {
                    try? await SupabaseService.shared.logEntry(amountMl: amountToLog, source: .mac)
                    await loadEntries()
                }
            }
        }
        .padding()
        .task {
            await loadEntries()
        }
    }
    
    private func loadEntries() async {
        entries = (try? await SupabaseService.shared.fetchEntries(since: Calendar.current.startOfDay(for: Date()))) ?? []
    }
}

#Preview {
    ContentView()
}
