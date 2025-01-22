import SwiftUI

struct WeeklyView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var selectedDay: String?
    
    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Activity Graph
                    ActivityGraph(commitsByDate: viewModel.commitsByDate)
                        .frame(height: 100)
                        .padding()
                    
                    // Weekly Schedule
                    ForEach(days, id: \.self) { day in
                        DayCard(
                            day: day,
                            isSelected: selectedDay == day,
                            workoutPlan: viewModel.workoutPlan[day],
                            progress: viewModel.getTodaysProgress(for: day)
                        )
                        .onTapGesture {
                            selectedDay = day
                            viewModel.selectedDay = day
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Workout Plan")
            .sheet(item: $selectedDay) { day in
                DayDetailView(day: day)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct DayCard: View {
    let day: String
    let isSelected: Bool
    let workoutPlan: (warmUp: String, workouts: [String], cardio: String)?
    let progress: DayProgress
    
    private let backgroundColor = Color(.systemBackground)
    private let selectedColor = Color.blue.opacity(0.1)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day)
                    .font(.headline)
                Spacer()
                if let completedSets = progress.completedSets {
                    Text("\(completedSets) sets")
                        .foregroundColor(.secondary)
                }
            }
            
            if let plan = workoutPlan {
                if !plan.warmUp.isEmpty {
                    Text("Warm-up: \(plan.warmUp)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ForEach(plan.workouts, id: \.self) { workout in
                    Text("• \(workout)")
                        .font(.subheadline)
                }
                
                if !plan.cardio.isEmpty {
                    Text("Cardio: \(plan.cardio)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Rest Day")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? selectedColor : backgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct DayDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: WorkoutViewModel
    let day: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if let plan = viewModel.workoutPlan[day] {
                        // Warm-up Section
                        if !plan.warmUp.isEmpty {
                            Text("Warm-up")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Text(plan.warmUp)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                        }
                        
                        // Workouts Section
                        Text("Workouts")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(plan.workouts, id: \.self) { exercise in
                            ExerciseCommitCard(exerciseName: exercise, day: day)
                        }
                        
                        // Cardio Section
                        if !plan.cardio.isEmpty {
                            Text("Cardio")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            
                            Text(plan.cardio)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
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

struct ActivityGraph: View {
    let commitsByDate: [Date: Int]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activity")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(last90Days(), id: \.self) { date in
                    let count = commitsByDate[date] ?? 0
                    Rectangle()
                        .fill(colorForCount(count))
                        .frame(width: 10, height: heightForCount(count))
                }
            }
        }
    }
    
    private func last90Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<90).map { days in
            calendar.date(byAdding: .day, value: -days, to: today)!
        }.reversed()
    }
    
    private func colorForCount(_ count: Int) -> Color {
        switch count {
        case 0: return Color(.systemGray6)
        case 1: return .blue.opacity(0.3)
        case 2: return .blue.opacity(0.6)
        default: return .blue
        }
    }
    
    private func heightForCount(_ count: Int) -> CGFloat {
        switch count {
        case 0: return 10
        case 1: return 20
        case 2: return 30
        default: return 40
        }
    }
}

extension String: Identifiable {
    public var id: String { self }
} 