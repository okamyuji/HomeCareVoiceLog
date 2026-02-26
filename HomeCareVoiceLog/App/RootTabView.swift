import SwiftUI

struct RootTabView: View {
    let authService: BiometricAuthService

    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("tab.record", systemImage: "mic")
                }

            TimelineView()
                .tabItem {
                    Label("tab.timeline", systemImage: "list.bullet")
                }

            SummaryShareView()
                .tabItem {
                    Label("tab.summary", systemImage: "square.and.arrow.up")
                }

            SettingsView(authService: authService)
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
        }
    }
}
