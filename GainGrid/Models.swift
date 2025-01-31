import Foundation

struct DayProgress {
    let isComplete: Bool
    let completedSets: Int?
    let totalWeight: Int?
    
    static let empty = DayProgress(isComplete: false, completedSets: nil, totalWeight: nil)
}

struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    let exerciseName: String
    let notes: String?
    let weight: String
    let reps: Int
    let date: Date
    
    init(id: UUID = UUID(), exerciseName: String, notes: String?, weight: String, reps: Int, date: Date) {
        self.id = id
        self.exerciseName = exerciseName
        self.notes = notes
        self.weight = weight
        self.reps = reps
        self.date = date
    }
}

struct WorkoutHistory: Identifiable, Codable {
    let id: UUID
    let date: Date
    let sets: [WorkoutSet]
    
    init(id: UUID = UUID(), date: Date, sets: [WorkoutSet]) {
        self.id = id
        self.date = date
        self.sets = sets
    }
}

struct LocalCommit: Identifiable, Codable {
    let id: UUID
    let message: String
    let timestamp: Date
    let fileName: String
    let content: String
    
    init(id: UUID = UUID(), message: String, timestamp: Date, fileName: String, content: String) {
        self.id = id
        self.message = message
        self.timestamp = timestamp
        self.fileName = fileName
        self.content = content
    }
}

// Default workout plan structure
struct WorkoutDay: Codable {
    struct Workout: Codable {
        let warmUp: String
        let workouts: [String]
        let cardio: String
    }
    
    let workouts: [String: Workout]
}

// Settings structure for workout plan customization
struct WorkoutPlanSettings: Codable {
    var days: [String: DayPlan]
    
    struct DayPlan: Codable {
        var warmUp: String
        var workouts: [String]
        var cardio: String
    }
    
    static let empty = WorkoutPlanSettings(days: [:])
}

enum WorkoutType: String, Codable {
    case warmUp = "Warm-Up"
    case main = "Main"
    case cardio = "Cardio"
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: WorkoutType
    let targetSets: Int
    let targetReps: ClosedRange<Int>
    
    init(id: UUID = UUID(), name: String, type: WorkoutType, targetSets: Int, targetReps: ClosedRange<Int>) {
        self.id = id
        self.name = name
        self.type = type
        self.targetSets = targetSets
        self.targetReps = targetReps
    }
} 