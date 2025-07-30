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
