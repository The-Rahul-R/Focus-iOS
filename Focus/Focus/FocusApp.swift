//
//  FocusApp.swift
//  Focus
//
//  Created by Rahul R on 28/04/25.
//

import SwiftUI

@main
struct FocusApp: App {
    @StateObject private var viewModel = FocusViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .active:
                // App became active - check if we need to restore a session
                if viewModel.isActive {
                    // Restore the timer
                    viewModel.startFocus(mode: viewModel.currentMode!)
                }
            case .inactive:
                // App is about to become inactive - save state
                if viewModel.isActive {
                    viewModel.saveUserProfile()
                }
            case .background:
                // App is in background - save state
                if viewModel.isActive {
                    viewModel.saveUserProfile()
                }
            @unknown default:
                break
            }
        }
    }
}
