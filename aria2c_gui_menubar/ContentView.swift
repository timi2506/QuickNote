import SwiftUI
import AppKit

struct ContentView: View {
    @State private var notes: String = ""
    @State private var isNextWindowPresented: Bool = false

    var body: some View {
        VStack {
            Text("Enter notes for the file")
                .font(.headline)
            
            TextEditor(text: $notes)
                .frame(height: 175) // Adjust height to make the TextEditor larger
                .border(Color.gray, width: 1) // Optional: Add border for better visibility
                .padding()
            
            HStack {
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                Button("Continue") {
                    if !notes.isEmpty {
                        if let defaultPath = UserDefaults.standard.string(forKey: "defaultPath") {
                            // Use the default path and show the PathSelectionView
                            isNextWindowPresented = true
                        } else {
                            isNextWindowPresented = true
                        }
                    }
                }
                .disabled(notes.isEmpty)
            }
            .padding()
        }
        .padding()
        .frame(width: 400, height: 325)
        .sheet(isPresented: $isNextWindowPresented) {
            PathSelectionView(notes: notes)
        }
    }

    func executeAria2Download(url: String, path: String, fileName: String, notes: String) {
        let command = "\(path) &%& \(fileName) &%& \(notes)"
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        
        print("Copied to clipboard: \(command)")
        
        if let shortcutsURL = URL(string: "shortcuts://run-shortcut?name=DONT_CHANGE_NOTES_SAVER") {
            NSWorkspace.shared.open(shortcutsURL)
        }
    }
}
