import SwiftUI

struct ContentView: View {
    @Environment(WaterStore.self) private var store
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressRing(total: store.total(on: .now), goal: store.goal, progress: store.progress(on: .now))
                    addButtons
                    undoButton
                    WeekChart(days: store.lastDays(), goal: store.goal)
                    historySection
                }
                .padding()
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Water")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
        }
    }

    private var addButtons: some View {
        HStack(spacing: 12) {
            addButton(ml: 250)
            addButton(ml: 500)
        }
    }

    private func addButton(ml: Int) -> some View {
        Button {
            store.add(ml)
        } label: {
            Label("+\(ml) ml", systemImage: "drop.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
        }
        .buttonStyle(.borderedProminent)
        .accessibilityLabel("Add \(ml) ml")
    }

    private var undoButton: some View {
        Button {
            store.undoLast()
        } label: {
            Label("Undo last drink", systemImage: "arrow.uturn.backward")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .disabled(store.drinks(on: .now).isEmpty)
    }

    private var historySection: some View {
        let today = store.drinks(on: .now)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Today")
                .font(.headline)
            if today.isEmpty {
                Text("No drinks yet. Tap a button above.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(today.reversed()) { drink in
                    HStack {
                        Image(systemName: "drop.fill").foregroundStyle(.blue)
                        Text("\(drink.ml) ml")
                        Spacer()
                        Text(drink.date.formatted(date: .omitted, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
