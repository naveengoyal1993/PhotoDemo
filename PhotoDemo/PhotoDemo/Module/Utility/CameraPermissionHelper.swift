//
//  CameraPermissionHelper.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//


import AVFoundation

struct CameraPermissionHelper {
    static func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            // Permission already granted
            completion(true)
        case .notDetermined:
            // Request permission
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            // Permission denied
            completion(false)
        @unknown default:
            completion(false)
        }
    }
}
