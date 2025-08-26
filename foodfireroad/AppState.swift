import Foundation

class AppState: ObservableObject {
    // Все данные приложения
    @Published var meals: [Meal] = []
    @Published var recipes: [Recipe] = []
    @Published var activities: [Activity] = []
    @Published var settings: Settings = Settings(dailyKcalGoal: 2000, unitSystem: .metric)

    // Методы для работы с приёмами пищи
    func addMeal(_ meal: Meal) {
        meals.append(meal)
    }

    func updateMeal(_ meal: Meal) {
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
        }
    }

    func deleteMeal(_ meal: Meal) {
        meals.removeAll { $0.id == meal.id }
    }

    // Методы для работы с рецептами
    func addRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
    }

    func updateRecipe(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            recipes[index] = recipe
        }
    }

    func deleteRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }

    // Методы для работы с активностями
    func addActivity(_ activity: Activity) {
        activities.append(activity)
    }

    func updateActivity(_ activity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            activities[index] = activity
        }
    }

    func deleteActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
    }
    // MARK: - Seeding
    /// Seed sample healthy recipes on first launch (only if recipes are empty)
    func seedSampleDataIfNeeded() {
        guard recipes.isEmpty else { return }

        let r1 = Recipe(
            title: "Greek Salad",
            cuisine: "Mediterranean",
            servings: 2,
            kcalPerServing: 180,
            ingredients: [
                Ingredient(title: "Cucumber", amount: "1", unit: "pc"),
                Ingredient(title: "Tomatoes", amount: "2", unit: "pcs"),
                Ingredient(title: "Red onion", amount: "1/4", unit: "pc"),
                Ingredient(title: "Feta cheese", amount: "60", unit: "g"),
                Ingredient(title: "Olives", amount: "10", unit: "pcs"),
                Ingredient(title: "Olive oil", amount: "1", unit: "tbsp"),
                Ingredient(title: "Lemon juice", amount: "1", unit: "tbsp")
            ],
            isFavorite: true
        )

        let r2 = Recipe(
            title: "Oatmeal with Berries",
            cuisine: "Breakfast",
            servings: 1,
            kcalPerServing: 320,
            ingredients: [
                Ingredient(title: "Rolled oats", amount: "60", unit: "g"),
                Ingredient(title: "Milk or water", amount: "200", unit: "ml"),
                Ingredient(title: "Blueberries", amount: "50", unit: "g"),
                Ingredient(title: "Banana", amount: "1/2", unit: "pc"),
                Ingredient(title: "Honey (optional)", amount: "1", unit: "tsp")
            ],
            isFavorite: false
        )

        let r3 = Recipe(
            title: "Grilled Chicken & Quinoa Bowl",
            cuisine: "Healthy",
            servings: 2,
            kcalPerServing: 450,
            ingredients: [
                Ingredient(title: "Chicken breast", amount: "250", unit: "g"),
                Ingredient(title: "Quinoa (dry)", amount: "120", unit: "g"),
                Ingredient(title: "Cherry tomatoes", amount: "100", unit: "g"),
                Ingredient(title: "Spinach", amount: "60", unit: "g"),
                Ingredient(title: "Olive oil", amount: "1", unit: "tbsp"),
                Ingredient(title: "Lemon", amount: "1/2", unit: "pc")
            ],
            isFavorite: false
        )

        let r4 = Recipe(
            title: "Veggie Omelette",
            cuisine: "Breakfast",
            servings: 1,
            kcalPerServing: 300,
            ingredients: [
                Ingredient(title: "Eggs", amount: "2", unit: "pcs"),
                Ingredient(title: "Egg whites", amount: "2", unit: "pcs"),
                Ingredient(title: "Bell pepper", amount: "1/4", unit: "pc"),
                Ingredient(title: "Mushrooms", amount: "80", unit: "g"),
                Ingredient(title: "Spinach", amount: "40", unit: "g")
            ],
            isFavorite: false
        )

        let r5 = Recipe(
            title: "Lentil Soup",
            cuisine: "Vegetarian",
            servings: 3,
            kcalPerServing: 250,
            ingredients: [
                Ingredient(title: "Red lentils (dry)", amount: "200", unit: "g"),
                Ingredient(title: "Carrot", amount: "1", unit: "pc"),
                Ingredient(title: "Onion", amount: "1", unit: "pc"),
                Ingredient(title: "Garlic", amount: "2", unit: "cloves"),
                Ingredient(title: "Vegetable broth", amount: "800", unit: "ml"),
                Ingredient(title: "Olive oil", amount: "1", unit: "tbsp")
            ],
            isFavorite: false
        )

        recipes = [r1, r2, r3, r4, r5]
    }
}
