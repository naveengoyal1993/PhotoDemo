//
//  CameraView.swift
//  SimplePhoto
//
//  Created by Naveen Goyal on 05/12/24.
//
import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImagePath: String?
    @Environment(\.presentationMode) var presentationMode // Add this to handle dismissal

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = CameraViewController()
        // Check for camera permission
           CameraPermissionHelper.checkCameraPermission { authorized in
               if authorized {
                   controller.delegate = context.coordinator
               } else {
                   self.showPermissionAlert(controller: controller)
   
               }
           }
           return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, AVCapturePhotoCaptureDelegate {
        var parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
            guard let data = photo.fileDataRepresentation(),
                  let image = UIImage(data: data) else { return }

            let filePath = saveImageToDisk(image)
            parent.capturedImagePath = filePath
            parent.presentationMode.wrappedValue.dismiss()
        }

        private func saveImageToDisk(_ image: UIImage) -> String {
            let fileName = UUID().uuidString + ".jpg"
            let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent(fileName).path
            let url = URL(fileURLWithPath: filePath)
            try? image.jpegData(compressionQuality: 0.8)?.write(to: url)
            return filePath
        }
    }
    
        private func showPermissionAlert(controller: UIViewController) {
            let alert = UIAlertController(
                title: "Camera Permission Required",
                message: "This app requires camera access to capture images. Please enable camera permissions in Settings.",
                preferredStyle: .alert
            )
    
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
                if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                }
            }))
    
            DispatchQueue.main.async {
                controller.present(alert, animated: true)
            }
        }
}

class CameraViewController: UIViewController {
    var session: AVCaptureSession!
    var photoOutput: AVCapturePhotoOutput!
    weak var delegate: AVCapturePhotoCaptureDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCameraSession()
        addCaptureButton()
    }

    private func setupCameraSession() {
        session = AVCaptureSession()
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else { return }

        session.addInput(input)

        photoOutput = AVCapturePhotoOutput()
        session.addOutput(photoOutput)

        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Start session on a background thread
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }

    private func addCaptureButton() {
        let button = UIButton(type: .system)
        button.frame = CGRect(x: view.bounds.midX - 35, y: view.bounds.height - 200, width: 70, height: 70)
        button.backgroundColor = .white
        button.layer.cornerRadius = 35
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.gray.cgColor
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        view.addSubview(button)
    }

    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }

        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: delegate!)
    }
}
