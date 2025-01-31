import SwiftUI

struct ActivityGraph: View {
    let viewModel: WorkoutViewModel
    let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity")
                .font(.headline)
                .padding(.horizontal)
            
            if viewModel.commitsByDate.isEmpty {
                EmptyStateView()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    ForEach(getLastYear(), id: \.self) { date in
                        ActivitySquare(intensity: getIntensity(for: date))
                    }
                }
            }
        }
        .padding()
    }
    
    private func getLastYear() -> [Date] {
        let today = Date()
        let yearAgo = calendar.date(byAdding: .year, value: -1, to: today)!
        
        var dates: [Date] = []
        var currentDate = yearAgo
        
        while currentDate <= today {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private func getIntensity(for date: Date) -> Double {
        let commits = viewModel.commitsByDate[calendar.startOfDay(for: date)] ?? 0
        return commits == 0 ? 0 : Double(commits) / 5.0
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Activity Yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Complete your first workout to start seeing your activity pattern here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("💪 Your progress will show up as a heatmap")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
} 