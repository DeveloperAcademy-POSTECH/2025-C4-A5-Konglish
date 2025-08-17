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
            
            if needBootstrapped() {
                let bootstrapper = DataBootstrapper(context: container.mainContext)
                try bootstrapper.bootstrap()
                setBootstrapSuccess(value: true)
            }

            return container
        } catch {
            setBootstrapSuccess(value: false)
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
}

extension KonglishApp {
    /// 부트스트랩이 필요한지 여부를 판단한다
    private static func needBootstrapped() -> Bool {
        let key = "hasBootstrapped"
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: key) {
            return false
        } else {
            return true
        }
    }
    
    /// 부트스트랩 필요 여부를 업데이트한다
    private static func setBootstrapSuccess(value: Bool) {
        let key = "hasBootstrapped"
        UserDefaults.standard.set(value, forKey: key)
    }
}
