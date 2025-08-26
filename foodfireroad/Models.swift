




import Foundation

// Приём пищи
struct Meal: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var tripTag: String?        // текстовый тег поездки
    var type: MealType
    var title: String
    var kcal: Int
    var portion: String
    var notes: String?
    var recipeId: UUID?         // ссылка на рецепт
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Завтрак"
    case lunch = "Обед"
    case dinner = "Ужин"
    case snack = "Перекус"
}

// Рецепт
struct Recipe: Identifiable, Codable {
    var id = UUID()
    var title: String
    var cuisine: String?
    var servings: Int
    var kcalPerServing: Int
    var ingredients: [Ingredient]
    var isFavorite: Bool = false
}

struct Ingredient: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: String
    var unit: String
}

// Активность (сжигание калорий)
struct Activity: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var type: String
    var minutes: Int
    var intensity: Int   // 1–3
    var kcal: Int
}

// Настройки
struct Settings: Codable {
    var dailyKcalGoal: Int
    var unitSystem: UnitSystem
}

enum UnitSystem: String, Codable, CaseIterable {
    case metric = "Метрическая"
    case imperial = "Имперская"
}
