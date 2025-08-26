



import Foundation

// MARK: - Codable container for all app data

struct AppData: Codable {
    var meals: [Meal]
    var recipes: [Recipe]
    var activities: [Activity]
    var settings: Settings
}

// MARK: - Disk Storage

enum Storage {
    private static let fileName = "appdata.json"

    private static var fileURL: URL {
        let folder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return folder.appendingPathComponent(fileName)
    }

    static func load() -> AppData {
        let url = fileURL
        guard FileManager.default.fileExists(atPath: url.path) else {
            // Default empty state
            return AppData(
                meals: [],
                recipes: [],
                activities: [],
                settings: Settings(dailyKcalGoal: 2000, unitSystem: .metric)
            )
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(AppData.self, from: data)
            return decoded
        } catch {
            // Если файл повреждён — начинаем с пустого состояния,
            // чтобы не крашить приложение.
            return AppData(
                meals: [],
                recipes: [],
                activities: [],
                settings: Settings(dailyKcalGoal: 2000, unitSystem: .metric)
            )
        }
    }

    static func save(_ state: AppData) {
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // В MVP игнорируем ошибку записи (можно добавить логирование позже).
        }
    }
}

// MARK: - AppState helpers

extension AppState {
    /// Загружает данные из Storage в текущий AppState.
    func loadFromDisk() {
        let data = Storage.load()
        self.meals = data.meals
        self.recipes = data.recipes
        self.activities = data.activities
        self.settings = data.settings
    }

    /// Сохраняет текущие данные AppState в Storage.
    func saveToDisk() {
        let data = AppData(
            meals: self.meals,
            recipes: self.recipes,
            activities: self.activities,
            settings: self.settings
        )
        Storage.save(data)
    }
}
