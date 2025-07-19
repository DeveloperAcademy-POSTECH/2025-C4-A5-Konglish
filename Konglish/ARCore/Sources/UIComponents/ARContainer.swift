//
//  ARContainer.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import SwiftUI

public struct ARContainer: UIViewControllerRepresentable {
    // MARK: - Properties
    let gameSettings: GameSettings
    
    public init(gameSettings: GameSettings) {
        self.gameSettings = gameSettings
    }
    
    public func makeUIViewController(context: Context) -> ARContainerViewController {
        ARContainerViewController(gameSettings: gameSettings)
    }
    
    public func updateUIViewController(_ uiViewController: ARContainerViewController, context: Context) {
    }
}
