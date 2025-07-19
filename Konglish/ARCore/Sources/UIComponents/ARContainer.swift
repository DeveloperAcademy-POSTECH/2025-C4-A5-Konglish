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
    
    @Binding var currentDetectedPlanes: Int
    
    public init(gameSettings: GameSettings, currentDetectedPlanes: Binding<Int>) {
        self.gameSettings = gameSettings
        self._currentDetectedPlanes = currentDetectedPlanes
    }
    
    public func makeUIViewController(context: Context) -> ARContainerViewController {
        let viewController = ARContainerViewController(gameSettings: gameSettings)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ARContainerViewController, context: Context) {
    }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    public class Coordinator: ARContainerViewControllerDelegate {
        var parent: ARContainer
        
        init(_ parent : ARContainer) {
            self.parent = parent
        }
        
        public func arContainerDidFindPlaneAnchor(_ arContainer: ARContainerViewController) {
            parent.currentDetectedPlanes += 1
        }
        
        public func arContainerDidFindAllPlaneAnchor(_ arContainer: ARContainerViewController) {
        }
    }
}
