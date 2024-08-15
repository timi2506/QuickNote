import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, NSDraggingDestination {
    var statusItem: NSStatusItem?
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up the status item (menu bar icon)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "note.text", accessibilityDescription: "QuickNote")
            button.action = #selector(statusItemClicked(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.window?.registerForDraggedTypes([.fileURL])
            button.window?.delegate = self
        }

        // Set up the popover
        popover.contentViewController = NSHostingController(rootView: ContentView())
        popover.behavior = .transient
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            // Show the menu on right-click
            statusItem?.menu = createMenu()
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil // Clear the menu to prevent it from showing on the next left-click
        } else if event.type == .leftMouseUp {
            // Show the popover on left-click
            togglePopover(sender)
        }
    }

    func createMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        return menu
    }

    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let button = statusItem?.button {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    @objc func openSettings() {
        let settingsView = SettingsView()
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false)
        settingsWindow.isReleasedWhenClosed = false
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("Settings")
        settingsWindow.contentView = NSHostingView(rootView: settingsView)
        settingsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Drag-and-Drop Support

    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let draggedFileURL = NSURL(from: sender.draggingPasteboard) as URL?,
              draggedFileURL.hasDirectoryPath else {
            return false
        }

        // Save the default path
        UserDefaults.standard.set(draggedFileURL.path, forKey: "defaultPath")
        return true
    }
}

// Settings view to manage the default path
struct SettingsView: View {
    @State private var defaultPath: String = UserDefaults.standard.string(forKey: "defaultPath") ?? ""

    var body: some View {
        VStack {
            if !defaultPath.isEmpty {
                Text("Current Default Path:")
                Text(defaultPath)
                    .font(.system(size: 12))
                    .padding()

                Button("Delete Default Path") {
                    UserDefaults.standard.removeObject(forKey: "defaultPath")
                    defaultPath = ""
                }
                .padding()
            } else {
                Text("No Default Path Set")
            }

            Button("Re-select Default Path") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canChooseFiles = false
                panel.allowsMultipleSelection = false
                if panel.runModal() == .OK, let url = panel.url {
                    UserDefaults.standard.set(url.path, forKey: "defaultPath")
                    defaultPath = url.path
                }
            }
            .padding()
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}
