import SwiftUI

struct RootTabView: View {
    @State private var recordViewModel = RecordViewModel(
        audioRecorder: AudioRecorderService(),
        speechTranscriber: SpeechTranscriptionService()
    )

    var body: some View {
        TabView {
            RecordView(viewModel: recordViewModel)
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

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape")
                }
        }
    }
}
