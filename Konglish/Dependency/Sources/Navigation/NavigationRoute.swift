//
//  NavigationDestination.swift
//  Config
//
//  Created by Apple MacBook on 7/18/25.
//

import Foundation
import SwiftData

public enum AppRoute: Hashable {
    case category
    case level(categoryId: UUID)
    case ar(levelId: UUID)
}
