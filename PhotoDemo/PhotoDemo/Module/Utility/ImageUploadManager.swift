//
//  ImageUploadManager.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//

import Foundation
import Combine

class ImageUploadManager: ObservableObject {
    @Published var uploadProgress: [String: Double] = [:] // Track progress by image ID
    private var timers: [String: Timer] = [:] // Store timers for each image

    func uploadImage(imageID: String, progressUpdate: @escaping (Double) -> Void, completion: @escaping (Bool) -> Void) {
        // Start at 0% progress
        uploadProgress[imageID] = 0.0

        // Create a timer to simulate progress
        let timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            // Increment progress
            if let progress = self.uploadProgress[imageID], progress < 1.0 {
                self.uploadProgress[imageID] = progress + 0.05 // Increment progress by 5%
                progressUpdate(self.uploadProgress[imageID]!)
            } else {
                // Complete upload
                timer.invalidate()
                self.timers.removeValue(forKey: imageID)
                self.uploadProgress[imageID] = 1.0 // Ensure progress is 100%
                completion(true)
            }
        }

        // Store the timer
        timers[imageID] = timer
    }

    func cancelUpload(imageID: String) {
        // Cancel and remove timer for the given image ID
        if let timer = timers[imageID] {
            timer.invalidate()
            timers.removeValue(forKey: imageID)
            uploadProgress[imageID] = nil
        }
    }
}
