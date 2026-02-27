import SwiftUI

extension View {
    func appErrorAlert(_ item: Binding<AppErrorAlert?>) -> some View {
        alert(
            item.wrappedValue?.titleKey ?? "",
            isPresented: item.isPresent,
            presenting: item.wrappedValue
        ) { _ in
            Button("OK", role: .cancel) {}
        } message: { alert in
            Text(alert.message)
        }
    }
}
