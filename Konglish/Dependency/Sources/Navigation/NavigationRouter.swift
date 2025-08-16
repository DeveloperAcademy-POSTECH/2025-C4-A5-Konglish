//
//  NavigationRouter.swift
//  Config
//
//  Created by Apple MacBook on 7/18/25.
//

import Foundation

@Observable
public final class NavigationRouter<Route: Hashable> {
    public var path: [Route] = []
    
    public init() {}
    
    public func push(_ route: Route) {
        path.append(route)
    }
    
    public func pop() {
        _ = path.popLast()
    }
    
    public func reset() {
        path.removeAll()
    }
}
