//
//  ContentView.swift
//  GainGrid
//
//  Created by Carson Mulligan on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    
    var body: some View {
        WeeklyView()
            .environmentObject(viewModel)
    }
}

#Preview {
    ContentView()
}
