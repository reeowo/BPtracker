import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var allRecords: [BloodPressureRecord]
    @State private var selectedDays: Int = 7
    @State private var selectedBPDate: Date?
    @State private var selectedHRDate: Date?

    private var filteredRecords: [BloodPressureRecord] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -(selectedDays - 1), to: calendar.startOfDay(for: .now))!
        return allRecords
            .filter { $0.timestamp >= startDate }
            .sorted { $0.timestamp < $1.timestamp }
    }

    private var selectedBPRecord: BloodPressureRecord? {
        guard let selectedDate = selectedBPDate else { return nil }
        return closestRecord(to: selectedDate)
    }

    private var selectedHRRecord: BloodPressureRecord? {
        guard let selectedDate = selectedHRDate else { return nil }
        return closestRecord(to: selectedDate)
    }

    private func closestRecord(to date: Date) -> BloodPressureRecord? {
        filteredRecords.min(by: {
            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
        })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    periodPicker
                    bpChart
                    heartRateChart
                    summaryCard
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("统计趋势")
        }
    }

    private var periodPicker: some View {
        Picker("周期", selection: $selectedDays) {
            Text("7天").tag(7)
            Text("14天").tag(14)
            Text("30天").tag(30)
        }
        .pickerStyle(.segmented)
        .onChange(of: selectedDays) {
            selectedBPDate = nil
            selectedHRDate = nil
        }
    }

    private var bpChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("血压趋势")
                    .font(.headline)
                Spacer()
                if let r = selectedBPRecord {
                    selectedBPBadge(r)
                }
            }

            if filteredRecords.isEmpty {
                chartEmptyView
            } else {
                Chart {
                    ForEach(filteredRecords) { item in
                        LineMark(
                            x: .value("时间", item.timestamp),
                            y: .value("mmHg", item.systolic),
                            series: .value("类型", "收缩压")
                        )
                        .foregroundStyle(.red)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("时间", item.timestamp),
                            y: .value("mmHg", item.diastolic),
                            series: .value("类型", "舒张压")
                        )
                        .foregroundStyle(.blue)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }

                    RuleMark(y: .value("高压警戒", 140))
                        .foregroundStyle(.red.opacity(0.3))
                        .lineStyle(StrokeStyle(dash: [5, 5]))

                    RuleMark(y: .value("低压警戒", 90))
                        .foregroundStyle(.blue.opacity(0.3))
                        .lineStyle(StrokeStyle(dash: [5, 5]))

                    if let r = selectedBPRecord {
                        RuleMark(x: .value("选中", r.timestamp))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .annotation(position: .top, spacing: 4) {
                                VStack(spacing: 2) {
                                    Text("\(r.systolic)/\(r.diastolic)")
                                        .font(.caption.bold().monospacedDigit())
                                    Text(r.timeString)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                    }
                }
                .chartYScale(domain: 40...200)
                .chartXSelection(value: $selectedBPDate)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(selectedDays / 7, 1))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .chartLegend(position: .bottom) {
                    HStack(spacing: 16) {
                        Label("收缩压", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.red)
                        Label("舒张压", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func selectedBPBadge(_ r: BloodPressureRecord) -> some View {
        let level = BPLevel.evaluate(systolic: r.systolic, diastolic: r.diastolic)
        return HStack(spacing: 4) {
            Image(systemName: level.icon)
                .font(.caption2)
            Text("\(r.systolic)/\(r.diastolic)")
                .font(.caption.bold().monospacedDigit())
        }
        .foregroundStyle(level.color)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(level.color.opacity(0.12), in: Capsule())
    }

    private var heartRateChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("心率趋势")
                    .font(.headline)
                Spacer()
                if let r = selectedHRRecord {
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.caption2)
                        Text("\(r.heartRate) bpm")
                            .font(.caption.bold().monospacedDigit())
                    }
                    .foregroundStyle(.pink)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.pink.opacity(0.12), in: Capsule())
                }
            }

            if filteredRecords.isEmpty {
                chartEmptyView
            } else {
                Chart {
                    ForEach(filteredRecords) { item in
                        AreaMark(
                            x: .value("时间", item.timestamp),
                            y: .value("bpm", item.heartRate)
                        )
                        .foregroundStyle(.pink.opacity(0.15))
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("时间", item.timestamp),
                            y: .value("bpm", item.heartRate)
                        )
                        .foregroundStyle(.pink)
                        .symbol(Circle())
                        .interpolationMethod(.catmullRom)
                    }

                    if let r = selectedHRRecord {
                        RuleMark(x: .value("选中", r.timestamp))
                            .foregroundStyle(.gray.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                            .annotation(position: .top, spacing: 4) {
                                VStack(spacing: 2) {
                                    Text("\(r.heartRate) bpm")
                                        .font(.caption.bold().monospacedDigit())
                                    Text(r.timeString)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 6))
                            }
                    }
                }
                .chartYScale(domain: 40...160)
                .chartXSelection(value: $selectedHRDate)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: max(selectedDays / 7, 1))) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day())
                    }
                }
                .frame(height: 180)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var chartEmptyView: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title)
                .foregroundStyle(.tertiary)
            Text("暂无数据")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 180)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("周期概览")
                .font(.headline)

            if filteredRecords.isEmpty {
                Text("暂无数据")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                let sysValues = filteredRecords.map(\.systolic)
                let diaValues = filteredRecords.map(\.diastolic)
                let hrValues = filteredRecords.map(\.heartRate)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    summaryItem(title: "收缩压范围", value: "\(sysValues.min()!)-\(sysValues.max()!)", unit: "mmHg", color: .red)
                    summaryItem(title: "舒张压范围", value: "\(diaValues.min()!)-\(diaValues.max()!)", unit: "mmHg", color: .blue)
                    summaryItem(title: "心率范围", value: "\(hrValues.min()!)-\(hrValues.max()!)", unit: "bpm", color: .pink)
                    summaryItem(title: "测量次数", value: "\(filteredRecords.count)", unit: "次", color: .green)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func summaryItem(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(color)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(color.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatsView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
