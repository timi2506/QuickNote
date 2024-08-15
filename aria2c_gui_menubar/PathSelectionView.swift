import SwiftUI
import Foundation
import AppKit

struct PathSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var path: String = UserDefaults.standard.string(forKey: "defaultPath") ?? ""
    @State private var fileName: String = ""
    @State private var isShowingFileChooser: Bool = false
    let notes: String

    var body: some View {
        VStack {
            HStack {
                TextField("Choose Save Location", text: $path)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Browse") {
                    isShowingFileChooser = true
                }
                .fileImporter(isPresented: $isShowingFileChooser, allowedContentTypes: [.folder]) { result in
                    switch result {
                    case .success(let selectedPath):
                        // Ensure only the directory path is stored, without any file name
                        path = selectedPath.path
                    case .failure(let error):
                        print("Failed to select path: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            
            HStack {
                TextField("Enter File Name and Extension", text: $fileName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()

            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                
                Button("Done") {
                    // Use the default path if no path is selected
                    if let defaultPath = UserDefaults.standard.string(forKey: "defaultPath"), path.isEmpty {
                        path = defaultPath
                    }

                    // Form the full path by combining the directory path and the file name
                    let fullPath = "\(path)/\(fileName)"
                    copyCommandToClipboard(path: fullPath, fileName: fileName, notes: notes)
                    openURLScheme()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(fileName.isEmpty)
            }
            .padding()
        }
        .padding()
        .frame(width: 400, height: 200)
    }
    
    func copyCommandToClipboard(path: String, fileName: String, notes: String) {
        let command = "\(path) &%& \(fileName) &%& \(notes)"
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
        
        print("Command copied to clipboard: \(command)")
    }
    
    func openURLScheme() {
        let urlScheme = "shortcuts://run-shortcut?name=DONT_CHANGE_NOTES_SAVER"
        if let url = URL(string: urlScheme) {
            NSWorkspace.shared.open(url)
        }
    }
}
