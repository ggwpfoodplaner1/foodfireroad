import SwiftUI
import Combine

struct DiaryScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddMeal = false
    @State private var showAddedAlert = false

    var body: some View {
        NavigationStack {
            VStack {
                if appState.meals.filter({ Calendar.current.isDateInToday($0.date) }).isEmpty {
                    Spacer()
                    Text("To add a meal, tap +")
                        .font(.headline.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(appState.meals.filter { Calendar.current.isDateInToday($0.date) }) { meal in
                            VStack(alignment: .leading) {
                                Text(meal.title)
                                    .font(.headline)
                                Text("\(meal.kcal) kcal • \(meal.portion)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let meal = appState.meals.filter { Calendar.current.isDateInToday($0.date) }[index]
                                appState.deleteMeal(meal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Diary")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddMeal = true
                    } label: {
                        Text("+")
                            .font(.title.bold())
                    }
                    .accessibilityLabel("Add meal")
                }
            }
            .sheet(isPresented: $showingAddMeal) {
                AddMealView(onAdded: {
                    showAddedAlert = true
                })
                .environmentObject(appState)
            }
            .onReceive(appState.$meals) { _ in
                appState.saveToDisk()
            }
            .alert("Added to diary", isPresented: $showAddedAlert) {
                Button("OK", role: .cancel) {}
            }
        }
    }
}

struct AddMealView: View {
    var onAdded: (() -> Void)? = nil
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var kcal: String = ""
    @State private var portion: String = ""
    @State private var showDigitsAlert: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                TextField("Meal name", text: $title)
                TextField("Calories", text: $kcal)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .onChange(of: kcal) { newValue in
                        let digitsOnly = newValue.filter { $0.isNumber }
                        if newValue != digitsOnly {
                            kcal = digitsOnly
                            showDigitsAlert = true
                        }
                    }
                TextField("Portion", text: $portion)
            }
            .navigationTitle("Add meal")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let kcalInt = Int(kcal) {
                            let newMeal = Meal(
                                date: Date(),
                                tripTag: nil,
                                type: .lunch,
                                title: title,
                                kcal: kcalInt,
                                portion: portion,
                                notes: nil,
                                recipeId: nil
                            )
                            appState.addMeal(newMeal)
                            onAdded?()
                            dismiss()
                        }
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
    DiaryScreen()
        .environmentObject(AppState())
}
