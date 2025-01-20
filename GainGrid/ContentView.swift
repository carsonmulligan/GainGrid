//
//  ContentView.swift
//  GainGrid
//
//  Created by Carson Mulligan on 1/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var selectedDay: String?
    @State private var showingAddSetSheet = false
    @State private var selectedSet: WorkoutSet?
    @State private var selectedExercise: String?
    
    private let backgroundColor = Color(hex: "0D1117")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Plan Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Plan")
                            .font(.title)
                            .foregroundColor(textColor)
                        
                        ForEach(Array(viewModel.workoutPlan.keys.sorted()), id: \.self) { day in
                            Button(action: {
                                selectedDay = day
                            }) {
                                WorkoutDayView(
                                    dayName: day,
                                    warmUp: viewModel.workoutPlan[day]?.warmUp ?? "",
                                    workouts: viewModel.workoutPlan[day]?.workouts ?? [],
                                    cardio: viewModel.workoutPlan[day]?.cardio ?? "",
                                    onWorkoutTap: { exercise in
                                        selectedExercise = exercise
                                        selectedSet = nil
                                        showingAddSetSheet = true
                                    }
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    // Logging Section
                    if let selectedDay = selectedDay {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Logging for \(selectedDay)")
                                .font(.title2)
                                .foregroundColor(textColor)
                            
                            ForEach(viewModel.currentSets) { set in
                                Button(action: {
                                    selectedSet = set
                                    selectedExercise = nil
                                    showingAddSetSheet = true
                                }) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(set.exerciseName)
                                                .font(.headline)
                                            Text("\(set.weight) - \(set.reps) reps")
                                                .font(.subheadline)
                                            if let notes = set.notes {
                                                Text(notes)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "pencil.circle.fill")
                                            .foregroundColor(.gray)
                                            .imageScale(.large)
                                    }
                                    .padding()
                                    .background(Color(hex: "0E4429"))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Button(action: {
                                selectedSet = nil
                                selectedExercise = nil
                                showingAddSetSheet = true
                            }) {
                                Text("Add Set")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "26A641"))
                                    .cornerRadius(8)
                            }
                            
                            if !viewModel.currentSets.isEmpty {
                                Button(action: {
                                    viewModel.commitSession()
                                }) {
                                    Text("Commit Session")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(hex: "39D353"))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Activity Graph Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Log")
                            .font(.title)
                            .foregroundColor(textColor)
                        
                        ActivityGraph(commits: viewModel.commitsByDate)
                        
                        // Legend
                        HStack(spacing: 12) {
                            ForEach(["0", "1-3", "4-5", "6-8", "9+"], id: \.self) { range in
                                HStack(spacing: 4) {
                                    ActivitySquare(commits: range == "0" ? 0 : 
                                                 range == "1-3" ? 1 :
                                                 range == "4-5" ? 4 :
                                                 range == "6-8" ? 6 : 9)
                                    Text(range)
                                        .font(.caption)
                                        .foregroundColor(textColor)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .background(backgroundColor)
            .sheet(isPresented: $showingAddSetSheet) {
                AddSetView(viewModel: viewModel, existingSet: selectedSet, prefilledExercise: selectedExercise)
            }
            .navigationTitle("Workout Tracker")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AddSetView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WorkoutViewModel
    let existingSet: WorkoutSet?
    let prefilledExercise: String?
    
    @State private var exerciseName: String
    @State private var weight: String
    @State private var reps: Int
    @State private var notes: String
    
    init(viewModel: WorkoutViewModel, existingSet: WorkoutSet? = nil, prefilledExercise: String? = nil) {
        self.viewModel = viewModel
        self.existingSet = existingSet
        self.prefilledExercise = prefilledExercise
        
        // Initialize state with existing values, prefilled exercise, or defaults
        _exerciseName = State(initialValue: existingSet?.exerciseName ?? prefilledExercise ?? "")
        _weight = State(initialValue: existingSet?.weight ?? "")
        _reps = State(initialValue: existingSet?.reps ?? 1)
        _notes = State(initialValue: existingSet?.notes ?? "")
        
        // Extract reps from exercise description if available
        if let exercise = prefilledExercise {
            if let repsRange = exercise.range(of: "\\d+(?:-\\d+)? reps", options: .regularExpression) {
                let repsText = exercise[repsRange]
                if let firstNumber = repsText.components(separatedBy: CharacterSet.decimalDigits.inverted).first,
                   let defaultReps = Int(firstNumber) {
                    _reps = State(initialValue: defaultReps)
                }
            }
            
            // Extract weight description if available
            if exercise.contains("heavy") {
                _notes = State(initialValue: "Heavy weight")
            } else if exercise.contains("Light") {
                _notes = State(initialValue: "Light weight")
            }
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Exercise Name", text: $exerciseName)
                TextField("Weight (e.g. 50 lbs)", text: $weight)
                Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                TextField("Notes (optional)", text: $notes)
            }
            .navigationTitle(existingSet != nil ? "Edit Set" : "Add Set")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(existingSet != nil ? "Update" : "Save") {
                    if let existingSet = existingSet {
                        viewModel.updateSet(
                            existingSet: existingSet,
                            exerciseName: exerciseName,
                            weight: weight,
                            reps: reps,
                            notes: notes.isEmpty ? nil : notes
                        )
                    } else {
                        viewModel.addSet(
                            exerciseName: exerciseName,
                            weight: weight,
                            reps: reps,
                            notes: notes.isEmpty ? nil : notes
                        )
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(exerciseName.isEmpty || weight.isEmpty)
            )
        }
    }
}

class WorkoutViewModel: ObservableObject {
    private let dataService = LocalDataService()
    
    @Published var workoutPlan: [String: (warmUp: String, workouts: [String], cardio: String)] = [:]
    @Published var currentSets: [WorkoutSet] = []
    @Published var commitsByDate: [Date: Int] = [:]
    
    init() {
        loadWorkoutPlan()
        loadCommits()
    }
    
    private func loadWorkoutPlan() {
        // In a real app, we would parse the complete plan from LocalDataService.defaultWorkoutPlan
        // For now, we'll just use the Monday example
        if let mondayPlan = LocalDataService.defaultWorkoutPlan["Monday (Chest)"] {
            workoutPlan["Monday (Chest)"] = (
                warmUp: mondayPlan["Warm-Up"] as? String ?? "",
                workouts: mondayPlan["Workouts"] as? [String] ?? [],
                cardio: mondayPlan["Cardio"] as? String ?? ""
            )
        }
    }
    
    private func loadCommits() {
        let commits = dataService.loadAllCommits()
        let calendar = Calendar.current
        
        commitsByDate = Dictionary(grouping: commits) { commit in
            calendar.startOfDay(for: commit.timestamp)
        }.mapValues { $0.count }
    }
    
    func addSet(exerciseName: String, weight: String, reps: Int, notes: String?) {
        let newSet = WorkoutSet(
            exerciseName: exerciseName,
            notes: notes,
            weight: weight,
            reps: reps,
            date: Date()
        )
        currentSets.append(newSet)
    }
    
    func updateSet(existingSet: WorkoutSet, exerciseName: String, weight: String, reps: Int, notes: String?) {
        if let index = currentSets.firstIndex(where: { $0.id == existingSet.id }) {
            let updatedSet = WorkoutSet(
                id: existingSet.id,
                exerciseName: exerciseName,
                notes: notes,
                weight: weight,
                reps: reps,
                date: existingSet.date
            )
            currentSets[index] = updatedSet
        }
    }
    
    func commitSession() {
        guard !currentSets.isEmpty else { return }
        
        let markdown = dataService.generateMarkdownFromSets(currentSets)
        let commit = LocalCommit(
            message: "Completed workout session",
            timestamp: Date(),
            fileName: "workout_\(Date().timeIntervalSince1970).md",
            content: markdown
        )
        
        dataService.saveCommit(commit)
        currentSets.removeAll()
        loadCommits()
    }
}

#Preview {
    ContentView()
}
