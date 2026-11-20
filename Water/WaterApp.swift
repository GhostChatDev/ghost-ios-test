import SwiftUI

@main
struct WaterApp: App {
    @State private var store = WaterStore.forLaunch()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
