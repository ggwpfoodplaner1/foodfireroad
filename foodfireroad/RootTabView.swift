import SwiftUI

struct RootTabView: View {
    enum Tab: Hashable {
        case diary, recipes, burn, stats, settings
    }

    @EnvironmentObject var appState: AppState
    @State private var selection: Tab = .diary

    var body: some View {
        TabView(selection: $selection) {

            // Diary
            DiaryScreen()
                .tabItem { Label("Diary", systemImage: "fork.knife") }
                .tag(Tab.diary)

            // Recipes
            RecipesScreen()
                .tabItem { Label("Recipes", systemImage: "book") }
                .tag(Tab.recipes)

            // Burn
            BurnScreen()
                .tabItem { Label("Burn", systemImage: "flame") }
                .tag(Tab.burn)

            // Stats
            StatsScreen()
                .tabItem { Label("Statistics", systemImage: "chart.bar") }
                .tag(Tab.stats)

            // Settings (moved from sheet to tab)
            SettingsView()
                .environmentObject(appState)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(Tab.settings)
        }
    }
}

// MARK: - Previews
#Preview {
    RootTabView()
        .environmentObject(AppState())
}
