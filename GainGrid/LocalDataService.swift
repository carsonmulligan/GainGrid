import Foundation

class LocalDataService {
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
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
        // ... other days would be defined similarly
    ]
} 