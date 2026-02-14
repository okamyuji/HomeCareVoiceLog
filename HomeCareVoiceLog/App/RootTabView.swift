import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label(String(localized: "tab.record"), systemImage: "mic")
                }

            TimelineView()
                .tabItem {
                    Label(String(localized: "tab.timeline"), systemImage: "list.bullet")
                }

            SummaryShareView()
                .tabItem {
                    Label(String(localized: "tab.summary"), systemImage: "square.and.arrow.up")
                }

            SettingsView()
                .tabItem {
                    Label(String(localized: "tab.settings"), systemImage: "gearshape")
                }
        }
    }
}
