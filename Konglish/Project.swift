import ProjectDescription

// 버전 정보
let marketingVersion = "1.0.0"
let currentProjectVersion = "1"

let project = Project(
    name: "Konglish",
    packages: [
        .remote(url: "https://github.com/Moya/Moya", requirement: .upToNextMinor(from: "15.0.3")),
        .remote(url: "https://github.com/airbnb/lottie-spm", requirement: .upToNextMinor(from: "4.5.2"))
    ],
    targets: [
        .target(
            name: "Konglish",
            destinations: [.iPad],
            product: .app,
            bundleId: "app.konglish.Konglish",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    
                    "CFBundleShortVersionString": .string(marketingVersion),
                    "CFBundleVersion": .string(currentProjectVersion),
                    "LSApplicationCategoryType": "public.app-category.education",
                    
                    
                    "UIRequiredDeviceCapabilities": ["arkit"],
                    "UIRequiresFullScreen": true,
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSCameraUsageDescription": "AR을 위해 카메라 사용이 필요합니다",
                    "NSMicrophoneUsageDescription": "발음 분석을 위해 마이크 사용이 필요합니다",
                    "NSSpeechRecognitionUsageDescription": "발음 분석을 위해 음성 인식이 필요합니다",
                    "UIViewControllerBasedStatusBarAppearance": false,
                    "UIStatusBarHidden": true,
                    "UISupportedInterfaceOrientations~ipad": [
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight"
                    ]
                ]
            ),
            sources: ["Konglish/Sources/**"],
            resources: ["Konglish/Resources/**"],
            dependencies: [
                .project(target: "Dependency", path: "./Dependency"),
                .project(target: "ARCore", path: "./ARCore"),
                .package(product: "Moya"),
                .package(product: "Lottie")
            ],
            settings: .settings(
                base: [
                    "MARKETING_VERSION": .string(marketingVersion),
                    "CURRENT_PROJECT_VERSION": .string(currentProjectVersion)
                ]
            )
        ),
        .target(
            name: "KonglishTests",
            destinations: [.iPad],
            product: .unitTests,
            bundleId: "dev.tuist.KonglishTests",
            infoPlist: .default,
            sources: ["Konglish/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Konglish")]
        ),
    ]
)
