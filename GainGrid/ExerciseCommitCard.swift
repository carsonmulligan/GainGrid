import SwiftUI

struct ExerciseCommitCard: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let exerciseName: String
    let day: String
    
    @State private var weight: String = "50"
    @State private var reps: Int = 8
    @State private var totalSets: Int = 3
    @State private var currentSet: Int = 1
    @State private var notes: String = ""
    @State private var showingHistory = false
    @State private var showingSetConfig = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exerciseName)
                    .font(.headline)
                Spacer()
                Button(action: { showingHistory.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                }
                Button(action: { showingSetConfig.toggle() }) {
                    Image(systemName: "slider.horizontal.3")
                }
            }
            
            HStack {
                TextField("Weight", text: $weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
                
                Stepper("Reps: \(reps)", value: $reps, in: 1...20)
                    .frame(width: 150)
            }
            
            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Text("Set \(currentSet) of \(totalSets)")
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: commitSet) {
                    Text(currentSet < totalSets ? "Next Set" : "Complete")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showingHistory) {
            ExerciseHistoryView(exerciseName: exerciseName)
        }
        .sheet(isPresented: $showingSetConfig) {
            SetConfigurationView(totalSets: $totalSets, currentSet: $currentSet)
        }
        .onAppear {
            if let lastWeight = viewModel.getLastWeight(for: exerciseName, day: day) {
                weight = lastWeight
            }
        }
    }
    
    private func commitSet() {
        viewModel.addSet(
            exerciseName: exerciseName,
            weight: weight,
            reps: reps,
            notes: notes.isEmpty ? nil : notes
        )
        
        if currentSet < totalSets {
            currentSet += 1
            notes = ""  // Clear notes for next set
        } else {
            // Reset for next exercise
            currentSet = 1
            notes = ""
        }
    }
}

struct ExerciseHistoryView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    let exerciseName: String
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.getExerciseHistory(for: exerciseName)) { history in
                    Section(header: Text(history.date.formatted(date: .abbreviated, time: .omitted))) {
                        ForEach(history.sets) { set in
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
                }
            }
            .navigationTitle("\(exerciseName) History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SetConfigurationView: View {
    @Binding var totalSets: Int
    @Binding var currentSet: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Set Configuration")) {
                    Stepper("Total Sets: \(totalSets)", value: $totalSets, in: 1...10)
                    if currentSet > totalSets {
                        Text("Current set will be adjusted to match total sets")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Configure Sets")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                if currentSet > totalSets {
                    currentSet = totalSets
                }
                dismiss()
            })
        }
    }
} 