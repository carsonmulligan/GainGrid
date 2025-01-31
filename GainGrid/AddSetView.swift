import SwiftUI

struct AddSetView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    let exerciseName: String
    let day: String
    let setInfo: String
    let existingSet: WorkoutSet?
    
    @State private var weight: String = ""
    @State private var reps: Int = 8
    @State private var notes: String = ""
    @State private var selectedUnit: WeightUnit = .lbs
    @State private var showingHistory = false
    
    init(exerciseName: String, day: String, existingSet: WorkoutSet? = nil) {
        self.exerciseName = exerciseName
        self.day = day
        self.existingSet = existingSet
        
        // Create set info string based on exercise name
        var info = ""
        if let range = exerciseName.range(of: "\\d+(?:-\\d+)? (?:reps|sets)", options: .regularExpression) {
            info = String(exerciseName[range])
        }
        self.setInfo = info
        
        // Initialize state properties if editing existing set
        if let set = existingSet {
            _weight = State(initialValue: set.weight)
            _reps = State(initialValue: set.reps)
            _notes = State(initialValue: set.notes ?? "")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exerciseName)
                .font(.headline)
            
            Text(setInfo)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading) {
                    Text("Weight")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                        
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.rawValue).tag(unit)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 100)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Reps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button(action: { if reps > 1 { reps -= 1 } }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        
                        Text("\(reps)")
                            .frame(width: 40, alignment: .center)
                        
                        Button(action: { reps += 1 }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            // Quick Weight Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach([5, 10, 25, 45, 90], id: \.self) { quickWeight in
                        Button(action: {
                            weight = "\(quickWeight)"
                        }) {
                            Text("\(quickWeight)")
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            TextField("Notes (optional)", text: $notes)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Button(action: { showingHistory.toggle() }) {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("History")
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Button(action: {
                    saveSet()
                    dismiss()
                }) {
                    Text("Save Set")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .sheet(isPresented: $showingHistory) {
            ExerciseHistoryView(exerciseName: exerciseName)
        }
    }
    
    private func saveSet() {
        let weightString = "\(weight) \(selectedUnit.rawValue)"
        let set = WorkoutSet(
            exerciseName: exerciseName,
            notes: notes.isEmpty ? nil : notes,
            weight: weightString,
            reps: reps,
            date: Date()
        )
        viewModel.addSet(set)
    }
}

struct ExerciseHistoryView: View {
    let exerciseName: String
    @EnvironmentObject var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.getExerciseHistory(for: exerciseName)) { history in
                    VStack(alignment: .leading) {
                        Text(history.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ForEach(history.sets) { set in
                            Text("\(set.weight) × \(set.reps) reps")
                                .font(.body)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("\(exerciseName) History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum WeightUnit: String, CaseIterable {
    case lbs = "lbs"
    case kg = "kg"
} 