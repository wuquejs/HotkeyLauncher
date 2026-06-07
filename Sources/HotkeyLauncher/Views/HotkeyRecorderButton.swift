import AppKit
import Carbon.HIToolbox
import SwiftUI

struct HotkeyRecorderButton: View {
    @Binding var combination: HotkeyCombination

    let onRecordingChanged: (Bool) -> Void

    @State private var isRecording = false
    @State private var eventMonitor: Any?

    var body: some View {
        Button {
            if isRecording {
                stopRecording()
            } else {
                startRecording()
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isRecording ? "record.circle" : "keyboard")
                Text(isRecording ? "Press shortcut..." : combination.displayName)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
            }
            .frame(minWidth: 180, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .onDisappear {
            stopRecording()
        }
    }

    private func startRecording() {
        guard eventMonitor == nil else {
            return
        }

        isRecording = true
        onRecordingChanged(true)

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            if event.keyCode == UInt16(kVK_Escape) {
                stopRecording()
                return nil
            }

            guard let captured = HotkeyCombination.from(event: event) else {
                NSSound.beep()
                return nil
            }

            combination = captured
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
            self.eventMonitor = nil
        }

        if isRecording {
            isRecording = false
            onRecordingChanged(false)
        }
    }
}
