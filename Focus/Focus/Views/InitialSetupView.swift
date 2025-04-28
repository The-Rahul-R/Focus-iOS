import SwiftUI
import UIKit

struct InitialSetupView: View {
    @ObservedObject var viewModel: FocusViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var imageData: Data?
    
    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome to Focus")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Let's set up your profile")
                .font(.title3)
                .foregroundColor(.secondary)
            
            // Profile Image Section
            VStack {
                if let imageData = imageData,
                   let image = Image(data: imageData) {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    showingImagePicker = true
                }) {
                    Text("Choose Photo")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 16)
            
            // Username Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Name")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                TextField("Enter your name", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title3)
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Continue Button
            Button(action: {
                saveProfile()
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(username.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(username.isEmpty)
            .padding(.horizontal)
        }
        .padding()
        .sheet(isPresented: $showingImagePicker) {
            FocusProfileImagePicker(image: $inputImage)
        }
        .onChange(of: inputImage) { _, newImage in
            if let newImage = newImage,
               let data = newImage.jpegData(compressionQuality: 0.8) {
                imageData = data
            }
        }
    }
    
    private func saveProfile() {
        viewModel.userProfile.name = username
        if let imageData = imageData {
            viewModel.userProfile.imageData = imageData
        } else if let defaultImage = UIImage(systemName: "person.circle.fill"),
                  let defaultImageData = defaultImage.pngData() {
            viewModel.userProfile.imageData = defaultImageData
        }
        viewModel.saveUserProfile()
        dismiss()
    }
} 