import SwiftUI
import Combine

struct BurnScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            VStack {
                if appState.activities.isEmpty {
                    Spacer()
                    Text("To add an activity, tap +")
                        .font(.headline.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(appState.activities) { activity in
                            VStack(alignment: .leading) {
                                Text(activity.type)
                                    .font(.headline)
                                Text("\(activity.minutes) min • \(activity.kcal) kcal")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let act = appState.activities[index]
                                appState.deleteActivity(act)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Burn")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Text("+")
                            .font(.title.bold())
                    }
                    .accessibilityLabel("Add activity")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddActivityView()
                    .environmentObject(appState)
            }
            .onReceive(appState.$activities) { _ in
                appState.saveToDisk()
            }
        }
    }
}

struct AddActivityView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var type: String = ""
    @State private var minutes: String = ""
    @State private var intensity: Int = 1
    @State private var kcal: Int = 0
    @State private var showDigitsAlert: Bool = false

    // Simple table of base kcal values
    let baseKcalPerMinute: [String: Int] = [
        "Walking": 4,
        "Running": 10,
        "Cycling": 8,
        "Swimming": 9,
        "Yoga": 3
    ]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Activity type", text: $type)

                TextField("Minutes", text: $minutes)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onChange(of: minutes) { newValue in
                        let digitsOnly = newValue.filter { $0.isNumber }
                        if newValue != digitsOnly {
                            minutes = digitsOnly
                            showDigitsAlert = true
                        }
                    }

                Picker("Intensity", selection: $intensity) {
                    Text("Low").tag(1)
                    Text("Medium").tag(2)
                    Text("High").tag(3)
                }
                .pickerStyle(.segmented)

                if let minutesInt = Int(minutes), !type.isEmpty {
                    let base = baseKcalPerMinute[type] ?? 5
                    let calculated = minutesInt * base * intensity / 2
                    Text("≈ \(calculated) kcal")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            .navigationTitle("New Activity")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let minutesInt = Int(minutes), !type.isEmpty else { return }
                        let base = baseKcalPerMinute[type] ?? 5
                        let calculated = minutesInt * base * intensity / 2
                        let activity = Activity(
                            date: Date(),
                            type: type,
                            minutes: minutesInt,
                            intensity: intensity,
                            kcal: calculated
                        )
                        appState.addActivity(activity)
                        dismiss()
                    }
                }
            }
            .alert("Numbers only", isPresented: $showDigitsAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter digits only")
            }
        }
    }
}

// MARK: - Previews

#Preview {
    BurnScreen()
        .environmentObject(AppState())
}
