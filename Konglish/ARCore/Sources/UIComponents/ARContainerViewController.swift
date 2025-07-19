//
//  ARContainerViewController.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import UIKit
import RealityKit

/// ARView를 포함하는 UIViewController
public class ARContainerViewController: UIViewController {
    // MARK: - Properties
    internal let arView = ARView()
    public var isDebugModeEnabled = false // debugOption을 포함하고 싶으면 true로 지정한다. 세션을 다시 시작해야 반영된다.
    
    // MARK: - Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupARView()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pauseSession()
    }
}

extension ARContainerViewController {
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(arView)
        
        arView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
