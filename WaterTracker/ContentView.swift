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
    
    private var totalML: Int {
        entries.map(\.amountMl).reduce(0, +)
    }

    var body: some View {
        VStack {
            Text("\(totalML) ml")
            Button("Log 250ml") {
                Task {
                    try? await SupabaseService.shared.logEntry(amountMl: 250, source: .mac)
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
        entries = (try? await SupabaseService.shared.fetchEntries()) ?? []
    }
}

#Preview {
    ContentView()
}
