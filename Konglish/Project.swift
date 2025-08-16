import ProjectDescription

let project = Project(
    name: "Konglish",
    packages: [
        .remote(url: "https://github.com/Moya/Moya", requirement: .upToNextMinor(from: "15.0.3")),
        .remote(url: "https://github.com/airbnb/lottie-spm", requirement: .upToNextMinor(from: "4.5.2"))
    ],
    targets: [
        .target(
            name: "Konglish",
            destinations: .iOS,
            product: .app,
            bundleId: "app.konglish.Konglish",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "NSCameraUsageDescription": "AR을 위해 카메라 사용이 필요합니다",
                    "NSMicrophoneUsageDescription": "발음 분석을 위해 마이크 사용이 필요합니다",
                    "NSSpeechRecognitionUsageDescription": "발음 분석을 위해 음성 인식이 필요합니다",
                    "UIViewControllerBasedStatusBarAppearance": false,
                    "UIStatusBarHidden": true,
                ]
            ),
            sources: ["Konglish/Sources/**"],
            resources: ["Konglish/Resources/**"],
            dependencies: [
                .project(target: "Dependency", path: "./Dependency"),
                .project(target: "ARCore", path: "./ARCore"),
                .package(product: "Moya"),         
                .package(product: "Lottie")
            ]
        ),
        .target(
            name: "KonglishTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.KonglishTests",
            infoPlist: .default,
            sources: ["Konglish/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Konglish")]
        ),
    ]
)
