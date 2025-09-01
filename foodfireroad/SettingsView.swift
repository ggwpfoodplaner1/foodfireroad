import SwiftUI
import WebKit

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                appearanceSection
                privacySection
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Sections
    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $appState.themeMode) {
                ForEach(ThemeMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text("Changes apply immediately.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var privacySection: some View {
        Section("Privacy") {
            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }
        }
    }
}

// MARK: - Privacy screen with inline WKWebView
private struct PrivacyPolicyView: View {
    private let urlString = "https://www.termsfeed.com/live/437132bd-6788-4a24-8126-a4ebbd87296f"

    var body: some View {
        WebView(urlString: urlString)
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - UIKit bridge
private struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        webView.backgroundColor = .clear
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // no-op
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
