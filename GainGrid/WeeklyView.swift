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
                        VStack(spacing: 0) {
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
                            
                            if day != viewModel.workoutPlan.keys.sorted().last {
                                Divider()
                            }
                        }
                    }
                    
                    Text("Activity")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    ActivityGrid(viewModel: viewModel)
                        .padding(.horizontal)
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
}

struct ActivityGrid: View {
    let viewModel: WorkoutViewModel
    let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activity")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(getLastYear(), id: \.self) { date in
                    ActivitySquare(intensity: getIntensity(for: date))
                }
            }
            .padding()
        }
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

struct ActivitySquare: View {
    let intensity: Double // 0.0 to 1.0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.green.opacity(intensity))
            .frame(width: 10, height: 10)
    }
}

extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    WeeklyView()
        .environmentObject(WorkoutViewModel())
} 