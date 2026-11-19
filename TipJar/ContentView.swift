import SwiftUI

// A tip calculator. Every button on this screen changes what is shown.
struct ContentView: View {
    @State private var billCents = 5_000
    @State private var tipPercent = 15
    @State private var people = 2
    @State private var roundUp = false

    private var tipCents: Int { billCents * tipPercent / 100 }
    private var totalCents: Int { billCents + tipCents }
    private var perPersonCents: Int {
        let share = (totalCents + people - 1) / people
        return roundUp ? ((share + 99) / 100) * 100 : share
    }

    private func money(_ cents: Int) -> String { String(format: "$%d.%02d", cents / 100, cents % 100) }

    var body: some View {
        VStack(spacing: 20) {
            Text("Tip Jar").font(.largeTitle.bold())

            VStack(spacing: 6) {
                Text("Bill \(money(billCents))").font(.title2)
                HStack {
                    Button("- $5") { billCents = max(0, billCents - 500) }
                    Button("+ $5") { billCents += 500 }
                }
                .buttonStyle(.bordered)
            }

            VStack(spacing: 6) {
                Text("Tip \(tipPercent)% · \(money(tipCents))")
                HStack {
                    ForEach([10, 18, 20, 25], id: \.self) { p in
                        Button("\(p)%") { tipPercent = p }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }

            VStack(spacing: 6) {
                Text("\(people) people")
                HStack {
                    Button("Fewer people") { people = max(1, people - 1) }
                    Button("More people") { people += 1 }
                }
                .buttonStyle(.bordered)
            }

            Button(roundUp ? "Exact amount" : "Round up") { roundUp.toggle() }

            Text("Each pays \(money(perPersonCents))")
                .font(.title.bold())
                .accessibilityIdentifier("perPerson")
        }
        .padding()
    }
}
