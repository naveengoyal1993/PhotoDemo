//
//  ImageViewModel.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//

import SwiftUI
import Combine
import RealmSwift

class ImageViewModel: ObservableObject {
    @Published var images: [ImageEntry] = []
    
    @Published var uploadManager = ImageUploadManager()
    
    private var realm = try! Realm()
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        fetchImages()
    }
    
    // Fetch all images from Realm
    func fetchImages() {
        images = Array(realm.objects(ImageEntry.self).sorted(byKeyPath: "captureDate", ascending: false))
    }
    
    // Save image metadata to Realm
    func saveImage(filePath: String) {
        let imageEntry = ImageEntry()
        imageEntry.filePath = filePath
        imageEntry.fileName = String(filePath.split(separator: "/").last ?? "")
        do {
            try realm.write {
                realm.add(imageEntry)
            }
        } catch {
            print(error)
        }
        fetchImages()
    }
    
    // Upload Images
    func uploadImages() {
        let pendingImages = images.filter { !$0.isUploaded }
        for image in pendingImages {
            uploadImage(image)
        }
    }
    
    private func uploadImage(_ image: ImageEntry) {
        //uploadImageOnServer(image)
        uploadManager.uploadImage(imageID: image.filePath) {[weak self] progressUpdate in
            self?.updateProgress(image, progress: Float(progressUpdate))
        } completion: {[weak self] _ in
            self?.markAsUploaded(image)
        }
    }
    
    private func uploadImageOnServer(_ image: ImageEntry) {
        guard let fileURL = URL(string: image.filePath) else { return }
        var request = URLRequest(url: URL(string: "https://www.clippr.ai/api/upload")!)
        request.httpMethod = "POST"
        let uploadTask = URLSession.shared.uploadTask(with: request, fromFile: fileURL) { [weak self] data, response, error in
            guard error == nil else {
                self?.updateImageStatus(image, status: "Failed")
                return
            }
            self?.markAsUploaded(image)
        }
        uploadTask.resume()
        
        // Track progress
        uploadTask.progress.publisher(for: \.fractionCompleted)
            .sink { progress in
                self.updateProgress(image, progress: Float(progress))
            }
            .store(in: &subscriptions)
    }
    
    private func markAsUploaded(_ image: ImageEntry) {
        do {
            try realm.write {
                image.isUploaded = true
                image.uploadProgress = 1.0
                image.uploadStatus = "Completed"
            }
        } catch {
            print(error)
        }
        fetchImages()
    }
    
    private func updateProgress(_ image: ImageEntry, progress: Float) {
        do {
            try realm.write {
                image.uploadProgress = progress
                image.uploadStatus = progress < 1.0 ? "Uploading" : "Completed"
            }
        } catch {
            print(error)
        }
        fetchImages()
    }
    
    private func updateImageStatus(_ image: ImageEntry, status: String) {
        do {
            try realm.write {
                image.uploadStatus = status
            }
        } catch {
            print(error)
        }
        fetchImages()
    }
}
