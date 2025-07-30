import SwiftUI
import SwiftData
import Dependency

@main
struct KonglishApp: App {
    @State var container = DIContainer(navigationRouter: NavigationRouter<AppRoute>())

    private let modelContainer: ModelContainer = {
        do {
            let container = try ModelContainer(for: 
                                                CategoryModel.self,
                                               CardModel.self,
                                               LevelModel.self,
                                               GameSessionModel.self,
                                               UsedCardModel.self
            )
            
            if isFirstLaunch() {
                let bootstrapper = DataBootstrapper(context: container.mainContext)
                bootstrapper.bootstrap()
            }

            return container
        } catch {
            fatalError("SwiftData 컨테이너 초기화 실패: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            GuidingView()
                .environmentObject(container)
                .modelContainer(modelContainer)
        }
    }

    /// 최초 1회 실행 여부 확인
    private static func isFirstLaunch() -> Bool {
        let key = "hasBootstrapped"
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: key) {
            return false
        } else {
            defaults.set(true, forKey: key)
            return true
        }
    }
}
