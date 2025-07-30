import SwiftUI
import Dependency

@main
struct KonglishApp: App {
    
    @State var container = DIContainer(navigationRouter: NavigationRouter<AppRoute>())
    var body: some Scene {
        WindowGroup {
            GuidingView()
                .environmentObject(container)
        }
    }
}
