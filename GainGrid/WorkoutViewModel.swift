import Foundation

class WorkoutViewModel: ObservableObject {
    private let dataService = LocalDataService()
    
    @Published var workoutPlan: [String: WorkoutPlanSettings.DayPlan] = [:]
    @Published var currentSets: [String: [WorkoutSet]] = [:]
    @Published var commitsByDate: [Date: Int] = [:]
    @Published var selectedDay: String? {
        didSet {
            if oldValue != selectedDay {
                currentSets.removeAll()
            }
        }
    }
    
    private var workoutHistory: [String: [WorkoutHistory]] = [:]
    private var exerciseHistory: [String: [WorkoutSet]] = [:]
    
    init() {
        loadWorkoutPlan()
        loadCommits()
        loadHistory()
    }
    
    // MARK: - Set Management
    func addSet(_ set: WorkoutSet) {
        if currentSets[set.exerciseName] == nil {
            currentSets[set.exerciseName] = []
        }
        currentSets[set.exerciseName]?.append(set)
        objectWillChange.send()
    }
    
    func getCurrentSets(for exercise: String, on day: String) -> [WorkoutSet]? {
        return currentSets[exercise]
    }
    
    // MARK: - History Management
    func getExerciseHistory(for exercise: String) -> [WorkoutHistory] {
        return workoutHistory[exercise] ?? []
    }
    
    func getPersonalRecords(for exercise: String) -> [PersonalRecord]? {
        // TODO: Implement personal records tracking
        return nil
    }
    
    func commitSession(for day: String) {
        guard !currentSets.isEmpty else { return }
        
        // Create workout history entries for each exercise
        for (exercise, sets) in currentSets {
            let history = WorkoutHistory(date: Date(), sets: sets)
            if workoutHistory[exercise] == nil {
                workoutHistory[exercise] = []
            }
            workoutHistory[exercise]?.append(history)
        }
        
        // Update commit count for today
        let today = Calendar.current.startOfDay(for: Date())
        commitsByDate[today] = (commitsByDate[today] ?? 0) + 1
        
        // Save everything
        dataService.saveWorkoutHistory(workoutHistory)
        dataService.saveCommits(commitsByDate)
        
        // Clear current session
        currentSets.removeAll()
        objectWillChange.send()
    }
    
    // MARK: - Workout Plan Management
    private func loadWorkoutPlan() {
        workoutPlan = dataService.loadWorkoutPlan()
    }
    
    private func loadCommits() {
        commitsByDate = dataService.loadCommits()
    }
    
    private func loadHistory() {
        workoutHistory = dataService.loadWorkoutHistory()
    }
}

// MARK: - Supporting Types
struct WorkoutPlanSettings {
    struct DayPlan {
        let warmUp: String
        let workouts: [String]
        let cardio: String
    }
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let type: String
    let value: Double
    let date: Date
} 