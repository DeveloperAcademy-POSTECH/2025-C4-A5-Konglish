//
//  FinishedOverlay.swift
//  Konglish
//
//  Created by 임영택 on 7/29/25.
//

import SwiftUI

struct FinishedOverlay: View {
    let gameSessionModel: GameSessionModel
    
    var body: some View {
        CompleteWindow(model: gameSessionModel)
    }
}
