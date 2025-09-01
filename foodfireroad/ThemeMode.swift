import SwiftUI

/// App-wide theme preference.
/// Stored in AppState and applied in FoodFireRoadApp via `.preferredColorScheme(...)`.
public enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    public var id: String { rawValue }

    /// Title used in Settings UI
    public var title: String {
        switch self {
        case .system: return "System"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    /// Mapping to SwiftUI ColorScheme. `nil` means follow system.
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}
