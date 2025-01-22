import SwiftUI

struct WeeklyView: View {
    @StateObject private var viewModel = WorkoutViewModel()
    @State private var selectedDay: String?
    @State private var showingDayDetail = false
    @State private var showingActivityGraph = false
    
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
            VStack(spacing: 0) {
                // Date Header
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
                }
                .padding()
                .background(secondaryColor)
                
                ScrollView {
                    VStack(spacing: 0) {
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
                        
                        // Activity Graph
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Activity")
                                .font(.title2)
                                .foregroundColor(textColor)
                                .padding(.horizontal)
                            
                            ActivityGraph(commits: viewModel.commitsByDate)
                            
                            // Legend
                            HStack(spacing: 12) {
                                ForEach(["0", "1-3", "4-5", "6-8", "9+"], id: \.self) { range in
                                    HStack(spacing: 4) {
                                        ActivitySquare(commits: range == "0" ? 0 : 
                                                     range == "1-3" ? 1 :
                                                     range == "4-5" ? 4 :
                                                     range == "6-8" ? 6 : 9)
                                        Text(range)
                                            .font(.caption)
                                            .foregroundColor(textColor)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
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
                        showingActivityGraph = true
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