import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "mic")
                }

            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "list.bullet")
                }

            SummaryShareView()
                .tabItem {
                    Label("Summary", systemImage: "square.and.arrow.up")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}
