import SwiftUI

struct ProgressRing: View {
    let total: Int
    let goal: Int
    let progress: Double

    private var gradient: AngularGradient {
        AngularGradient(colors: [.cyan, .blue, .cyan], center: .center)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.blue.opacity(0.15), lineWidth: 24)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(gradient, style: StrokeStyle(lineWidth: 24, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)
            VStack(spacing: 4) {
                Text("\(total) ml")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())
                Text("of \(goal) ml goal")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 240, height: 240)
        .padding(12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Water progress")
        .accessibilityValue("\(total) of \(goal) millilitres")
    }
}
