import Foundation

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