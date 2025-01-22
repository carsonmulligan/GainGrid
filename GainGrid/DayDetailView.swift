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

#Preview {
    DayDetailView(day: "Monday")
        .environmentObject(WorkoutViewModel())
}