




import SwiftUI

struct SettingsSheet: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var dailyGoalText: String = ""
    @State private var unitSystem: UnitSystem = .metric

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily goal") {
                    TextField("Daily calorie goal (kcal)", text: $dailyGoalText)
                        .keyboardType(.numberPad)
                }

                Section("Units") {
                    Picker("Unit system", selection: $unitSystem) {
                        Text("Metric").tag(UnitSystem.metric)
                        Text("Imperial").tag(UnitSystem.imperial)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button(role: .destructive) {
                        // Soft reset to defaults
                        dailyGoalText = "2000"
                        unitSystem = .metric
                    } label: {
                        Text("Reset to defaults")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Int(dailyGoalText) ?? appState.settings.dailyKcalGoal
                        appState.settings = Settings(dailyKcalGoal: goal, unitSystem: unitSystem)
                        appState.saveToDisk()
                        dismiss()
                    }
                }
            }
            .onAppear {
                dailyGoalText = String(appState.settings.dailyKcalGoal)
                unitSystem = appState.settings.unitSystem
            }
        }
    }
}

// MARK: - Previews

#Preview {
    SettingsSheet()
        .environmentObject(AppState())
}
