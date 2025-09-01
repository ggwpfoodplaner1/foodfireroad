import SwiftUI

@main
struct FoodFireRoadApp: App {
    @StateObject private var appState = AppState()
    
    
    @Environment(\.scenePhase) private var scenePhase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    
    
    init() {
        
        NotificationCenter.default.post(name: Notification.Name("art.icon.loading.start"), object: nil)
        IconSettings.shared.attach()
    }
    
    var body: some Scene {
        WindowGroup {
            TabSettingsView{
                RootTabView()
                    .environmentObject(appState)
                    .preferredColorScheme(appState.themeMode.colorScheme) // ← применяем тему

                    .onAppear {
                        appState.loadFromDisk()
                    }
            }
           
            
            
            .onAppear {
                OrientationGate.allowAll = false
            }
            
            .onChange(of: scenePhase) { newPhase in
                switch newPhase {
                case .inactive, .background:
                    appState.saveToDisk()
                default:
                    break
                }
            }
            
            
        }
        
       
       
        
        
        
        
        
        
    }
    
    
    

    
    final class AppDelegate: NSObject, UIApplicationDelegate {
        func application(_ application: UIApplication,
                         supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            if OrientationGate.allowAll {
                return [.portrait, .landscapeLeft, .landscapeRight]
            } else {
                return [.portrait]
            }
        }
    }
    
    
    
}

