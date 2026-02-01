import AppKit
import SwiftUI

struct MenuBarIcon: View {
    let phase: TimerState.Phase
    let isRunning: Bool

    var body: some View {
        Image(nsImage: createIcon())
    }

    private func createIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSColor.black.setStroke()

            let inset: CGFloat = 2
            let circleRect = rect.insetBy(dx: inset, dy: inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            switch (phase, isRunning) {
            case (.focus, true):
                // Solid filled circle
                NSBezierPath(ovalIn: circleRect).fill()

            case (.focus, false):
                // Hollow circle outline
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.stroke()

            case (.shortBreak, true):
                // Bottom half filled, top half stroked
                // Bottom half - filled
                let bottomPath = NSBezierPath()
                bottomPath.move(to: NSPoint(x: center.x - radius, y: center.y))
                bottomPath.appendArc(withCenter: center, radius: radius,
                                    startAngle: 180, endAngle: 0, clockwise: true)
                bottomPath.close()
                bottomPath.fill()

                // Top half - stroked
                let topPath = NSBezierPath()
                topPath.appendArc(withCenter: center, radius: radius,
                                 startAngle: 0, endAngle: 180, clockwise: true)
                topPath.lineWidth = 1.5
                topPath.stroke()

            case (.shortBreak, false):
                // Full circle outline only (no fill)
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 1.5
                path.stroke()

            case (.longBreak, true):
                // Dashed circle outline
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 2
                path.setLineDash([3, 2], count: 2, phase: 0)
                path.stroke()

            case (.longBreak, false):
                // Thinner dashed circle
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = 1
                path.setLineDash([2, 2], count: 2, phase: 0)
                path.stroke()
            }
            return true
        }
        image.isTemplate = true  // Let macOS handle coloring to match menu bar
        return image
    }
}
