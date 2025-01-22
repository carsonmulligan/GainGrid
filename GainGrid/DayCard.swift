import SwiftUI

struct DayCard: View {
    let day: String
    let isSelected: Bool
    let workoutPlan: WorkoutPlanSettings.DayPlan
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
            
            if !workoutPlan.warmUp.isEmpty {
                Text("Warm-up: \(workoutPlan.warmUp)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ForEach(workoutPlan.workouts, id: \.self) { workout in
                Text("• \(workout)")
                    .font(.subheadline)
            }
            
            if !workoutPlan.cardio.isEmpty {
                Text("Cardio: \(workoutPlan.cardio)")
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