// Copy this file to `SupabaseConfig.swift` (gitignored) and fill in your
// project's real values. Find both in the Supabase dashboard under
// Project Settings -> API. Use the publishable key here, not the secret
// key -- this config ships inside the app binary on both platforms.

import Foundation

enum SupabaseConfig {
    static let url = URL(string: "https://YOUR-PROJECT-REF.supabase.co")!
    static let publishableKey = "YOUR-PUBLISHABLE-KEY"
}
