import SwiftUI

struct ActivitySquare: View {
    let commits: Int
    
    private var color: Color {
        switch commits {
        case 0: return Color(hex: "0D1117")
        case 1...3: return Color(hex: "0E4429")
        case 4...5: return Color(hex: "006D32")
        case 6...8: return Color(hex: "26A641")
        default: return Color(hex: "39D353")
        }
    }
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .cornerRadius(2)
    }
}

struct ActivityGraph: View {
    let commits: [Date: Int]
    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 4), count: 7)
    private let calendar = Calendar.current
    
    private var daysToShow: [(date: Date, commits: Int)] {
        let today = Date()
        let days = (0..<365).compactMap { daysAgo -> (Date, Int)? in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            return (date, commits[date, default: 0])
        }
        return days.reversed()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: columns, spacing: 4) {
                ForEach(daysToShow, id: \.date) { day in
                    ActivitySquare(commits: day.commits)
                }
            }
            .padding()
        }
    }
}

struct WorkoutDayView: View {
    let dayName: String
    let warmUp: String
    let workouts: [String]
    let cardio: String
    let onWorkoutTap: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dayName)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "C9D1D9"))
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Warm-Up")
                    .font(.headline)
                    .foregroundColor(Color(hex: "C9D1D9"))
                Button(action: { onWorkoutTap(warmUp) }) {
                    Text(warmUp)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "58A6FF"))
                }
                
                Text("Workouts")
                    .font(.headline)
                    .foregroundColor(Color(hex: "C9D1D9"))
                    .padding(.top, 4)
                ForEach(workouts, id: \.self) { workout in
                    Button(action: { onWorkoutTap(workout) }) {
                        Text("• \(workout)")
                            .font(.subheadline)
                            .foregroundColor(Color(hex: "58A6FF"))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Text("Cardio")
                    .font(.headline)
                    .foregroundColor(Color(hex: "C9D1D9"))
                    .padding(.top, 4)
                Button(action: { onWorkoutTap(cardio) }) {
                    Text(cardio)
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "58A6FF"))
                }
            }
        }
        .padding()
        .background(Color(hex: "0D1117"))
        .cornerRadius(8)
    }
}

// Helper extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 