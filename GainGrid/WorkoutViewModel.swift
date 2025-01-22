import Foundation

class WorkoutViewModel: ObservableObject {
    private let dataService = LocalDataService()
    
    @Published var workoutPlan: [String: WorkoutPlanSettings.DayPlan] = [:]
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
    private var exerciseHistory: [String: [WorkoutSet]] = [:]
    
    init() {
        loadWorkoutPlan()
        loadCommits()
        loadHistory()
    }
    
    // MARK: - Workout Plan Management
    private func loadWorkoutPlan() {
        let plan = dataService.loadWorkoutPlan()
        
        // Convert the Any dictionary to our typed format
        for (day, details) in plan {
            workoutPlan[day] = WorkoutPlanSettings.DayPlan(
                warmUp: details["Warm-Up"] as? String ?? "",
                workouts: details["Workouts"] as? [String] ?? [],
                cardio: details["Cardio"] as? String ?? ""
            )
        }
    }
    
    // MARK: - History Management
    private func loadHistory() {
        // Load history for each day
        for day in workoutPlan.keys {
            workoutHistory[day] = dataService.loadWorkoutHistory(for: day)
            
            // Build exercise history
            for workout in workoutHistory[day] ?? [] {
                for set in workout.sets {
                    if exerciseHistory[set.exerciseName] == nil {
                        exerciseHistory[set.exerciseName] = []
                    }
                    exerciseHistory[set.exerciseName]?.append(set)
                }
            }
        }
    }
    
    func getLastWorkout(for day: String) -> WorkoutHistory? {
        return workoutHistory[day]?.last
    }
    
    func getWorkoutHistory(for day: String) -> [WorkoutHistory] {
        return workoutHistory[day] ?? []
    }
    
    func getExerciseHistory(for exercise: String) -> [WorkoutHistory] {
        // Group sets by date to create WorkoutHistory objects
        let sets = exerciseHistory[exercise] ?? []
        let groupedSets = Dictionary(grouping: sets) { set in
            Calendar.current.startOfDay(for: set.date)
        }
        
        return groupedSets.map { date, sets in
            WorkoutHistory(date: date, sets: sets.sorted { $0.date < $1.date })
        }.sorted { $0.date > $1.date }
    }
    
    func getLastWeight(for exercise: String, day: String) -> String? {
        return exerciseHistory[exercise]?.last?.weight
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
        
        // Update exercise history immediately
        if exerciseHistory[exerciseName] == nil {
            exerciseHistory[exerciseName] = []
        }
        exerciseHistory[exerciseName]?.append(newSet)
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
            
            // Update exercise history
            if let historyIndex = exerciseHistory[exerciseName]?.firstIndex(where: { $0.id == existingSet.id }) {
                exerciseHistory[exerciseName]?[historyIndex] = updatedSet
            }
        }
    }
    
    // MARK: - Commit Management
    func commitSession(for day: String) {
        guard !currentSets.isEmpty else { return }
        
        // Save workout history
        dataService.saveWorkoutHistory(day: day, sets: currentSets)
        
        // Update local history
        if workoutHistory[day] == nil {
            workoutHistory[day] = []
        }
        let workout = WorkoutHistory(date: Date(), sets: currentSets)
        workoutHistory[day]?.append(workout)
        
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