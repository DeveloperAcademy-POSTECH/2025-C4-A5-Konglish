//
//  Project.swift
//  Config
//
//  Created by Apple MacBook on 7/18/25.
//

import Foundation
import ProjectDescription

let project = Project(
    name: "ARCore",
    packages: [.local(path: "Packages/KonglishARProject/")],
    targets: [
        .target(name: "ARCore",
                destinations: .iOS,
                product: .staticFramework,
                bundleId: "app.arCore.Konglish",
                infoPlist: .default,
                sources: ["Sources/**"],
                resources: [],
                dependencies: [.package(product: "KonglishARProject")]
        )
    ]
)
