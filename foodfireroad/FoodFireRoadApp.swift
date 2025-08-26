import SwiftUI

@main
struct FoodFireRoadApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .onAppear {
                    appState.loadFromDisk()
                }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .inactive, .background:
                appState.saveToDisk()
            default:
                break
            }
        }
    }
}
