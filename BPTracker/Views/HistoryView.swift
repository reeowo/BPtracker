import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \BloodPressureRecord.timestamp, order: .reverse) private var allRecords: [BloodPressureRecord]
    @Environment(\.modelContext) private var modelContext

    private var groupedRecords: [(date: Date, records: [BloodPressureRecord])] {
        RecordStore.groupByDay(allRecords)
    }

    var body: some View {
        NavigationStack {
            Group {
                if allRecords.isEmpty {
                    emptyState
                } else {
                    recordList
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("历史记录")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("暂无记录")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("开始记录你的血压数据吧")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var recordList: some View {
        List {
            ForEach(groupedRecords, id: \.date) { group in
                Section {
                    if let avg = RecordStore.dailyAverage(group.records) {
                        dailyAverageRow(avg: avg, count: group.records.count)
                    }

                    ForEach(group.records) { record in
                        recordRow(record)
                    }
                    .onDelete { indexSet in
                        deleteRecords(from: group.records, at: indexSet)
                    }
                } header: {
                    dailySectionHeader(date: group.date, count: group.records.count)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func dailySectionHeader(date: Date, count: Int) -> some View {
        HStack {
            Text(RecordStore.formatDate(date, style: "M月d日"))
                .font(.subheadline.bold())
            Text(RecordStore.weekday(date))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(count) 次")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func dailyAverageRow(avg: (systolic: Int, diastolic: Int, heartRate: Int), count: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "function")
                .font(.caption)
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(.blue.gradient, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text("日均值")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Text("\(avg.systolic)/\(avg.diastolic)")
                        .font(.subheadline.bold().monospacedDigit())
                    Label("\(avg.heartRate) bpm", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                }
            }

            Spacer()

            let level = BPLevel.evaluate(systolic: avg.systolic, diastolic: avg.diastolic)
            Text(level.rawValue)
                .font(.caption.bold())
                .foregroundStyle(level.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(level.color.opacity(0.12), in: Capsule())
        }
        .listRowBackground(Color.blue.opacity(0.04))
    }

    private func recordRow(_ record: BloodPressureRecord) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(record.level.color.opacity(0.15))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: record.level.icon)
                        .font(.caption)
                        .foregroundStyle(record.level.color)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.systolic)/\(record.diastolic) mmHg")
                    .font(.subheadline.bold().monospacedDigit())
                HStack(spacing: 6) {
                    Label("\(record.heartRate) bpm", systemImage: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                    if !record.note.isEmpty {
                        Text("· \(record.note)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            Text(record.timeString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private func deleteRecords(from records: [BloodPressureRecord], at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(records[index])
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: BloodPressureRecord.self, inMemory: true)
}
