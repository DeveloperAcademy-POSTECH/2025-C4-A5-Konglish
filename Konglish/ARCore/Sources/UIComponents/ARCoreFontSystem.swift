//
//  ARCoreFontSystem.swift
//  ARCore
//
//  Created by 임영택 on 7/25/25.
//

import SwiftUI

/// ARCore 모듈에서 사용할 폰트 목록
enum ARCoreFont {
    case title
    case subtitle
    case body
}

/// 폰트 설정을 위한 구조체
public struct ARCoreFontSetting {
    let title: Font
    let subtitle: Font
    let body: Font
    
    public init(title: Font, subtitle: Font, body: Font) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}

/// 주입받은 폰트를 가지고 있는 클래스. 싱글톤 사용 강제.
class ARCoreFontSystem {
    static let shared = ARCoreFontSystem()
    
    private(set) var title: Font?
    private(set) var subtitle: Font?
    private(set) var body: Font?
    
    private init() { }
    
    /// 폰트 시스템을 설정한다. 각 타이포그라피에 따라 Font 객체를 지정한다.
    func configure(title: Font, subtitle: Font, body: Font) {
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
    
    /// 폰트 시스템을 설정한다. ARCoreFontSetting 구조체를 넘긴다.
    func configure(with setting: ARCoreFontSetting) {
        configure(title: setting.title, subtitle: setting.subtitle, body: setting.body)
    }
    
    /// 특정 타이포그라피에 대한 폰트를 반환한다.
    func font(for style: ARCoreFont) -> Font {
        switch style {
        case .title: title ?? .title
        case .subtitle: subtitle ?? .title2
        case .body: body ?? .body
        }
    }
}

extension Font {
    static var arCoreTitle: Font {
        ARCoreFontSystem.shared.font(for: .title)
    }
    
    static var arCoreSubtitle: Font {
        ARCoreFontSystem.shared.font(for: .subtitle)
    }
    
    static var arCoreBody: Font {
        ARCoreFontSystem.shared.font(for: .body)
    }
}
