import Foundation
import SwiftUI

class FocusViewModel: ObservableObject {
    @Published var currentMode: FocusMode?
    @Published var timer: Timer?
    @Published var elapsedTime: TimeInterval = 0
    @Published var points: Int = 0
    @Published var currentBadges: [Badge] = []
    @Published var userProfile = UserProfile()
    @Published var isActive = false
    
    private var startTime: Date?
    private var lastPointTime: Date?
    
    init() {
        loadUserProfile()
    }
    
    func startFocus(mode: FocusMode) {
        currentMode = mode
        startTime = Date()
        lastPointTime = Date()
        isActive = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime = Date().timeIntervalSince(self.startTime!)
            
            //logic to Award points and badges every 2 minutes
            if let lastPointTime = self.lastPointTime,
               Date().timeIntervalSince(lastPointTime) >= 120 {
                self.points += 1
                let newBadge = Badge.randomBadge()
                self.currentBadges.append(newBadge)
                
                //logic to Update user profile immediately
                DispatchQueue.main.async {
                    self.userProfile.totalPoints += 1
                    self.userProfile.badges.append(newBadge)
                    self.saveUserProfile()
                }
                
                self.lastPointTime = Date()
            }
        }
    }
    
    func stopFocus() {
        guard let startTime = startTime else { return }
        
        timer?.invalidate()
        timer = nil
        
        let session = Session(
            mode: currentMode!,
            startTime: startTime,
            endTime: Date(),
            points: points,
            badges: currentBadges
        )
        
        userProfile.sessions.append(session)
        saveUserProfile()
        
        // Reset the state
        currentMode = nil
        elapsedTime = 0
        points = 0
        currentBadges = []
        isActive = false
    }
    
    func formattedTime() -> String {
        let hours = Int(elapsedTime) / 3600
        let minutes = Int(elapsedTime) / 60 % 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
        }
    }
    
    private func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: "userProfile"),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
    }
} 
