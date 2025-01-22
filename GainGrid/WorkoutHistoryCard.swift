import SwiftUI

struct WorkoutHistoryCard: View {
    let workout: WorkoutHistory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(workout.date.formatted(.dateTime.month().day().year()))
                .font(.headline)
            
            ForEach(workout.sets) { set in
                HStack {
                    Text(set.exerciseName)
                        .font(.subheadline)
                    Spacer()
                    Text("\(set.weight) × \(set.reps)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 