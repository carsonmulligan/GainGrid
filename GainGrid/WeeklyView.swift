import SwiftUI

struct WeeklyView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var selectedDay: String?
    @State private var showingDayDetail = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(viewModel.workoutPlan.keys.sorted(), id: \.self) { day in
                            DayCard(
                                day: day,
                                isSelected: day == selectedDay,
                                workoutPlan: (
                                    warmUp: "",
                                    workouts: viewModel.workoutPlan[day] ?? [],
                                    cardio: ""
                                ),
                                progress: DayProgress(completedSets: nil)
                            )
                            .onTapGesture {
                                selectedDay = day
                                showingDayDetail = true
                            }
                        }
                    }
                    .padding()
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

@retroactive extension String: Identifiable {
    public var id: String { self }
}

#Preview {
    WeeklyView()
        .environmentObject(WorkoutViewModel())
} 