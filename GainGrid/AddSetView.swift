import SwiftUI

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