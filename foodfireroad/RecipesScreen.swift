import SwiftUI
import Combine

struct RecipesScreen: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            VStack {
                if appState.recipes.isEmpty {
                    Spacer()
                    Text("To add a recipe, tap +")
                        .font(.headline.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Spacer()
                } else {
                    List {
                        ForEach(appState.recipes) { recipe in
                            RecipeRow(recipe: recipe)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let recipe = appState.recipes[index]
                                appState.deleteRecipe(recipe)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recipes")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAdd = true
                    } label: {
                        Text("+")
                            .font(.title.bold())
                    }
                    .accessibilityLabel("Add recipe")
                }
            }
            .sheet(isPresented: $showingAdd) {
                AddRecipeView()
                    .environmentObject(appState)
            }
            .onReceive(appState.$recipes) { _ in
                appState.saveToDisk()
            }
            .onAppear {
                appState.seedSampleDataIfNeeded()
            }
        }
    }
}

struct RecipeRow: View {
    @EnvironmentObject var appState: AppState
    let recipe: Recipe
    @State private var expanded = false
    @State private var showAddedAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(recipe.title)
                    .font(.headline)
                if recipe.isFavorite {
                    Image(systemName: "star.fill")
                        .imageScale(.small)
                }
                Spacer()
                Text("\(recipe.kcalPerServing) kcal/serving")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            if let cuisine = recipe.cuisine, !cuisine.isEmpty {
                Text(cuisine)
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            }

            DisclosureGroup(isExpanded: $expanded) {
                VStack(alignment: .leading, spacing: 4) {
                    if recipe.ingredients.isEmpty {
                        Text("No ingredients")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recipe.ingredients) { ing in
                            Text("• \(ing.title) — \(ing.amount) \(ing.unit)")
                                .font(.subheadline)
                        }
                    }

                    HStack {
                        Button("Add to diary") {
                            let meal = Meal(
                                date: Date(),
                                tripTag: nil,
                                type: .lunch,
                                title: recipe.title,
                                kcal: recipe.kcalPerServing,
                                portion: "1 serving",
                                notes: nil,
                                recipeId: recipe.id
                            )
                            appState.addMeal(meal)
                            showAddedAlert = true
                        }
                        .buttonStyle(.borderedProminent)

                        Spacer()

                        Button(recipe.isFavorite ? "Remove favorite" : "Mark favorite") {
                            var updated = recipe
                            updated.isFavorite.toggle()
                            appState.updateRecipe(updated)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 4)
            } label: {
                Text("Ingredients")
                    .font(.subheadline)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation { expanded.toggle() }
        }
        .padding(.vertical, 6)
        .alert("Added to diary", isPresented: $showAddedAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct AddRecipeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var cuisine: String = ""
    @State private var servings: String = "1"
    @State private var kcalPerServing: String = ""
    @State private var ingredients: [Ingredient] = []

    var body: some View {
        NavigationStack {
            Form {
                Section("Main info") {
                    TextField("Recipe name", text: $title)
                    TextField("Cuisine (optional)", text: $cuisine)
                    TextField("Servings", text: $servings)
                        .keyboardType(.numberPad)
                    TextField("Calories per serving", text: $kcalPerServing)
                        .keyboardType(.numberPad)
                }

                Section("Ingredients") {
                    if ingredients.isEmpty {
                        Text("Add ingredients")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(ingredients) { ing in
                            HStack {
                                Text(ing.title).font(.body)
                                Spacer()
                                Text("\(ing.amount) \(ing.unit)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            ingredients.remove(atOffsets: indexSet)
                        }
                    }

                    AddIngredientRow { newIng in
                        ingredients.append(newIng)
                    }
                }
            }
            .navigationTitle("New recipe")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let servingsInt = Int(servings),
                              let kcalInt = Int(kcalPerServing),
                              !title.trimmingCharacters(in: .whitespaces).isEmpty
                        else { return }

                        let recipe = Recipe(
                            title: title,
                            cuisine: cuisine.isEmpty ? nil : cuisine,
                            servings: servingsInt,
                            kcalPerServing: kcalInt,
                            ingredients: ingredients,
                            isFavorite: false
                        )
                        appState.addRecipe(recipe)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AddIngredientRow: View {
    var onAdd: (Ingredient) -> Void

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var unit: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Add ingredient").font(.subheadline)
            HStack {
                TextField("Name", text: $title)
                TextField("Amount", text: $amount)
                    .frame(width: 70)
                TextField("Unit", text: $unit)
                    .frame(width: 60)
                Button {
                    let trimmed = title.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    let ing = Ingredient(title: trimmed, amount: amount, unit: unit)
                    onAdd(ing)
                    title = ""; amount = ""; unit = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }
}
