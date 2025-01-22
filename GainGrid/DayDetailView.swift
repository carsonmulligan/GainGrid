import SwiftUI

struct DayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WorkoutViewModel
    let day: String
    
    @State private var showingAddSetSheet = false
    @State private var selectedSet: WorkoutSet?
    @State private var selectedExercise: String?
    @State private var showingHistory = false
    
    private let backgroundColor = Color(hex: "0D1117")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let plan = viewModel.workoutPlan[day] {
                        // Quick Commit Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Quick Commit")
                                .font(.title2)
                                .foregroundColor(textColor)
                            
                            if let lastWorkout = viewModel.getLastWorkout(for: day) {
                                Text("Last workout: \(lastWorkout.date.formatted(.dateTime.month().day()))")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            ForEach(Array(plan.workouts.enumerated()), id: \.element) { index, workout in
                                QuickCommitRow(
                                    exercise: workout,
                                    lastWeight: viewModel.getLastWeight(for: workout, day: day),
                                    onCommit: { weight, reps, notes in
                                        viewModel.addSet(
                                            exerciseName: workout,
                                            weight: weight,
                                            reps: reps,
                                            notes: notes
                                        )
                                    }
                                )
                            }
                            
                            if !viewModel.currentSets.isEmpty {
                                Button(action: {
                                    viewModel.commitSession(for: day)
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Commit Workout")
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
                        
                        // History Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("History")
                                    .font(.title2)
                                    .foregroundColor(textColor)
                                Spacer()
                                Button(action: { showingHistory.toggle() }) {
                                    Text(showingHistory ? "Hide" : "Show")
                                        .foregroundColor(Color(hex: "58A6FF"))
                                }
                            }
                            
                            if showingHistory {
                                ForEach(viewModel.getWorkoutHistory(for: day), id: \.date) { workout in
                                    WorkoutHistoryCard(workout: workout)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .background(backgroundColor)
            .navigationTitle(day)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        selectedSet = nil
                        selectedExercise = nil
                        showingAddSetSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(textColor)
                    }
                }
            }
            .sheet(isPresented: $showingAddSetSheet) {
                AddSetView(viewModel: viewModel, existingSet: selectedSet, prefilledExercise: selectedExercise)
            }
        }
        .onAppear {
            viewModel.selectedDay = day
        }
    }
}

struct QuickCommitRow: View {
    let exercise: String
    let lastWeight: String?
    let onCommit: (String, Int, String?) -> Void
    
    @State private var weight: String = ""
    @State private var reps: Int = 1
    @State private var notes: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("Weight", text: $weight)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .frame(width: 80)
                
                Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                    .frame(width: 120)
                
                Button(action: {
                    guard !weight.isEmpty else { return }
                    onCommit(weight, reps, notes.isEmpty ? nil : notes)
                    weight = ""
                    reps = 1
                    notes = ""
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "39D353"))
                        .imageScale(.large)
                }
            }
            
            if let lastWeight = lastWeight {
                Text("Last: \(lastWeight)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "161B22"))
        .cornerRadius(8)
    }
}

struct WorkoutHistoryCard: View {
    let workout: WorkoutHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(workout.date.formatted(.dateTime.month().day().year()))
                .font(.headline)
                .foregroundColor(.white)
            
            ForEach(workout.sets) { set in
                HStack {
                    Text(set.exerciseName)
                        .font(.subheadline)
                    Spacer()
                    Text("\(set.weight) × \(set.reps)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "161B22"))
        .cornerRadius(8)
    }
} 