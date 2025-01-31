import SwiftUI

struct DayDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: WorkoutViewModel
    let day: String
    @State private var showTooltips = true
    
    private let backgroundColor = Color(.systemBackground)
    private let textColor = Color(.label)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let dayPlan = viewModel.workoutPlan[day] {
                        // Warm-up section
                        if !dayPlan.warmUp.isEmpty {
                            Section(header: Text("Warm-up").font(.headline)) {
                                Text(dayPlan.warmUp)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Main workouts
                        ForEach(dayPlan.workouts, id: \.self) { exercise in
                            ExerciseCommitCard(exerciseName: exercise, day: day)
                                .overlay(
                                    Group {
                                        if showTooltips {
                                            TooltipView()
                                                .offset(y: -60)
                                        }
                                    }
                                )
                        }
                        
                        // Cardio section
                        if !dayPlan.cardio.isEmpty {
                            Section(header: Text("Cardio").font(.headline)) {
                                Text(dayPlan.cardio)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Commit Button
                        Button(action: {
                            viewModel.commitSession(for: day)
                            dismiss()
                        }) {
                            Text("Complete Workout")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top)
                        .disabled(viewModel.currentSets.isEmpty)
                    } else {
                        Text("Rest Day")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle(day)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Weekly Plan")
                        }
                    }
                }
            }
        }
        .onAppear {
            // Hide tooltips after first viewing
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showTooltips = false
                }
            }
        }
    }
}

struct TooltipView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("View exercise history")
                }
                
                HStack {
                    Image(systemName: "chart.bar.fill")
                    Text("Track your progress")
                }
            }
            .font(.caption)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(radius: 4)
        }
        .transition(.opacity)
    }
}

struct ExerciseCommitCard: View {
    let exerciseName: String
    let day: String
    @State private var showingAddSet = false
    @State private var showingHistory = false
    @State private var showingProgress = false
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exerciseName)
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showingHistory.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(.blue)
                }
                .help("View exercise history")
                
                Button(action: { showingProgress.toggle() }) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                }
                .help("Track your progress")
            }
            
            if let sets = viewModel.getCurrentSets(for: exerciseName, on: day) {
                ForEach(sets) { set in
                    HStack {
                        Text("\(set.weight) × \(set.reps) reps")
                        if let notes = set.notes {
                            Text("- \(notes)")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.subheadline)
                }
            }
            
            Button(action: { showingAddSet.toggle() }) {
                Text("Add Set")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingAddSet) {
            AddSetView(exerciseName: exerciseName, day: day)
        }
        .sheet(isPresented: $showingHistory) {
            ExerciseHistoryView(exerciseName: exerciseName)
        }
        .sheet(isPresented: $showingProgress) {
            ExerciseProgressView(exerciseName: exerciseName)
        }
    }
}

struct ExerciseProgressView: View {
    let exerciseName: String
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Weight Progress")) {
                    // Weight progress chart would go here
                    Text("Weight progress visualization coming soon")
                }
                
                Section(header: Text("Volume Progress")) {
                    // Volume progress chart would go here
                    Text("Volume progress visualization coming soon")
                }
                
                Section(header: Text("Personal Records")) {
                    if let prs = viewModel.getPersonalRecords(for: exerciseName) {
                        ForEach(prs) { pr in
                            VStack(alignment: .leading) {
                                Text(pr.type)
                                    .font(.headline)
                                Text("\(pr.value) on \(pr.date.formatted())")
                                    .font(.subheadline)
                            }
                        }
                    } else {
                        Text("No personal records yet")
                    }
                }
            }
            .navigationTitle("\(exerciseName) Progress")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    DayDetailView(day: "Monday")
        .environmentObject(WorkoutViewModel())
}