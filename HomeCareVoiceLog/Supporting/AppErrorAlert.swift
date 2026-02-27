import SwiftUI

struct AppErrorAlert: Identifiable {
    let id = UUID()
    let titleKey: LocalizedStringKey
    let message: String
}
