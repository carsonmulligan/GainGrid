import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    @State private var showingDayDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.workoutPlan.keys.sorted(), id: \.self) { day in
                        DayCard(
                            day: day,
                            isSelected: day == selectedDay,
                            workoutPlan: viewModel.workoutPlan[day] ?? WorkoutPlanSettings.DayPlan(warmUp: "", workouts: [], cardio: ""),
                            progress: viewModel.getTodaysProgress(for: day)
                        )
                        .onTapGesture {
                            selectedDay = day
                            showingDayDetail = true
                        }
                        .background(getBackgroundColor(for: day))
                    }
                }
            }
            .navigationTitle("Weekly Plan")
            .sheet(isPresented: $showingDayDetail) {
                if let day = selectedDay {
                    DayDetailView(day: day)
                }
            }
        }
    }
    
    private func getBackgroundColor(for day: String) -> Color {
        let index = viewModel.workoutPlan.keys.sorted().firstIndex(of: day) ?? 0
        return index % 2 == 0 ? Color(.systemBackground) : Color(.systemGray6)
    }
}

struct DayCard: View {
    let day: String
    let isSelected: Bool
    let workoutPlan: WorkoutPlanSettings.DayPlan
    let progress: DayProgress
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(day)
                    .font(.title2)
                    .fontWeight(.bold)
                if let focus = getFocusArea() {
                    Text("(\(focus))")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.bottom, 4)
            
            if !workoutPlan.warmUp.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Warm-up:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(workoutPlan.warmUp)
                        .font(.body)
                }
            }
            
            if !workoutPlan.workouts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(workoutPlan.workouts, id: \.self) { workout in
                        Text("• \(workout)")
                            .font(.body)
                    }
                }
            }
            
            if !workoutPlan.cardio.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cardio:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(workoutPlan.cardio)
                        .font(.body)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getFocusArea() -> String? {
        // Extract focus area from workouts (e.g., "Chest", "Biceps & Triceps")
        if workoutPlan.workouts.contains(where: { $0.contains("Chest") }) {
            return "Chest"
        } else if workoutPlan.workouts.contains(where: { $0.contains("Bicep") || $0.contains("Tricep") }) {
            return "Biceps & Triceps"
        } else if workoutPlan.cardio.contains("run") || workoutPlan.cardio.contains("cardio") {
            return "Rest/Run"
        }
        return nil
    }
}

#Preview {
    WeeklyView()
        .environmentObject(WorkoutViewModel())
} 