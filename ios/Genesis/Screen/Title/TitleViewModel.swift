import SwiftUI
import AVFoundation

@Observable
class TitleViewModel {
    var isShowingAR = false
    var isShowingSettings = false
    var isShowingCameraPermissionDenied = false
    var titleOpacity: Double = 0
    var buttonOpacity: Double = 0

    func startAnimations() {
        withAnimation(.easeIn(duration: 1.0)) {
            titleOpacity = 1.0
        }
        withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
            buttonOpacity = 1.0
        }
    }

    func requestCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isShowingAR = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.isShowingAR = true
                    } else {
                        self?.isShowingCameraPermissionDenied = true
                    }
                }
            }
        case .denied, .restricted:
            isShowingCameraPermissionDenied = true
        default:
            isShowingAR = true
        }
    }
}
