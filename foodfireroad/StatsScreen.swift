





import SwiftUI

struct StatsScreen: View {
    @EnvironmentObject var appState: AppState

    private var totalIntake: Int {
        appState.meals.reduce(0) { $0 + $1.kcal }
    }

    private var totalBurn: Int {
        appState.activities.reduce(0) { $0 + $1.kcal }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Overview") {
                    HStack {
                        Text("Total intake")
                        Spacer()
                        Text("\(totalIntake) kcal")
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Total burn")
                        Spacer()
                        Text("\(totalBurn) kcal")
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text("\(totalIntake - totalBurn) kcal")
                            .foregroundColor(totalIntake - totalBurn > 0 ? .red : .green)
                    }
                }

                Section("Top meals") {
                    ForEach(appState.meals.prefix(3)) { meal in
                        Text("\(meal.title) • \(meal.kcal) kcal")
                    }
                }

                Section("Top activities") {
                    ForEach(appState.activities.prefix(3)) { act in
                        Text("\(act.type) • \(act.kcal) kcal")
                    }
                }
            }
            .navigationTitle("Statistics")
        }
    }
}

// MARK: - Previews
#Preview {
    StatsScreen()
        .environmentObject(AppState())
}
