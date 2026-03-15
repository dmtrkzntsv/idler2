import SwiftUI
import IOKit.pwr_mgt
import CoreGraphics

// MARK: - Sleep Blocker

class SleepBlocker: ObservableObject {
    @Published var isActive: Bool = false

    private var systemAssertionID: IOPMAssertionID = 0
    private var displayAssertionID: IOPMAssertionID = 0
    private var timer: Timer?

    func toggle() {
        if isActive {
            stop()
        } else {
            start()
        }
    }

    func start() {
        guard !isActive else { return }

        // Create IOKit assertion to prevent system sleep
        let systemResult = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleSystemSleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Idler: preventing system sleep" as CFString,
            &systemAssertionID
        )

        // Create IOKit assertion to prevent display sleep
        let displayResult = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            "Idler: preventing display sleep" as CFString,
            &displayAssertionID
        )

        guard systemResult == kIOReturnSuccess && displayResult == kIOReturnSuccess else {
            return
        }

        isActive = true

        // Start activity simulation every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.simulateActivity()
        }
    }

    func stop() {
        guard isActive else { return }

        // Release IOKit assertions
        if systemAssertionID != 0 {
            IOPMAssertionRelease(systemAssertionID)
            systemAssertionID = 0
        }
        if displayAssertionID != 0 {
            IOPMAssertionRelease(displayAssertionID)
            displayAssertionID = 0
        }

        timer?.invalidate()
        timer = nil
        isActive = false
    }

    private func simulateActivity() {
        // Declare user activity to IOKit
        var activityID: IOPMAssertionID = 0
        IOPMAssertionDeclareUserActivity(
            "Idler: user activity" as CFString,
            kIOPMUserActiveLocal,
            &activityID
        )

        // Nudge mouse 1 pixel right, then back (imperceptible)
        nudgeMouse()
    }

    private func nudgeMouse() {
        let loc = NSEvent.mouseLocation
        // NSEvent uses bottom-left origin in global coordinates.
        // CGEvent uses top-left origin relative to the primary screen.
        // Primary screen's maxY gives us the global top edge for the conversion.
        let primaryHeight = NSScreen.screens.first?.frame.maxY ?? 0
        let cgY = primaryHeight - loc.y
        let cgPoint = CGPoint(x: loc.x + 1, y: cgY)
        let cgPointBack = CGPoint(x: loc.x, y: cgY)

        if let moveRight = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                    mouseCursorPosition: cgPoint, mouseButton: .left) {
            moveRight.post(tap: .cghidEventTap)
        }
        // Move back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let moveBack = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved,
                                       mouseCursorPosition: cgPointBack, mouseButton: .left) {
                moveBack.post(tap: .cghidEventTap)
            }
        }
    }

    deinit {
        stop()
    }
}

// MARK: - App

@main
struct IdlerApp: App {
    @StateObject private var blocker = SleepBlocker()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 0) {
                // Status header
                HStack(spacing: 8) {
                    Circle()
                        .fill(blocker.isActive ? Color.green : Color.secondary.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Text(blocker.isActive ? "Sleep prevention active" : "Sleep allowed")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 8)

                Divider()

                // Toggle button
                Button(action: { blocker.toggle() }) {
                    Label(
                        blocker.isActive ? "Allow Sleep" : "Prevent Sleep",
                        systemImage: blocker.isActive ? "moon.zzz" : "bolt.fill"
                    )
                }
                .keyboardShortcut("s")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Divider()

                Button("Quit") {
                    blocker.stop()
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .padding(.bottom, 4)
            }
            .frame(width: 220)
        } label: {
            Image(systemName: blocker.isActive ? "bolt.fill" : "moon.zzz")
        }
        .menuBarExtraStyle(.window)
    }
}
