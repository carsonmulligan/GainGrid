import Foundation

class WorkoutViewModel: ObservableObject {
    private let dataService = LocalDataService()
    
    @Published var workoutPlan: [String: (warmUp: String, workouts: [String], cardio: String)] = [:]
    @Published var currentSets: [WorkoutSet] = []
    @Published var commitsByDate: [Date: Int] = [:]
    @Published var selectedDay: String? {
        didSet {
            // Clear current sets when changing days
            if oldValue != selectedDay {
                currentSets.removeAll()
            }
        }
    }
    
    private var workoutHistory: [String: [WorkoutHistory]] = [:]
    
    init() {
        loadWorkoutPlan()
        loadCommits()
    }
    
    // MARK: - Workout Plan Management
    private func loadWorkoutPlan() {
        let plan = dataService.loadWorkoutPlan()
        
        // Convert the Any dictionary to our typed tuple format
        for (day, details) in plan {
            workoutPlan[day] = (
                warmUp: details["Warm-Up"] as? String ?? "",
                workouts: details["Workouts"] as? [String] ?? [],
                cardio: details["Cardio"] as? String ?? ""
            )
        }
    }
    
    // MARK: - History Management
    func getLastWorkout(for day: String) -> WorkoutHistory? {
        return dataService.getLastWorkout(for: day)
    }
    
    func getWorkoutHistory(for day: String) -> [WorkoutHistory] {
        return dataService.loadWorkoutHistory(for: day)
    }
    
    func getLastWeight(for exercise: String, day: String) -> String? {
        return dataService.loadWorkoutHistory(for: day)
            .flatMap { $0.sets }
            .first { $0.exerciseName == exercise }?
            .weight
    }
    
    // MARK: - Set Management
    func addSet(exerciseName: String, weight: String, reps: Int, notes: String?) {
        let newSet = WorkoutSet(
            exerciseName: exerciseName,
            notes: notes,
            weight: weight,
            reps: reps,
            date: Date()
        )
        currentSets.append(newSet)
    }
    
    func updateSet(existingSet: WorkoutSet, exerciseName: String, weight: String, reps: Int, notes: String?) {
        if let index = currentSets.firstIndex(where: { $0.id == existingSet.id }) {
            let updatedSet = WorkoutSet(
                id: existingSet.id,
                exerciseName: exerciseName,
                notes: notes,
                weight: weight,
                reps: reps,
                date: existingSet.date
            )
            currentSets[index] = updatedSet
        }
    }
    
    // MARK: - Commit Management
    func commitSession(for day: String) {
        guard !currentSets.isEmpty else { return }
        
        // Save workout history
        dataService.saveWorkoutHistory(day: day, sets: currentSets)
        
        // Create and save commit
        let markdown = dataService.generateMarkdownFromSets(currentSets)
        let commit = LocalCommit(
            message: "Completed \(day) workout",
            timestamp: Date(),
            fileName: "workout_\(Date().timeIntervalSince1970).md",
            content: markdown
        )
        
        dataService.saveCommit(commit)
        currentSets.removeAll()
        loadCommits()
    }
    
    private func loadCommits() {
        let commits = dataService.loadAllCommits()
        let calendar = Calendar.current
        
        commitsByDate = Dictionary(grouping: commits) { commit in
            calendar.startOfDay(for: commit.timestamp)
        }.mapValues { $0.count }
    }
    
    func getTodaysProgress(for day: String) -> DayProgress {
        let hasWorkout = !currentSets.isEmpty && selectedDay == day
        
        if hasWorkout {
            let totalSets = currentSets.count
            let totalWeight = currentSets.reduce(0) { total, set in
                total + (Int(set.weight.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0)
            }
            return DayProgress(isComplete: false, completedSets: totalSets, totalWeight: totalWeight)
        } else {
            return DayProgress(isComplete: false, completedSets: nil, totalWeight: nil)
        }
    }
} 