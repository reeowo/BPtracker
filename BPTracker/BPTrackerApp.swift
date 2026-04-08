import SwiftUI
import SwiftData

@main
struct BPTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BloodPressureRecord.self)
    }
}
