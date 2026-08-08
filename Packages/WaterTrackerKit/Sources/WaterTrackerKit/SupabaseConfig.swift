import Foundation

enum SupabaseConfig {
    static let url: URL = {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "SupabaseURL") as? String,
              let url = URL(string: string) else {
            fatalError("Missing or invalid SupabaseURL in Info.plist")
        }
        return url
    }()
    static let publishableKey: String = {
        guard let string = Bundle.main.object(forInfoDictionaryKey: "SupabasePublishableKey") as? String else {
            fatalError("Missing or invalid SupabasePublishableKey in Info.plist")
        }
        return string
    }()
}
