import SwiftUI

struct DayCard: View {
    let day: String
    let isSelected: Bool
    let workoutPlan: WorkoutPlanSettings.DayPlan
    let progress: DayProgress
    
    private let backgroundColor = Color(.systemBackground)
    private let selectedColor = Color(.systemGray6)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Day header
            Text(day.uppercased())
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            if progress.isComplete {
                ForEach(workoutPlan.workouts, id: \.self) { workout in
                    Text(workout)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .strikethrough()
                }
            }
            
            // Optional: Show current date and weather if it's today
            if Calendar.current.isDateInToday(Date()) {
                Text("\(Date().formatted(.dateTime.month().day().year())) - \(Date().formatted(.dateTime.hour().minute())) - 64°")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? selectedColor : backgroundColor)
    }
} 