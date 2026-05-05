import SwiftUI

@Observable
class DriveViewModel {
    var isAccelerating = false
    var isBraking = false
    var isReversing = false
    var joystickX: Double = 0
    var joystickY: Double = 0
    var hasPlacedCar = false
    var hasDetectedPlane = false
    var errorMessage: String?
    var currentSpeedRatio: Double = 0

    func clearError() {
        errorMessage = nil
    }
}
