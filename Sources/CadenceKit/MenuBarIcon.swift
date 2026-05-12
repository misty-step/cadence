import AppKit

public struct MenuBarIconImage {
    public let phase: TimerState.Phase
    public let isRunning: Bool

    private enum Constants {
        static let size: CGFloat = 18
        static let inset: CGFloat = 2
        static let lineWidth: CGFloat = 2
        static let thinLineWidth: CGFloat = 1.5
        static let veryThinLineWidth: CGFloat = 1
        static let dashPatternLarge: [CGFloat] = [3, 2]
        static let dashPatternSmall: [CGFloat] = [2, 2]
    }

    public init(phase: TimerState.Phase, isRunning: Bool) {
        self.phase = phase
        self.isRunning = isRunning
    }

    public func createNSImage() -> NSImage {
        let size = NSSize(width: Constants.size, height: Constants.size)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.labelColor.setStroke()

            let circleRect = rect.insetBy(dx: Constants.inset, dy: Constants.inset)
            let center = NSPoint(x: rect.midX, y: rect.midY)
            let radius = circleRect.width / 2

            switch (phase, isRunning) {
            case (.focus, true):
                NSColor.labelColor.setFill()
                NSBezierPath(ovalIn: circleRect).fill()

            case (.focus, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.lineWidth
                path.stroke()

            case (.shortBreak, true):
                NSColor.labelColor.setFill()
                let bottomPath = NSBezierPath()
                bottomPath.move(to: NSPoint(x: center.x - radius, y: center.y))
                bottomPath.appendArc(withCenter: center, radius: radius,
                                    startAngle: 180, endAngle: 0, clockwise: true)
                bottomPath.close()
                bottomPath.fill()

                let topPath = NSBezierPath()
                topPath.appendArc(withCenter: center, radius: radius,
                                 startAngle: 0, endAngle: 180, clockwise: false)
                topPath.lineWidth = Constants.thinLineWidth
                topPath.stroke()

            case (.shortBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.thinLineWidth
                path.stroke()

            case (.longBreak, true):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.lineWidth
                path.setLineDash(Constants.dashPatternLarge, count: Constants.dashPatternLarge.count, phase: 0)
                path.stroke()

            case (.longBreak, false):
                let path = NSBezierPath(ovalIn: circleRect)
                path.lineWidth = Constants.veryThinLineWidth
                path.setLineDash(Constants.dashPatternSmall, count: Constants.dashPatternSmall.count, phase: 0)
                path.stroke()
            }
            return true
        }
        image.isTemplate = true
        return image
    }
}
