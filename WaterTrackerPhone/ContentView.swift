//
//  ContentView.swift
//  WaterTrackerPhone
//
//  Created by Hendrik Rombach on 04.08.26.
//

import SwiftUI
import WaterTrackerKit

struct ContentView: View {
    @State private var entries: [WaterEntry] = []
    @State private var amountToAdd = 350
    @State private var errorMessage: String?
    
    private var totalML: Int {
        entries.map(\.amountMl).reduce(0, +)
    }
    
    var body: some View {
        VStack {
            Text("Total: \(totalML)ml")
            Stepper("\(amountToAdd)ml", value: $amountToAdd, in: 50...2000, step: 50)
            Button("Log \(amountToAdd)ml") {
                Task {
                    do {
                        try await SupabaseService.shared.logEntry(amountMl: amountToAdd, source: .iphone)
                        try await HealthKitService.shared.syncWater()
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                    await loadEntries()
                }
            }
            if let errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }
        }
        .padding()
        .task {
            do {
                try await HealthKitService.shared.requestAuthorization()
                try await HealthKitService.shared.syncWater()
            } catch {
                errorMessage = error.localizedDescription
            }
            await loadEntries()
        }
    }
    
    private func loadEntries() async {
        do {
            try await entries = SupabaseService.shared.fetchEntries(since: Calendar.current.startOfDay(for: Date()))
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ContentView()
}
