import SwiftUI

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