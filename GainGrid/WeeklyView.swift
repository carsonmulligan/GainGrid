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
        "Friday (Biceps & Triceps)",
        "Saturday (Rest/Run)",
        "Sunday (Rest)"
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
                            viewModel.selectedDay = day
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