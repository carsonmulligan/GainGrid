import Foundation

class LocalDataService {
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    // MARK: - Workout Plan Management
    func saveWorkoutPlan(_ plan: [String: [String: Any]]) {
        let planURL = documentsPath.appendingPathComponent("workout_plan.json")
        do {
            let data = try JSONSerialization.data(withJSONObject: plan, options: .prettyPrinted)
            try data.write(to: planURL)
        } catch {
            print("Error saving workout plan: \(error)")
        }
    }
    
    func loadWorkoutPlan() -> [String: [String: Any]] {
        let planURL = documentsPath.appendingPathComponent("workout_plan.json")
        if let data = try? Data(contentsOf: planURL),
           let plan = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
            return plan
        }
        return Self.defaultWorkoutPlan
    }
    
    // MARK: - Workout History Management
    func saveWorkoutHistory(day: String, sets: [WorkoutSet]) {
        let historyURL = documentsPath.appendingPathComponent("history")
        let dayURL = historyURL.appendingPathComponent("\(day).json")
        
        do {
            try fileManager.createDirectory(at: historyURL, withIntermediateDirectories: true)
            
            // Load existing history
            var history = loadWorkoutHistory(for: day)
            
            // Add new workout
            let workout = WorkoutHistory(date: Date(), sets: sets)
            history.append(workout)
            
            // Save updated history
            let data = try JSONEncoder().encode(history)
            try data.write(to: dayURL)
        } catch {
            print("Error saving workout history: \(error)")
        }
    }
    
    func loadWorkoutHistory(for day: String) -> [WorkoutHistory] {
        let historyURL = documentsPath.appendingPathComponent("history")
        let dayURL = historyURL.appendingPathComponent("\(day).json")
        
        do {
            let data = try Data(contentsOf: dayURL)
            return try JSONDecoder().decode([WorkoutHistory].self, from: data)
        } catch {
            return []
        }
    }
    
    func getLastWorkout(for day: String) -> WorkoutHistory? {
        return loadWorkoutHistory(for: day).last
    }
    
    // MARK: - Commits Management
    func loadAllCommits() -> [LocalCommit] {
        let commitsURL = documentsPath.appendingPathComponent("commits")
        
        do {
            try fileManager.createDirectory(at: commitsURL, withIntermediateDirectories: true)
            let fileURLs = try fileManager.contentsOfDirectory(at: commitsURL, includingPropertiesForKeys: nil)
            
            return try fileURLs.compactMap { url in
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(LocalCommit.self, from: data)
            }
        } catch {
            print("Error loading commits: \(error)")
            return []
        }
    }
    
    func saveCommit(_ localCommit: LocalCommit) {
        let commitsURL = documentsPath.appendingPathComponent("commits")
        let fileURL = commitsURL.appendingPathComponent("\(localCommit.id).json")
        
        do {
            try fileManager.createDirectory(at: commitsURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(localCommit)
            try data.write(to: fileURL)
        } catch {
            print("Error saving commit: \(error)")
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
    
    // MARK: - Default Workout Plan
    static let defaultWorkoutPlan: [String: [String: Any]] = [
        "Monday (Chest)": [
            "Warm-Up": "Chest Press Machine (Light) - 2 sets of 12-15 reps",
            "Workouts": [
                "Chest Press Machine: 5 sets of 4-6 reps (heavy)",
                "Incline Chest Press Machine: 4 sets of 6-8 reps",
                "Pec Deck (Chest Fly Machine): 4 sets of 10-12 reps",
                "Decline Chest Press Machine: 4 sets of 6-8 reps",
                "Cable Crossovers (High to Low): 4 sets of 10-12 reps",
                "Push-Ups (Weighted, Optional): 3 sets to failure"
            ],
            "Cardio": "15 minutes incline treadmill walk"
        ],
        "Tuesday (Shoulders)": [
            "Warm-Up": "Overhead Press Machine (Light) - 2 sets of 12-15 reps",
            "Workouts": [
                "Overhead Shoulder Press Machine: 5 sets of 4-6 reps (heavy)",
                "Lateral Raise Machine: 4 sets of 12-15 reps",
                "Front Raises (Cable): 4 sets of 12-15 reps",
                "Reverse Pec Deck (Rear Delts): 4 sets of 12-15 reps",
                "Cable Upright Row: 4 sets of 8-10 reps",
                "Smith Machine Shrugs: 4 sets of 8-10 reps"
            ],
            "Cardio": "15 minutes elliptical machine"
        ],
        "Wednesday (Legs)": [
            "Warm-Up": "Leg Press (Light) - 2 sets of 12-15 reps",
            "Workouts": [
                "Leg Press Machine: 5 sets of 4-6 reps (heavy)",
                "Leg Curl Machine (Hamstrings): 4 sets of 8-10 reps",
                "Leg Extension Machine (Quads): 4 sets of 8-10 reps",
                "Glute Kickback Machine: 4 sets of 10-12 reps",
                "Standing Calf Raise Machine: 4 sets of 12-15 reps",
                "Seated Calf Raise Machine: 4 sets of 12-15 reps"
            ],
            "Cardio": "15 minutes stair climber"
        ],
        "Thursday (Back)": [
            "Warm-Up": "Lat Pulldown (Light) - 2 sets of 12-15 reps",
            "Workouts": [
                "Lat Pulldown Machine: 5 sets of 4-6 reps (heavy)",
                "Seated Row Machine: 4 sets of 6-8 reps",
                "Assisted Pull-Ups (Weight Stack): 4 sets of 8-10 reps",
                "Single-Arm Row (Cable): 4 sets of 8-10 reps per arm",
                "Face Pulls (Cable, Upper Back): 4 sets of 12-15 reps",
                "Reverse Pec Deck (Rear Delts): 4 sets of 12-15 reps"
            ],
            "Cardio": "15 minutes rowing machine"
        ],
        "Friday (Biceps & Triceps)": [
            "Warm-Up": "Tricep Pushdowns (Light) - 2 sets of 12-15 reps",
            "Workouts": [
                "Preacher Curl Machine (Biceps): 4 sets of 8-10 reps",
                "Hammer Curl Machine (Biceps): 4 sets of 10-12 reps",
                "Cable Concentration Curls: 4 sets of 12-15 reps",
                "Tricep Pushdown (Cable): 4 sets of 8-10 reps",
                "Overhead Tricep Extension (Cable): 4 sets of 10-12 reps",
                "Dips (Machine-Assisted, Optional): 4 sets of 6-8 reps"
            ],
            "Cardio": "15 minutes jump rope or light treadmill run"
        ],
        "Saturday (Rest/Run)": [
            "Warm-Up": "Light stretching",
            "Workouts": ["Optional: 5k run or light cardio"],
            "Cardio": "30 minutes of preferred cardio"
        ],
        "Sunday (Rest)": [
            "Warm-Up": "Light stretching",
            "Workouts": ["Active recovery or rest"],
            "Cardio": "Optional: Light walking"
        ]
    ]
} 