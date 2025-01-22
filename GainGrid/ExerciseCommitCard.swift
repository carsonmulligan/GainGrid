import SwiftUI

struct ExerciseCommitCard: View {
    let exercise: String
    let lastWeight: String?
    let onCommit: (String, Int) -> Void
    @State private var showingHistory = false
    @State private var showingSetConfig = false
    
    @State private var weight: String = "50"  // Default weight
    @State private var reps: Int = 8          // Default reps
    @State private var currentSet: Int = 1
    @State private var totalSets: Int = 3     // Now mutable
    
    private let backgroundColor = Color(hex: "161B22")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Exercise Header with History Button
            Button(action: { showingHistory = true }) {
                HStack {
                    Text(exercise)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Spacer()
                    
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundColor(Color(hex: "58A6FF"))
                }
            }
            
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
            
            // Progress and Configuration
            HStack {
                Button(action: { showingSetConfig = true }) {
                    Text("Set \(currentSet) of \(totalSets)")
                        .font(.caption)
                        .foregroundColor(Color(hex: "58A6FF"))
                }
                
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
        .sheet(isPresented: $showingHistory) {
            ExerciseHistoryView(exercise: exercise)
        }
        .sheet(isPresented: $showingSetConfig) {
            SetConfigurationView(totalSets: $totalSets, currentSet: $currentSet)
        }
    }
}

struct ExerciseHistoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel = WorkoutViewModel()
    let exercise: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Progress Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Progress")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Weight progression chart would go here
                        Rectangle()
                            .fill(Color(hex: "161B22"))
                            .frame(height: 200)
                            .overlay(
                                Text("Weight Progress Chart")
                                    .foregroundColor(.gray)
                            )
                    }
                    .padding()
                    
                    // History List
                    VStack(alignment: .leading, spacing: 8) {
                        Text("History")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.getExerciseHistory(for: exercise), id: \.date) { entry in
                            ExerciseHistoryCard(entry: entry)
                        }
                    }
                }
            }
            .background(Color(hex: "0D1117"))
            .navigationTitle(exercise)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct ExerciseHistoryCard: View {
    let entry: WorkoutHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.date.formatted(.dateTime.month().day().year()))
                .font(.subheadline)
                .foregroundColor(.white)
            
            ForEach(entry.sets.filter { $0.exerciseName == entry.sets.first?.exerciseName }) { set in
                HStack {
                    Text("\(set.weight) × \(set.reps)")
                        .font(.subheadline)
                    if let notes = set.notes {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "161B22"))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct SetConfigurationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var totalSets: Int
    @Binding var currentSet: Int
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sets Configuration")) {
                    Stepper("Total Sets: \(totalSets)", value: $totalSets, in: 1...10)
                    Stepper("Current Set: \(currentSet)", value: $currentSet, in: 1...totalSets)
                }
                
                Section {
                    Button("Reset Progress") {
                        currentSet = 1
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Configure Sets")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 