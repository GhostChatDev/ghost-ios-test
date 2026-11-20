import SwiftUI

struct SettingsView: View {
    @Environment(WaterStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let goal = Binding<Int>(get: { store.goal }, set: { store.setGoal($0) })
        NavigationStack {
            Form {
                Section("Daily goal") {
                    Stepper(value: goal, in: 500...6000, step: 250) {
                        Text("\(store.goal) ml")
                            .monospacedDigit()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
