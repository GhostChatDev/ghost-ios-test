import SwiftUI
import Charts

struct WeekChart: View {
    let days: [DayTotal]
    let goal: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 7 days")
                .font(.headline)
            Chart {
                ForEach(days) { item in
                    BarMark(
                        x: .value("Day", item.day, unit: .day),
                        y: .value("Millilitres", item.ml)
                    )
                    .foregroundStyle(item.ml >= goal ? Color.green : Color.blue)
                    .cornerRadius(4)
                }
                RuleMark(y: .value("Goal", goal))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(.secondary)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                }
            }
            .frame(height: 180)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}
