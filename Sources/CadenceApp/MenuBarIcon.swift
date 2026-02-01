import SwiftUI

struct MenuBarIcon: View {
    let progress: Double
    let isFocus: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .opacity(0.25)
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .foregroundStyle(isFocus ? .red : .green)
        .frame(width: 18, height: 18)
        .accessibilityHidden(true)
    }
}
