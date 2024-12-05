//
//  ContentView.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ImageViewModel()
    @State private var showingCamera = false
    @State private var capturedImagePath: String?

    var body: some View {
        NavigationView {
            VStack {
                List(viewModel.images) { image in
                    HStack {
                        if let uiImage = UIImage(contentsOfFile: image.localFilePath) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        VStack(alignment: .leading) {
                            Text("\(image.uploadStatus)")
                                .font(.headline)
                            ProgressView(value: image.uploadProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                                .padding()
                                .animation(.easeInOut, value: image.uploadProgress)
                        }
                    }
                }
                .navigationTitle("Captured Images")

                Button("Capture Image") {
                    showingCamera = true
                }
                .sheet(isPresented: $showingCamera) {
                    CameraView(capturedImagePath: $capturedImagePath)
                        .onDisappear {
                            if let path = capturedImagePath {
                                viewModel.saveImage(filePath: path)
                                capturedImagePath = nil
                            }
                        }
                }
                Button("Upload Images") {
                    viewModel.uploadImages()
                }
                .padding()
            }
        }
    }
}
