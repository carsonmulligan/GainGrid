import SwiftUI

struct WeeklyView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var selectedDay: String?
    @State private var showingDayDetail = false
    
    private let backgroundColor = Color(hex: "0D1117")
    private let textColor = Color(hex: "C9D1D9")
    private let secondaryColor = Color(hex: "161B22")
    
    private let days = [
        "Monday (Chest)",
        "Tuesday (Shoulders)",
        "Wednesday (Legs)",
        "Thursday (Back)",
        "Friday (Biceps & Triceps)"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Date and Weather Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(Date().formatted(.dateTime.month().day().year()))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(Date().formatted(.dateTime.hour().minute()))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("64°")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(secondaryColor)
                    
                    // Days of the Week
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            day: day,
                            isSelected: selectedDay == day,
                            workoutPlan: viewModel.workoutPlan[day],
                            todaysProgress: viewModel.getTodaysProgress(for: day),
                            backgroundColor: backgroundColor
                        ) {
                            selectedDay = day
                            showingDayDetail = true
                        }
                        Divider()
                            .background(Color(hex: "30363D"))
                    }
                }
            }
            .background(backgroundColor)
            .sheet(isPresented: $showingDayDetail) {
                if let selectedDay = selectedDay {
                    DayDetailView(
                        viewModel: viewModel,
                        day: selectedDay
                    )
                }
            }
            .navigationTitle("GainGrid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Show activity graph
                    }) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(textColor)
                    }
                }
            }
        }
    }
}

struct DayCell: View {
    let day: String
    let isSelected: Bool
    let workoutPlan: (warmUp: String, workouts: [String], cardio: String)?
    let todaysProgress: DayProgress
    let backgroundColor: Color
    let onTap: () -> Void
    
    private var dayAbbreviation: String {
        String(day.prefix(3))
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(day)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if let progress = todaysProgress.completedSets {
                            Text("\(progress) sets completed")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    if todaysProgress.isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "39D353"))
                    }
                }
                
                if let totalWeight = todaysProgress.totalWeight {
                    HStack {
                        Text("Total Weight: \(totalWeight) lbs")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "161B22") : backgroundColor)
            .contentShape(Rectangle())
        }
    }
}

struct DayProgress {
    let isComplete: Bool
    let completedSets: Int?
    let totalWeight: Int?
}

extension WorkoutViewModel {
    var selectedDay: String? {
        didSet {
            // Clear current sets when changing days
            if oldValue != selectedDay {
                currentSets.removeAll()
            }
        }
    }
    
    func getTodaysProgress(for day: String) -> DayProgress {
        let hasWorkout = !currentSets.isEmpty && selectedDay == day
        
        if hasWorkout {
            let totalSets = currentSets.count
            let totalWeight = currentSets.reduce(0) { total, set in
                total + (Int(set.weight.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0)
            }
            return DayProgress(isComplete: false, completedSets: totalSets, totalWeight: totalWeight)
        } else {
            return DayProgress(isComplete: false, completedSets: nil, totalWeight: nil)
        }
    }
}

struct DayDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: WorkoutViewModel
    let day: String
    
    @State private var showingAddSetSheet = false
    @State private var selectedSet: WorkoutSet?
    @State private var selectedExercise: String?
    
    private let backgroundColor = Color(hex: "0D1117")
    private let textColor = Color(hex: "C9D1D9")
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Workout Plan
                    if let plan = viewModel.workoutPlan[day] {
                        WorkoutDayView(
                            dayName: day,
                            warmUp: plan.warmUp,
                            workouts: plan.workouts,
                            cardio: plan.cardio,
                            onWorkoutTap: { exercise in
                                selectedExercise = exercise
                                selectedSet = nil
                                showingAddSetSheet = true
                            }
                        )
                    }
                    
                    // Current Sets
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Today's Sets")
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
                                presentationMode.wrappedValue.dismiss()
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
            }
            .background(backgroundColor)
            .sheet(isPresented: $showingAddSetSheet) {
                AddSetView(viewModel: viewModel, existingSet: selectedSet, prefilledExercise: selectedExercise)
            }
            .navigationTitle(day)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .onAppear {
            viewModel.selectedDay = day
        }
    }
} 