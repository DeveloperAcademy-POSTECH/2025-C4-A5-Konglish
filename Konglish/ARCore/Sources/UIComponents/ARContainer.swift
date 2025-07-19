//
//  ARContainer.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import SwiftUI

/// ARContainerViewController를 SwiftUI로 브릿지하는 UIViewControllerRepresentable 클래스
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
        uiViewController.delegate = context.coordinator
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
    
    public class Coordinator: ARContainerViewControllerDelegate {
        public func arContainerDidFindPlaneAnchor(_ arContainer: ARContainerViewController) {
            print("arContainerDidFindPlaneAnchor")
        }
        
        public func arContainerDidFindAllPlaneAnchor(_ arContainer: ARContainerViewController) {
            print("arContainerDidFindAllPlaneAnchor")
        }
    }
}
