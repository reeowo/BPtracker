import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var allRecords: [BloodPressureRecord]
    @Binding var showAddRecord: Bool

    private var todayRecords: [BloodPressureRecord] {
        RecordStore.todayRecords(from: allRecords)
    }

    private var todayAverage: (systolic: Int, diastolic: Int, heartRate: Int)? {
        RecordStore.dailyAverage(todayRecords)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    todayCard
                    quickAddButton
                    recentSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("今日血压")
        }
    }

    private var todayCard: some View {
        VStack(spacing: 16) {
            if let avg = todayAverage {
                let level = BPLevel.evaluate(systolic: avg.systolic, diastolic: avg.diastolic)

                HStack(spacing: 4) {
                    Image(systemName: level.icon)
                        .foregroundStyle(level.color)
                    Text(level.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(level.color)
                }

                HStack(spacing: 32) {
                    bpValueColumn(title: "收缩压", value: avg.systolic, unit: "mmHg")
                    divider
                    bpValueColumn(title: "舒张压", value: avg.diastolic, unit: "mmHg")
                    divider
                    bpValueColumn(title: "心率", value: avg.heartRate, unit: "bpm")
                }

                Text("今日已测量 \(todayRecords.count) 次")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 48))
                    .foregroundStyle(.tertiary)
                Text("今天还没有记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("点击下方按钮开始记录血压")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    private var divider: some View {
        Rectangle()
            .fill(.quaternary)
            .frame(width: 1, height: 40)
    }

    private func bpValueColumn(title: String, value: Int, unit: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var quickAddButton: some View {
        Button {
            showAddRecord = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("记录血压")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                LinearGradient(
                    colors: [.pink, .red.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !todayRecords.isEmpty {
                Text("今日记录")
                    .font(.headline)
                    .padding(.leading, 4)

                ForEach(todayRecords) { record in
                    recordRow(record)
                }
            }

            if allRecords.count > todayRecords.count {
                let yesterdayAndBefore = Array(allRecords.filter { !todayRecords.contains($0) }.prefix(5))
                if !yesterdayAndBefore.isEmpty {
                    Text("历史记录")
                        .font(.headline)
                        .padding(.leading, 4)
                        .padding(.top, 8)

                    ForEach(yesterdayAndBefore) { record in
                        recordRow(record)
                    }
                }
            }
        }
    }

    private func recordRow(_ record: BloodPressureRecord) -> some View {
        HStack {
            Circle()
                .fill(record.level.color.opacity(0.2))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: record.level.icon)
                        .foregroundStyle(record.level.color)
                        .font(.callout)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.systolic)/\(record.diastolic) mmHg")
                    .font(.subheadline.bold())
                HStack(spacing: 8) {
                    Label("\(record.heartRate) bpm", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                    if !record.note.isEmpty {
                        Text(record.note)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(record.timeString)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                Text(RecordStore.formatDate(record.timestamp, style: "M/d"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView(showAddRecord: .constant(false))
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
