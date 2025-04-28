import Foundation

enum FocusMode: String, CaseIterable, Identifiable, Codable {
    case work = "Work"
    case play = "Play"
    case rest = "Rest"
    case sleep = "Sleep"
    
    var id: String { rawValue }
}

struct Badge: Identifiable, Codable {
    let id: UUID
    let emoji: String
    let type: BadgeType
    let timestamp: Date
    
    init(emoji: String, type: BadgeType, timestamp: Date) {
        self.id = UUID()
        self.emoji = emoji
        self.type = type
        self.timestamp = timestamp
    }
    
    enum BadgeType: String, Codable {
        case tree
        case leaf
        case animal
    }
    
    static let treeEmojis = ["🌵", "🎄", "🌲", "🌳", "🌴"]
    static let leafEmojis = ["🍂", "🍁", "🍄"]
    static let animalEmojis = ["🐅", "🦅", "🐵", "🐝"]
    
    static func randomBadge() -> Badge {
        let types: [BadgeType] = [.tree, .leaf, .animal]
        let randomType = types.randomElement()!
        
        let emoji: String
        switch randomType {
        case .tree:
            emoji = treeEmojis.randomElement()!
        case .leaf:
            emoji = leafEmojis.randomElement()!
        case .animal:
            emoji = animalEmojis.randomElement()!
        }
        
        return Badge(emoji: emoji, type: randomType, timestamp: Date())
    }
}

struct Session: Identifiable, Codable {
    let id: UUID
    let mode: FocusMode
    let startTime: Date
    let endTime: Date
    let points: Int
    let badges: [Badge]
    
    init(mode: FocusMode, startTime: Date, endTime: Date, points: Int, badges: [Badge]) {
        self.id = UUID()
        self.mode = mode
        self.startTime = startTime
        self.endTime = endTime
        self.points = points
        self.badges = badges
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

class UserProfile: ObservableObject, Codable {
    @Published var name: String
    @Published var imageData: Data?
    @Published var totalPoints: Int
    @Published var badges: [Badge]
    @Published var sessions: [Session]
    
    init(name: String = "", imageData: Data? = nil, totalPoints: Int = 0, badges: [Badge] = [], sessions: [Session] = []) {
        self.name = name
        self.imageData = imageData
        self.totalPoints = totalPoints
        self.badges = badges
        self.sessions = sessions
    }
    
    // Added Codable conformance for UserProfile
    enum CodingKeys: String, CodingKey {
        case name, imageData, totalPoints, badges, sessions
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        totalPoints = try container.decode(Int.self, forKey: .totalPoints)
        badges = try container.decode([Badge].self, forKey: .badges)
        sessions = try container.decode([Session].self, forKey: .sessions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(imageData, forKey: .imageData)
        try container.encode(totalPoints, forKey: .totalPoints)
        try container.encode(badges, forKey: .badges)
        try container.encode(sessions, forKey: .sessions)
    }
} 
