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
                            DayCard(day: day, exercises: viewModel.workoutPlan[day] ?? [])
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

struct DayCard: View {
    let day: String
    let exercises: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(day)
                    .font(.headline)
                Spacer()
            }
            
            ForEach(exercises, id: \.self) { exercise in
                Text("• \(exercise)")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
} 