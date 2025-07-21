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
    
    /// 전체 개수의 모든 평면 앵커를 찾았을 때 호출되는 메서드. 찾을 평면 앵커의 개수는 `GameSettings`의
    /// `numberOfCards` 프로퍼티에 정의한다.
    ///
    /// 매번 평면 앵커를 찾을 때마다 `arContainerDidFindPlaneAnchor(_:)`가 호출되며, 마지막 평면 앵커를 찾은 경우
    /// `arContainerDidFindPlaneAnchor(_:)` 호출 이후 이 메서드가 호출된다.
    func arContainerDidFindAllPlaneAnchor(_ arContainer: ARContainerViewController)
}
