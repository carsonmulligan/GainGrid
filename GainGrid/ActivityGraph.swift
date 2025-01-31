import SwiftUI

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