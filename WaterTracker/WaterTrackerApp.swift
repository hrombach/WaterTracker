//
//  WaterTrackerApp.swift
//  WaterTracker
//
//  Created by Hendrik Rombach on 04.08.26.
//

import SwiftUI

@main
struct WaterTrackerApp: App {
    var body: some Scene {
        MenuBarExtra("Water Tracker", systemImage: "waterbottle.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }
}
