import SwiftUI

struct DayDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: WorkoutViewModel
    let day: String
    
    private let backgroundColor = Color(.systemBackground)
    private let textColor = Color(.label)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let exercises = viewModel.workoutPlan[day] {
                        ForEach(exercises, id: \.self) { exercise in
                            ExerciseCommitCard(exerciseName: exercise, day: day)
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
            .navigationBarItems(trailing: Button("Done") { dismiss() })
        }
    }
}

struct ExerciseCommitCard: View {
    let exerciseName: String
    let day: String
    
    @State private var weight: String = "50"  // Default weight
    @State private var reps: Int = 8          // Default reps
    @State private var currentSet: Int = 1
    private let totalSets: Int = 3            // Default sets
    
    private let backgroundColor = Color(hex: "161B22")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(exerciseName)
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
                    viewModel.addSet(
                        exerciseName: exerciseName,
                        weight: weight,
                        reps: reps,
                        notes: nil
                    )
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
                
                if let lastWeight = viewModel.getLastWeight(for: exerciseName, day: day) {
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