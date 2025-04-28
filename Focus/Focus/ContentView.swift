//
//  ContentView.swift
//  Focus
//
//  Created by Rahul R on 28/04/25.
//

import SwiftUI

extension Image {
    init?(data: Data) {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            self.init(uiImage: uiImage)
        } else {
            return nil
        }
        #else
        if let nsImage = NSImage(data: data) {
            self.init(nsImage: nsImage)
        } else {
            return nil
        }
        #endif
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FocusViewModel()
    @State private var showInitialSetup = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if viewModel.isActive {
                        ActiveFocusView(viewModel: viewModel)
                    } else {
                        FocusModeSelectionView(viewModel: viewModel)
                    }
                    
                    NavigationLink(destination: ProfileView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text("Profile")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Focus")
        }
        .sheet(isPresented: $showInitialSetup) {
            InitialSetupView(viewModel: viewModel)
        }
        .onAppear {
            // Show initial setup if user profile is not set
            if viewModel.userProfile.name.isEmpty {
                showInitialSetup = true
            }
        }
    }
}

struct FocusModeSelectionView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Select Focus Mode")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)
            
            Text("Choose a mode to start focusing")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 32)
            
            VStack(spacing: 16) {
                ForEach(FocusMode.allCases) { mode in
                    Button(action: {
                        viewModel.startFocus(mode: mode)
                    }) {
                        HStack {
                            Image(systemName: iconForMode(mode))
                                .font(.title2)
                            Text(mode.rawValue)
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(colorForMode(mode))
                        .cornerRadius(12)
                        .shadow(color: colorForMode(mode).opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func iconForMode(_ mode: FocusMode) -> String {
        switch mode {
        case .work: return "briefcase.fill"
        case .play: return "gamecontroller.fill"
        case .rest: return "bed.double.fill"
        case .sleep: return "moon.fill"
        }
    }
    
    private func colorForMode(_ mode: FocusMode) -> Color {
        switch mode {
        case .work: return .blue
        case .play: return .green
        case .rest: return .orange
        case .sleep: return .purple
        }
    }
}

struct ActiveFocusView: View {
    @ObservedObject var viewModel: FocusViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text(viewModel.currentMode?.rawValue ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(colorForMode(viewModel.currentMode ?? .work))
            
            Text(viewModel.formattedTime())
                .font(.system(size: 64, weight: .bold, design: .monospaced))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            
            HStack(spacing: 32) {
                VStack {
                    Text("\(viewModel.points)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Points")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.currentBadges) { badge in
                            Text(badge.emoji)
                                .font(.system(size: 40))
                        }
                    }
                }
                .frame(height: 50)
            }
            
            Button(action: {
                viewModel.stopFocus()
            }) {
                HStack {
                    Image(systemName: "stop.circle.fill")
                    Text("Stop Focusing")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(12)
            }
        }
        .padding()
    }
    
    private func colorForMode(_ mode: FocusMode) -> Color {
        switch mode {
        case .work: return .blue
        case .play: return .green
        case .rest: return .orange
        case .sleep: return .purple
        }
    }
}

struct ProfileView: View {
    @ObservedObject var viewModel: FocusViewModel
    @State private var isEditingProfile = false
    @State private var editedName = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Image Section
                VStack {
                    if let imageData = viewModel.userProfile.imageData,
                       let image = Image(data: imageData) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(.gray)
                    }
                    
                    if isEditingProfile {
                        Button(action: {
                            showingImagePicker = true
                        }) {
                            Text("Change Photo")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.bottom, 8)
                
                // Name Section
                if isEditingProfile {
                    TextField("Enter your name", text: $editedName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                } else {
                    Text(viewModel.userProfile.name.isEmpty ? "Your Name" : viewModel.userProfile.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                // Stats Section
                HStack(spacing: 32) {
                    StatView(title: "Total Points", value: "\(viewModel.userProfile.totalPoints)")
                    StatView(title: "Total Badges", value: "\(viewModel.userProfile.badges.count)")
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Badges Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Badges")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.userProfile.badges) { badge in
                                Text(badge.emoji)
                                    .font(.system(size: 40))
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                
                // Recent Sessions
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ForEach(viewModel.userProfile.sessions.suffix(5).reversed()) { session in
                        SessionCard(session: session)
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditingProfile {
                        // Save changes
                        viewModel.userProfile.name = editedName
                        if let inputImage = inputImage,
                           let imageData = inputImage.jpegData(compressionQuality: 0.8) {
                            viewModel.userProfile.imageData = imageData
                        }
                        viewModel.saveUserProfile()
                    }
                    isEditingProfile.toggle()
                }) {
                    Text(isEditingProfile ? "Done" : "Edit")
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ProfileImagePicker(image: $inputImage)
        }
        .onAppear {
            editedName = viewModel.userProfile.name
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct SessionCard: View {
    let session: Session
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(session.mode.rawValue)
                    .font(.headline)
                Spacer()
                Text(session.formattedDuration)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                Text("\(session.points) points")
                
                Spacer()
                
                Text(session.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ProfileImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
    }
}

#Preview {
    ContentView()
}
