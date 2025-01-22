import SwiftUI

struct DayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WorkoutViewModel
    let day: String
    
    @State private var showingHistory = false
    
    private let backgroundColor = Color(hex: "0D1117")
    private let textColor = Color(hex: "C9D1D9")
    private let secondaryColor = Color(hex: "161B22")
    
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
                            
                            ForEach(plan.workouts, id: \.self) { workout in
                                ExerciseCommitCard(
                                    exercise: workout,
                                    lastWeight: viewModel.getLastWeight(for: workout, day: day),
                                    onCommit: { weight, reps in
                                        viewModel.addSet(
                                            exerciseName: workout,
                                            weight: weight,
                                            reps: reps,
                                            notes: nil
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
                    .foregroundColor(.blue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Add custom set
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(textColor)
                    }
                }
            }
        }
        .onAppear {
            viewModel.selectedDay = day
        }
    }
}

struct ExerciseCommitCard: View {
    let exercise: String
    let lastWeight: String?
    let onCommit: (String, Int) -> Void
    
    @State private var weight: String = "50"  // Default weight
    @State private var reps: Int = 8          // Default reps
    @State private var currentSet: Int = 1
    private let totalSets: Int = 3            // Default sets
    
    private let backgroundColor = Color(hex: "161B22")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exercise)
                .font(.headline)
                .foregroundColor(.white)
                .lineLimit(2)
            
            HStack(spacing: 16) {
                // Weight Input
                VStack(alignment: .leading) {
                    TextField("Weight", text: $weight)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .frame(width: 80)
                }
                
                // Reps Stepper
                VStack(alignment: .leading) {
                    Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                        .foregroundColor(textColor)
                }
                
                Spacer()
                
                // Commit Button
                Button(action: {
                    onCommit(weight, reps)
                    if currentSet < totalSets {
                        currentSet += 1
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "39D353"))
                        .imageScale(.large)
                }
            }
            
            // Progress and Last Weight
            HStack {
                Text("Set \(currentSet) of \(totalSets)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let lastWeight = lastWeight {
                    Text("Last: \(lastWeight)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(backgroundColor)
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