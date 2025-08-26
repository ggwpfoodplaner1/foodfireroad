import SwiftUI

struct RootTabView: View {
    enum Tab: Hashable {
        case diary, recipes, burn, stats
    }

    @EnvironmentObject var appState: AppState
    @State private var selection: Tab = .diary
    @State private var showingSettings = false

    var body: some View {
        TabView(selection: $selection) {

            // Diary
            DiaryScreen()
                .tabItem {
                    Label("Diary", systemImage: "fork.knife")
                }
                .tag(Tab.diary)

            // Recipes
            RecipesScreen()
                .tabItem {
                    Label("Recipes", systemImage: "book")
                }
                .tag(Tab.recipes)

            // Burn
            BurnScreen()
                .tabItem {
                    Label("Burn", systemImage: "flame")
                }
                .tag(Tab.burn)

            // Stats
            StatsScreen()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar")
                }
                .tag(Tab.stats)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
                .environmentObject(appState)
        }
    }
}

// MARK: - Previews

#Preview {
    RootTabView()
        .environmentObject(AppState())
}
