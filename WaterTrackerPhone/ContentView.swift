//
//  ContentView.swift
//  WaterTrackerPhone
//
//  Created by Hendrik Rombach on 04.08.26.
//

import SwiftUI

struct ContentView: View {
    @State private var amountToAdd = 350
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Text("Total: 0ml") // placeholder
            Stepper("\(amountToAdd)ml", value: $amountToAdd, in: 50...2000, step: 50)
            Button("Log \(amountToAdd)ml") {
                Task {
                    do {
                        try await HealthKitService.shared.logWater(amountMl: amountToAdd)
                        errorMessage = nil
                    } catch {
                        errorMessage = error.localizedDescription
                    }
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
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    ContentView()
}
