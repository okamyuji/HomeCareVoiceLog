import LocalAuthentication
import SwiftUI

extension LABiometryType {
    var lockIconName: String {
        switch self {
        case .faceID:
            "faceid"
        case .touchID:
            "touchid"
        case .opticID:
            "opticid"
        case .none:
            "lock.open"
        @unknown default:
            "lock.open"
        }
    }

    var lockButtonLabelKey: LocalizedStringKey {
        switch self {
        case .faceID:
            "lock.button.faceid"
        case .touchID:
            "lock.button.touchid"
        case .opticID:
            "lock.button.opticid"
        case .none:
            "lock.button.unlock"
        @unknown default:
            "lock.button.unlock"
        }
    }

    var settingsToggleLabelKey: LocalizedStringKey {
        switch self {
        case .faceID:
            "settings.biometric.faceid"
        case .touchID:
            "settings.biometric.touchid"
        case .opticID:
            "settings.biometric.opticid"
        case .none:
            "settings.biometric.lock"
        @unknown default:
            "settings.biometric.lock"
        }
    }
}
