//
//  ARContainerViewController.swift
//  ARCoreManifests
//
//  Created by 임영택 on 7/19/25.
//

import UIKit
import RealityKit
import os.log

/// ARView를 포함하는 UIViewController
public class ARContainerViewController: UIViewController {
    // MARK: - Properties
    let arView = ARView()
    
    /// ARSession debugOption 포함 여부를 지정한다.  debugOption을 포함하고 싶으면 true로 지정한다. 세션을 다시 시작해야 반영된다.
    public var isDebugModeEnabled = false
    
    /// 대리자
    public weak var delegate: ARContainerViewControllerDelegate?
    
    /// 로거
    let logger = Logger.of("ARContainerViewController")
    
    /// 기능을 제공하는 클래스들 (ARFeatureProvider)
    var planeVisualizer: PlaneVisualizer?
    
    /// 인식된 평면의 시각화 엔티티들
    var detectedPlaneEntities: [UUID: AnchorEntity] = [:]
    
    // MARK: 초기화가 필요한 게임 속성
    let gameSettings: GameSettings
    
    // MARK: - Init
    init(gameSettings: GameSettings) {
        self.gameSettings = gameSettings
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
