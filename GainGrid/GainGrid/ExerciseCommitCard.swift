struct ExerciseHistoryView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let exerciseName: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.getExerciseHistory(for: exerciseName)) { history in
                    Section(header: Text(history.date.formatted(date: .abbreviated, time: .omitted))) {
                        ForEach(history.sets) { set in
                            HistorySetRow(set: set)
                        }
                    }
                }
            }
            .navigationTitle("\(exerciseName) History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HistorySetRow: View {
    let set: WorkoutSet
    
    var body: some View {
        HStack {
            Text("\(set.weight)lbs")
                .bold()
            Text("×")
            Text("\(set.reps) reps")
            if let notes = set.notes {
                Spacer()
                Text(notes)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
} 