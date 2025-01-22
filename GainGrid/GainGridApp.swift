//
//  GainGridApp.swift
//  GainGrid
//
//  Created by Carson Mulligan on 1/20/25.
//

import SwiftUI

@main
struct LocalCommitWorkoutRepoApp: App {
    var body: some Scene {
        WindowGroup {
            WeeklyView()
                .preferredColorScheme(.dark)
        }
    }
}
