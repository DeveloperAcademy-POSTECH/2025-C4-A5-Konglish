//
//  ARContainer.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import SwiftUI

public struct ARContainer: UIViewControllerRepresentable {
    public init () {
    }
    
    public func makeUIViewController(context: Context) -> ARContainerViewController {
        ARContainerViewController()
    }
    
    public func updateUIViewController(_ uiViewController: ARContainerViewController, context: Context) {
    }
}
