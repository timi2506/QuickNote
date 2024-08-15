import SwiftUI

@main
struct Aria2cGuiMenubarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView() // No main window needed
        }
    }
}
