//
//  ARContainerViewControllerDelegate.swift
//  ARCore
//
//  Created by 임영택 on 7/19/25.
//

/// ARContainerViewController의 작업을 위임받아 수행하는 대리자
public protocol ARContainerViewControllerDelegate: AnyObject {
    /// 새로운 평면 앵커를 찾았을 때 호출되는 메서드
    func arContainerDidFindPlaneAnchor(_ arContainer: ARContainerViewController)
}
