import Foundation

class LocalDataService {
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Workout Plan Management
    func loadWorkoutPlan() -> [String: WorkoutPlanSettings.DayPlan] {
        let planURL = documentsPath.appendingPathComponent("workout_plan.json")
        if let data = try? Data(contentsOf: planURL),
           let plan = try? JSONDecoder().decode(WorkoutPlanSettings.self, from: data) {
            return plan.days
        }
        return defaultWorkoutPlan()
    }
    
    func saveWorkoutPlan(_ plan: WorkoutPlanSettings) {
        let planURL = documentsPath.appendingPathComponent("workout_plan.json")
        if let data = try? JSONEncoder().encode(plan) {
            try? data.write(to: planURL)
        }
    }
    
    // MARK: - Workout History Management
    func loadWorkoutHistory() -> [String: [WorkoutHistory]] {
        let historyURL = documentsPath.appendingPathComponent("workout_history.json")
        if let data = try? Data(contentsOf: historyURL),
           let history = try? JSONDecoder().decode([String: [WorkoutHistory]].self, from: data) {
            return history
        }
        return [:]
    }
    
    func saveWorkoutHistory(_ history: [String: [WorkoutHistory]]) {
        let historyURL = documentsPath.appendingPathComponent("workout_history.json")
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: historyURL)
        }
    }
    
    // MARK: - Commits Management
    func loadCommits() -> [Date: Int] {
        let commitsURL = documentsPath.appendingPathComponent("commits.json")
        if let data = try? Data(contentsOf: commitsURL),
           let commits = try? JSONDecoder().decode([String: Int].self, from: data) {
            // Convert string dates back to Date objects
            return commits.reduce(into: [:]) { result, pair in
                if let date = ISO8601DateFormatter().date(from: pair.key) {
                    result[date] = pair.value
                }
            }
        }
        return [:]
    }
    
    func saveCommits(_ commits: [Date: Int]) {
        let commitsURL = documentsPath.appendingPathComponent("commits.json")
        // Convert dates to ISO8601 strings for JSON storage
        let stringDates = commits.reduce(into: [:]) { result, pair in
            result[ISO8601DateFormatter().string(from: pair.key)] = pair.value
        }
        if let data = try? JSONEncoder().encode(stringDates) {
            try? data.write(to: commitsURL)
        }
    }
    
    // MARK: - Markdown Generation
    func generateMarkdownFromSets(_ sets: [WorkoutSet]) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        var markdown = "# Workout Session - \(dateFormatter.string(from: Date()))\n\n"
        
        // Group sets by exercise
        let groupedSets = Dictionary(grouping: sets) { $0.exerciseName }
        
        for (exercise, sets) in groupedSets {
            markdown += "## \(exercise)\n\n"
            
            for set in sets {
                markdown += "- Weight: \(set.weight), Reps: \(set.reps)"
                if let notes = set.notes, !notes.isEmpty {
                    markdown += " (Notes: \(notes))"
                }
                markdown += "\n"
            }
            markdown += "\n"
        }
        
        return markdown
    }
    
    // MARK: - Default Data
    private func defaultWorkoutPlan() -> [String: WorkoutPlanSettings.DayPlan] {
        [
            "Monday (Chest)": .init(
                warmUp: "Chest Press Machine (Light) - 2 sets of 12-15 reps",
                workouts: [
                    "Chest Press Machine: 5 sets of 4-6 reps (heavy)",
                    "Incline Chest Press Machine: 4 sets of 6-8 reps",
                    "Pec Deck (Chest Fly Machine): 4 sets of 10-12 reps",
                    "Decline Chest Press Machine: 4 sets of 6-8 reps",
                    "Cable Crossovers (High to Low): 4 sets of 10-12 reps"
                ],
                cardio: "15-20 minutes moderate intensity"
            ),
            "Tuesday (Shoulders)": .init(
                warmUp: "Lateral Raises (Light) - 2 sets of 12-15 reps",
                workouts: [
                    "Shoulder Press Machine: 5 sets of 4-6 reps (heavy)",
                    "Lateral Raise Machine: 4 sets of 8-10 reps",
                    "Front Raise Machine: 4 sets of 8-10 reps",
                    "Reverse Fly Machine: 4 sets of 10-12 reps"
                ],
                cardio: "15-20 minutes moderate intensity"
            ),
            "Wednesday (Legs)": .init(
                warmUp: "Bodyweight Squats - 2 sets of 15-20 reps",
                workouts: [
                    "Leg Press: 5 sets of 4-6 reps (heavy)",
                    "Leg Extension Machine: 4 sets of 8-10 reps",
                    "Leg Curl Machine: 4 sets of 8-10 reps",
                    "Calf Raise Machine: 4 sets of 12-15 reps"
                ],
                cardio: "15-20 minutes moderate intensity"
            ),
            "Thursday (Back)": .init(
                warmUp: "Lat Pulldown (Light) - 2 sets of 12-15 reps",
                workouts: [
                    "Lat Pulldown Machine: 5 sets of 4-6 reps (heavy)",
                    "Seated Row Machine: 4 sets of 6-8 reps",
                    "T-Bar Row Machine: 4 sets of 8-10 reps",
                    "Back Extension Machine: 4 sets of 10-12 reps"
                ],
                cardio: "15-20 minutes moderate intensity"
            ),
            "Friday (Biceps & Triceps)": .init(
                warmUp: "Tricep Pushdowns (Light) - 2 sets of 12-15 reps",
                workouts: [
                    "Preacher Curl Machine (Biceps): 4 sets of 8-10 reps",
                    "Hammer Curl Machine (Biceps): 4 sets of 10-12 reps",
                    "Cable Concentration Curls: 4 sets of 12-15 reps",
                    "Tricep Pushdown (Cable): 4 sets of 8-10 reps",
                    "Overhead Tricep Extension Machine: 4 sets of 10-12 reps"
                ],
                cardio: "15-20 minutes moderate intensity"
            ),
            "Saturday (Rest/Run)": .init(
                warmUp: "Light stretching",
                workouts: ["Optional: 5k run or light cardio"],
                cardio: "30 minutes of preferred cardio"
            ),
            "Sunday (Rest)": .init(
                warmUp: "Rest day",
                workouts: ["Active recovery or complete rest"],
                cardio: ""
            )
        ]
    }
} 