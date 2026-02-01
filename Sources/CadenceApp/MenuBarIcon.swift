import AppKit
import SwiftUI

struct MenuBarIcon: View {
    let phase: TimerState.Phase
    let isRunning: Bool

    private enum DrawingConstants {
        static let iconSize: CGFloat = 18
        static let inset: CGFloat = 2
        static let regularLineWidth: CGFloat = 2
        static let mediumLineWidth: CGFloat = 1.5
        static let thinLineWidth: CGFloat = 1
        static let runningDashPattern: [CGFloat] = [3, 2]
        static let pausedDashPattern: [CGFloat] = [2, 2]
    }

    var body: some View {
        Image(nsImage: createIcon())
    }

    private func createIcon() -> NSImage {
        let size = NSSize(width: DrawingConstants.iconSize, height: DrawingConstants.iconSize)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSColor.black.setStroke()

            let circleRect = rect.insetBy(dx: DrawingConstants.inset, dy: DrawingConstants.inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            switch (phase, isRunning) {
            case (.focus, true):
                // Solid filled circle
                NSBezierPath(ovalIn: circleRect).fill()

            case (.focus, false):
                // Hollow circle outline
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = DrawingConstants.regularLineWidth
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
                                 startAngle: 0, endAngle: 180, clockwise: false)
                topPath.lineWidth = DrawingConstants.mediumLineWidth
                topPath.stroke()

            case (.shortBreak, false):
                // Full circle outline only (no fill)
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = DrawingConstants.mediumLineWidth
                path.stroke()

            case (.longBreak, true):
                // Dashed circle outline
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = DrawingConstants.regularLineWidth
                path.setLineDash(DrawingConstants.runningDashPattern, count: 2, phase: 0)
                path.stroke()

            case (.longBreak, false):
                // Thinner dashed circle
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = DrawingConstants.thinLineWidth
                path.setLineDash(DrawingConstants.pausedDashPattern, count: 2, phase: 0)
                path.stroke()
            }
            return true
        }
        image.isTemplate = true  // Let macOS handle coloring to match menu bar
        return image
    }
}
